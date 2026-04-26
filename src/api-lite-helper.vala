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

/**
 * The helper namespace for the daemon.
 *
 * @since 0.0.2
 */
namespace helper {
    // Helper constants.
    const string O_BRACKET =  "[";
    const string C_BRACKET =  "]";
    const string NEW_LINE  = "\n";

    // Helper method. Used to get the daemon settings.
    KeyFile _get_settings() {
        var settings = new KeyFile();

        // TODO: Implement getting the daemon settings.

        return settings;
    }
}

// vim:set nu et ts=4 sw=4:
