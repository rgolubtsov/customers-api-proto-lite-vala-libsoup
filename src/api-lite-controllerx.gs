[indent=4]/*
 * src/api-lite-controllerx.gs
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.7
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

uses Sqlite
uses Soup
uses Json

uses Helper
uses Model

/**
 * The controller namespace of the daemon (in Genie).
 *
 * This module is written solely to demonstrate how to use Genie code
 * in a Vala project. It simply could have been written in Vala,
 * but chosen to be written in the Genie programming language:
 *
 * [[https://docs.vala.dev/genie/]]
 *
 * @since 0.0.8
 */
namespace ControllerX
    // REST API endpoints -----------------------------------------------------

    /**
     * The {{{GET /v1/customers}}} endpoint.
     *
     * Retrieves from the database and lists all customer profiles.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     * @param msg The request message being processed.
     */
    def list_customers(dbg:bool, cnx:Database, msg:ServerMessage)
        stmt:Statement

        // Retrieving all customer profiles from the database.
        var res = cnx.prepare_v2(SQL_GET_ALL_CUSTOMERS,
                                 SQL_GET_ALL_CUSTOMERS.length, out stmt)

        if (res is not OK)
            warning(cnx.errmsg())

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR))
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null)
        else
            customers:array of Customer = { Customer(0, EMPTY_STRING) }

            while (stmt.step() is ROW)
                customers += Customer(stmt.column_int (0),
                                      stmt.column_text(1))

            if (customers.length is 1)
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_NOT_FOUND_2))
                msg.set_status(Soup.Status.NOT_FOUND, null)

                return

            // Eliminating the unneeded first element from the customers array.
            if (customers.length>1) do customers=customers[1:customers.length]

            var
                json_ary  = new Json.Array()
                json_node = new Json.Node(ARRAY)
                json_gen  = new Generator()
                json_body = new StringBuilder()

            for customer in customers
                var json_obj = new Json.Object()
                json_obj.set_int_member(   JSON_ID,   customer.id  )
                json_obj.set_string_member(JSON_NAME, customer.name)
                json_ary.add_object_element(json_obj)

            json_node.init_array(json_ary)
            json_gen.set_root(json_node)
            json_gen.to_gstring(json_body)

            _dbg(dbg, O_BRACKET + customers[0].id.to_string() // getId()
                    + V_BAR     + customers[0].name           // getName()
                    + C_BRACKET)

            msg.set_response(MIME_TYPE, COPY, json_body.data)
            msg.set_status(Soup.Status.OK, null)

    /**
     * The {{{GET /v1/customers/{customer_id}}}} endpoint.
     *
     * Retrieves profile details for a given customer from the database.
     *
     * @param dbg         The debug logging enabler.
     * @param cnx         The database connection.
     * @param msg         The request message being processed.
     * @param customer_id The customer ID.
     */
    def get_customer(dbg        :bool,
                     cnx        :Database,
                     msg        :ServerMessage,
                     customer_id:int)

        _dbg(dbg, REST_CUST_ID + EQUALS + customer_id.to_string())

        stmt:Statement

        // Retrieving profile details for a given customer from the database.
        var res = cnx.prepare_v2(SQL_GET_CUSTOMER_BY_ID,
                                 SQL_GET_CUSTOMER_BY_ID.length, out stmt)

        if (res is not OK)
            warning(cnx.errmsg())

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR))
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null)
        else
            stmt.bind_int(1, customer_id)

            if (stmt.step() is ROW)
                var customer = Customer(stmt.column_int (0),
                                        stmt.column_text(1))

                var
                    json_obj  = new Json.Object()
                    json_node = new Json.Node(OBJECT)
                    json_gen  = new Generator()
                    json_body = new StringBuilder()

                json_obj.set_int_member(   JSON_ID,   customer.id  )
                json_obj.set_string_member(JSON_NAME, customer.name)
                json_node.init_object(json_obj)
                json_gen.set_root(json_node)
                json_gen.to_gstring(json_body)

                _dbg(dbg, O_BRACKET + customer.id.to_string() // getId()
                        + V_BAR     + customer.name           // getName()
                        + C_BRACKET)

                msg.set_response(MIME_TYPE, COPY, json_body.data)
                msg.set_status(Soup.Status.OK, null)
            else
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_NOT_FOUND_2))
                msg.set_status(Soup.Status.NOT_FOUND, null)

// vim:set nu et ts=4 sw=4:
