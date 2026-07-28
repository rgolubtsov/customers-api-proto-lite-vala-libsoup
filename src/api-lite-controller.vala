/*
 * src/api-lite-controller.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.6
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Sqlite;

using helper;
using model;
using modelx;

/**
 * The controller namespace of the daemon.
 *
 * @since 0.0.5
 */
namespace controller {
    // REST API endpoints -----------------------------------------------------

    /**
     * The {{{PUT /v1/customers}}} endpoint.
     *
     * Creates a new customer (puts customer data to the database).
     *
     * The request body is defined exactly in the form
     * as {{{{\"name\":\"{customer_name}\"}}}}. It should be passed
     * with the accompanied request header {{{content-type}}}
     * just like the following:
     *
     * {{{
     * -H 'content-type: application/json' -d '{\"name\":\"{customer_name}\"}'
     * }}}
     *
     * {{{{customer_name}}}} is a name assigned to a newly created customer.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void add_customer(bool dbg, Database cnx) {
        // TODO: Implement creating a new customer
        //       (putting customer data to the database).
        _dbg(dbg, O_BRACKET + "1. add_customer" + C_BRACKET);

        Statement stmt;

        // Creating a new customer (putting customer data to the database).
        var res = cnx.prepare_v2(SQL_PUT_CUSTOMER,
                                 SQL_PUT_CUSTOMER.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);
        }
    }

    /**
     * The {{{PUT /v1/customers/contacts}}} endpoint.
     *
     * Creates a new contact for a given customer (puts a contact
     * regarding a given customer to the database).
     *
     * The request body is defined exactly in the form as
     * {{{{\"customer_id\":\"{customer_id}\",\"contact\":\"{customer_contact}\"}}}}.
     * It should be passed with the accompanied request header
     * {{{content-type}}} just like the following:
     *
     * {{{
     * -H 'content-type: application/json' -d '{\"customer_id\":\"{customer_id}\",\"contact\":\"{customer_contact}\"}'
     * }}}
     *
     * {{{{customer_id}}}} is the customer ID used to associate a newly created
     * contact with this customer.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void add_contact(bool dbg, Database cnx) {
        // TODO: Implement creating a new contact for a given customer
        //       (putting a contact regarding a given customer
        //       to the database).
        _dbg(dbg, O_BRACKET + "2. add_contact" + C_BRACKET);

        var cont_type = EMAIL; // <== TODO: Replace with the actual one.

        var sql_query = SQL_PUT_CONTACT[1];
               if (cont_type == PHONE) {
            sql_query = SQL_PUT_CONTACT[0];
        } else if (cont_type == EMAIL) {
            sql_query = SQL_PUT_CONTACT[1];
        }

        Statement stmt;

        // Creating a new contact (putting a contact regarding a given customer
        // to the database).
        var res = cnx.prepare_v2(sql_query, sql_query.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);
        }
    }

    /**
     * The {{{GET /v1/customers}}} endpoint.
     *
     * Retrieves from the database and lists all customer profiles.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void list_customers(bool dbg, Database cnx) {
        _dbg(dbg, O_BRACKET + "3. list_customers" + C_BRACKET);

        Statement stmt;

        // Retrieving all customer profiles from the database.
        var res = cnx.prepare_v2(SQL_GET_ALL_CUSTOMERS,
                                 SQL_GET_ALL_CUSTOMERS.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);

            var cols = stmt.column_count();
            while (stmt.step() == ROW) {
                var row = EMPTY_STRING;
                for (var i = 0; i < cols; i++) {
                    row += stmt.column_name(i) + COLON
                        +  stmt.column_text(i) + SPACE;
                }

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }
        }
    }

    /**
     * The {{{GET /v1/customers/{customer_id}}}} endpoint.
     *
     * Retrieves profile details for a given customer from the database.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void get_customer(bool dbg, Database cnx) {
        _dbg(dbg, O_BRACKET + "4. get_customer" + C_BRACKET);

        Statement stmt;

        // Retrieving profile details for a given customer from the database.
        var res = cnx.prepare_v2(SQL_GET_CUSTOMER_BY_ID,
                                 SQL_GET_CUSTOMER_BY_ID.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);

            var cust_id = 2; // <== TODO: Replace with the actual one.

            stmt.bind_int(1, cust_id);

            var cols = stmt.column_count();
            if (stmt.step() == ROW) {
                var row = EMPTY_STRING;
                for (var i = 0; i < cols; i++) {
                    row += stmt.column_name(i) + COLON
                        +  stmt.column_text(i) + SPACE;
                }

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }
        }
    }

    /**
     * The {{{GET /v1/customers/{customer_id}/contacts}}} endpoint.
     *
     * Retrieves from the database and lists all contacts
     * associated with a given customer.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void list_contacts(bool dbg, Database cnx) {
        _dbg(dbg, O_BRACKET + "5. list_contacts" + C_BRACKET);

        Statement stmt;

        // Retrieving all contacts associated with a given customer
        // from the database.
        var res = cnx.prepare_v2(SQL_GET_ALL_CONTACTS,
                                 SQL_GET_ALL_CONTACTS.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);

            var cust_id = 2; // <== TODO: Replace with the actual one.

            stmt.bind_int(1, cust_id); // <== For retrieving phones.
            stmt.bind_int(2, cust_id); // <== For retrieving emails.

            var cols = stmt.column_count();
            while (stmt.step() == ROW) {
                var row = EMPTY_STRING;
                for (var i = 0; i < cols; i++) {
                    row += stmt.column_name(i) + COLON
                        +  stmt.column_text(i) + SPACE;
                }

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }
        }
    }

    /**
     * The {{{GET /v1/customers/{customer_id}/contacts/{contact_type}}}}
     * endpoint.
     *
     * Retrieves from the database and lists all contacts of a given type
     * associated with a given customer.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     */
    void list_contacts_by_type(bool dbg, Database cnx) {
        _dbg(dbg, O_BRACKET + "6. list_contacts_by_type" + C_BRACKET);

        var cont_type = EMAIL; // <== TODO: Replace with the actual one.

        var sql_query = SQL_GET_CONTACTS_BY_TYPE[1];
               if (cont_type == PHONE) {
            sql_query = SQL_GET_CONTACTS_BY_TYPE[0];
        } else if (cont_type == EMAIL) {
            sql_query = SQL_GET_CONTACTS_BY_TYPE[1];
        }

        Statement stmt;

        // Retrieving all contacts of a given type associated
        // with a given customer from the database.
        var res = cnx.prepare_v2(sql_query, sql_query.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            _dbg(dbg, O_BRACKET + stmt.sql() + C_BRACKET);

            var cust_id = 2; // <== TODO: Replace with the actual one.

            stmt.bind_int(1, cust_id);

            var cols = stmt.column_count();
            while (stmt.step() == ROW) {
                var row = EMPTY_STRING;
                for (var i = 0; i < cols; i++) {
                    row += stmt.column_name(i) + COLON
                        +  stmt.column_text(i) + SPACE;
                }

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }
        }
    }
}

// vim:set nu et ts=4 sw=4:
