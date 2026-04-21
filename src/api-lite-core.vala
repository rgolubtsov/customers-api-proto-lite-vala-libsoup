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

// The main namespace of the daemon -------------------------------------------

// Build it as: $ valac --pkg=posix src/api-lite-core.vala

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
    return Posix.EXIT_SUCCESS;
}

// vim:set nu et ts=4 sw=4:
