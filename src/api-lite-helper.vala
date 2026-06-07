/*
 * src/api-lite-helper.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.2
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Posix;

/**
 * The helper namespace for the daemon.
 *
 * @since 0.0.2
 */
namespace helper {
    // Helper constants.
    const string EMPTY_STRING =   "";
    const string O_BRACKET    =  "[";
    const string C_BRACKET    =  "]";
    const string NEW_LINE     = "\n";

    // Common error messages.
    const string ERR_SETTINGS_NOT_FOUND
        = "FATAL: Unable to get daemon settings: %s.";

    /**
     * The filename of the daemon settings (as a series
     * of {{{GLib.KeyFile}}} key-value pairs).
     */
    const string SETTINGS = "./etc/settings.conf";

    // Daemon settings keys for the debug logging enabler.
    const string LOGGER_GROUP = "logger";
    const string DBG_ENABLED  = "debug.enabled";

    // Daemon settings keys for the microservice daemon name.
    const string DAEMON_GROUP = "daemon";
    const string DAEMON_NAME  = "name";

    // Daemon settings keys for the SQLite database path.
    const string SQLITE_GROUP = "sqlite";
    const string DB_PATH      = "database.path";

    // Helper method. Used to get the daemon settings.
    KeyFile _get_settings() {
        var  settings  = new KeyFile();
        bool is_loaded = false;

        try {
            is_loaded = settings.load_from_file(SETTINGS, KeyFileFlags.NONE);
        } catch (Error e) {
            if (e is FileError.NOENT) {
                warning(ERR_SETTINGS_NOT_FOUND, e.message);
            }
        }

        if (!is_loaded) exit(EXIT_FAILURE);

        return settings;
    }

    // Helper method. Identifies whether debug logging is enabled by retrieving
    //                the corresponding setting from daemon settings.
    bool _is_debug_log_enabled(KeyFile settings) {
        var dbg = true;

        try {
            dbg = settings.get_boolean(LOGGER_GROUP, DBG_ENABLED);
        } catch (KeyFileError e) {
            if (e is KeyFileError.KEY_NOT_FOUND) dbg = false;
        }

        return dbg;
    }
}

// vim:set nu et ts=4 sw=4:
