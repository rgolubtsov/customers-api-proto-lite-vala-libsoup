[indent=4]/*
 * src/api-lite-controllerx.gs
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.7
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

uses Sqlite

uses helper
uses model

/**
 * The controller namespace of the daemon (in Genie).
 *
 * This module is written solely to demonstrate how to use Genie code
 * in a Vala project. It simply could have been written in Vala,
 * but chosen to be written in the Genie programming language:
 *
 * [[https://docs.vala.dev/genie/]]
 *
 * @since 0.0.7
 */
namespace controllerx
    // REST API endpoints -----------------------------------------------------

    /**
     * The {{{GET /v1/customers}}} endpoint.
     *
     * Retrieves from the database and lists all customer profiles.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    def list_customers(dbg:bool, cnx:Database)
        _dbg(dbg, O_BRACKET + "3. list_customers" + C_BRACKET)

        stmt:Statement

        // Retrieving all customer profiles from the database.
        var res = cnx.prepare_v2(SQL_GET_ALL_CUSTOMERS,
                                 SQL_GET_ALL_CUSTOMERS.length, out stmt)

        if (res is not OK) do warning(cnx.errmsg())
        else
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET)

            while (stmt.step() is ROW)
                var row = (stmt.column_int (0).to_string() // getId()
                + V_BAR +  stmt.column_text(1))            // getName()

                _dbg(dbg, O_BRACKET + row + C_BRACKET)

    /**
     * The {{{GET /v1/customers/{customer_id}}}} endpoint.
     *
     * Retrieves profile details for a given customer from the database.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    def get_customer(dbg:bool, cnx:Database)
        _dbg(dbg, O_BRACKET + "4. get_customer" + C_BRACKET)

        stmt:Statement

        // Retrieving profile details for a given customer from the database.
        var res = cnx.prepare_v2(SQL_GET_CUSTOMER_BY_ID,
                                 SQL_GET_CUSTOMER_BY_ID.length, out stmt)

        if (res is not OK) do warning(cnx.errmsg())
        else
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET)

            var cust_id = 2 // <== TODO: Replace with the actual one.
            _dbg(dbg, REST_CUST_ID + EQUALS + cust_id.to_string())

            stmt.bind_int(1, cust_id)

            if (stmt.step() is ROW)
                var row = (stmt.column_int (0).to_string() // getId()
                + V_BAR +  stmt.column_text(1))            // getName()

                _dbg(dbg, O_BRACKET + row + C_BRACKET)

// vim:set nu et ts=4 sw=4:
