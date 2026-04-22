/*
 * src/api-lite-core.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.1
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
}

/**
 * The microservice entry point.
 *
 * @param args An array of command-line arguments.
 *
 * @returns The exit code of the overall termination of the daemon.
 */
int main(string[] args) {
    return EXIT_SUCCESS;
}

// vim:set nu et ts=4 sw=4:
