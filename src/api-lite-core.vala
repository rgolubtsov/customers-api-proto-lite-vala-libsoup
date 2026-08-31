/*
 * src/api-lite-core.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.0
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Posix;
using Log;
using Sqlite;
using Soup;

using Helper;
using Handler;

/**
 * The main namespace of the daemon.
 *
 * @since 0.0.1
 */
namespace Core {
    /**
     * This method is in fact the microservice entry point.
     * It gets called just in the {{{main()}}} method but wrapped
     * into the {{{Core}}} namespace for better conformity.
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

        // Opening the system logger.
        // Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
        openlog((string) null, LOG_CONS | LOG_PID, LOG_DAEMON);

        // Getting the daemon settings.
        var settings = _get_settings();

        // Identifying whether debug logging is enabled.
        var dbg = _is_debug_log_enabled(settings); dbg_ = dbg;

        var daemon_name = EMPTY_STRING;
        try { daemon_name = settings.get_string(DAEMON_GROUP, DAEMON_NAME); }
        catch (KeyFileError e) { return EXIT_FAILURE; }
        _dbg(dbg, O_BRACKET + daemon_name + C_BRACKET);

        // Getting the SQLite database path.
        var database_path = EMPTY_STRING;
        try { database_path = settings.get_string(SQLITE_GROUP, DB_PATH); }
        catch (KeyFileError e) { return EXIT_FAILURE; }

        Database cnx;

        // Connecting to the database.
        var res = Database.open(database_path, out cnx);
        if (res == OK) {
            _dbg(dbg, O_BRACKET + ((ulong) cnx).to_string(HEX_F)
                    + C_BRACKET); cnx_ = cnx;
        } else { warning(cnx.errmsg()); }

        // Getting the port number used to run the Soup web server.
        var server_port = _get_server_port(settings);

        var server = new Server(SERVER_HEADER, EMPTY_STRING);
        server.add_handler(null, request_handler);

        // Trying to start up the Soup web server.
        try {
            server.listen_all(server_port, (ServerListenOptions) null);
            var loop = new MainLoop(); loop.run();
        } catch (Error e) {
            warning(e.message);
        }

        _cleanup();

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
    return Core.startup(args);
}

// vim:set nu et ts=4 sw=4:
