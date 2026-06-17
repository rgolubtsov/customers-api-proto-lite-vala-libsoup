/*
 * src/api-lite-core.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.4
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Posix;
using Log;

using helper;

/**
 * The main namespace of the daemon.
 *
 * @since 0.0.1
 */
namespace core {
    /**
     * This method is in fact the microservice entry point.
     * It gets called just in the {{{main()}}} method but wrapped
     * into the {{{core}}} namespace for better conformity.
     *
     * @param args An array of command-line arguments.
     *
     * @return The exit code of the overall termination of the daemon.
     */
    int startup(string[] args) {
        try {
            var logdir = File.new_for_path(LOG_DIR); if(!logdir.query_exists())
                logdir.make_directory();
            logfile = File.new_for_path(LOG_DIR + LOGFILE).append_to(NONE);
        } catch (Error e) { return EXIT_FAILURE; }

        // Registering the log writer callback.
        set_writer_func(log_writer);

        // Getting the daemon settings.
        var settings = _get_settings();

        // Identifying whether debug logging is enabled.
        var dbg = _is_debug_log_enabled(settings);

        var daemon_name = EMPTY_STRING;
        try { daemon_name = settings.get_string(DAEMON_GROUP, DAEMON_NAME); }
        catch (KeyFileError e) { return EXIT_FAILURE; }
        _dbg(dbg, O_BRACKET + daemon_name + C_BRACKET);

        // Getting the SQLite database path.
        var database_path = EMPTY_STRING;
        try { database_path = settings.get_string(SQLITE_GROUP, DB_PATH); }
        catch (KeyFileError e) { return EXIT_FAILURE; }
        _dbg(dbg, O_BRACKET + database_path + C_BRACKET);

        // Getting the port number used to run the Soup web server.
        var server_port = _get_server_port(settings);
        _dbg(dbg, O_BRACKET + server_port.to_string() + C_BRACKET);

        return EXIT_SUCCESS;
    }
}

/**
 * The microservice entry point.
 *
 * @param args An array of command-line arguments.
 *
 * @return The exit code of the overall termination of the daemon.
 */
int main(string[] args) {
    return core.startup(args);
}

// vim:set nu et ts=4 sw=4:
