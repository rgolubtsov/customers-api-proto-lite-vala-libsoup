/*
 * src/api-lite-core.vala
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
        // Getting the daemon settings.
        var settings = helper._get_settings();

        // TODO: Implement making use of daemon settings.
        print(settings.to_data()); // <== In such a way..

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
