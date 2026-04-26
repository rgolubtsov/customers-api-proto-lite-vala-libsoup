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

/*
 * Build it as: $ BIN_DIR=bin;SRC_DIR=src;\
                  valac --pkg=posix -d ${BIN_DIR} -o api-lited ${SRC_DIR}/* &&\
                  rm -vRf ${BIN_DIR}/${SRC_DIR}/
 *
 * Run it as: $ ./bin/api-lited; echo $?
 */

using Posix;

/** The main namespace of the daemon. */
namespace core {
    // TODO: Implement getting the daemon settings and all the rest.
    // Helper constants.
    const string O_BRACKET =  "[";
    const string C_BRACKET =  "]";
    const string NEW_LINE  = "\n";

    /**
     * This method is in fact the microservice entry point.
     * It gets called just in the {{{main()}}} method but wrapped
     * into the {{{core}}} namespace for better conformity.
     *
     * @param args An array of command-line arguments.
     *
     * @returns The exit code of the overall termination of the daemon.
     */
    int startup(string[] args) {
        // Getting the daemon settings.
        var settings = _get_settings();

        print(settings);

        return EXIT_SUCCESS;
    }

    // Helper method. Used to get the daemon settings.
    string _get_settings() {
        return (O_BRACKET + C_BRACKET + NEW_LINE);
    }
}

/**
 * The microservice entry point.
 *
 * @param args An array of command-line arguments.
 *
 * @returns The exit code of the overall termination of the daemon.
 */
int main(string[] args) {
    return core.startup(args);
}

// vim:set nu et ts=4 sw=4:
