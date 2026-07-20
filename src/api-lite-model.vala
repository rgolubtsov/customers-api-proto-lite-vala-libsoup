/*
 * src/api-lite-model.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.5
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

/**
 * The model namespace of the daemon.
 *
 * @since 0.0.5
 */
namespace model {
    /**
     * The SQL query for retrieving all customer profiles.
     *
     * Used by the {{{GET /v1/customers}}} REST endpoint.
     */
    const string SQL_GET_ALL_CUSTOMERS = """
        select id , -- as 'Customer ID'
               name -- as 'Customer Name'
         from
               customers
         order by
               id""";
}

// vim:set nu et ts=4 sw=4:
