/*
 * src/api-lite-controller.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.0.8
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Sqlite;

using Helper;
using Model;
using ModelX;

/**
 * The controller namespace of the daemon.
 *
 * @since 0.0.5
 */
namespace Controller {
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
        _dbg(dbg, O_BRACKET + "1. add_customer" + C_BRACKET);

        Statement stmt;

        // Creating a new customer (putting customer data to the database).
        var res = cnx.prepare_v2(SQL_PUT_CUSTOMER,
                                 SQL_PUT_CUSTOMER.length, out stmt);

        if (res != OK) { warning(cnx.errmsg()); } else {
            var customer_name = "JP"; // <== TODO: Replace with the actual one.
            _dbg(dbg, O_BRACKET + customer_name + C_BRACKET);

            stmt.bind_text(1, customer_name);

            if (stmt.step() == DONE) {
                stmt.reset();

                var res_ = cnx.prepare_v2(SQL_GET_ALL_CUSTOMERS
                                        + SQL_DESC_LIMIT_1,
                                         (SQL_GET_ALL_CUSTOMERS
                                        + SQL_DESC_LIMIT_1).length, out stmt);

                if (res_ != OK) { warning(cnx.errmsg()); } else {
                    if (stmt.step() == ROW) {
                        var row = stmt.column_int (0).to_string() // getId()
                        + V_BAR + stmt.column_text(1);            // getName()

                        _dbg(dbg, O_BRACKET + row + C_BRACKET);
                    }
                }
            }
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
            // TODO: Replace with the actual ones. -----------+
            var contact_cust_id = "2";              // <------|
            var contact_contact = "jp@example.com"; // <------+
            _dbg(dbg, REST_CUST_ID + EQUALS + contact_cust_id);
            _dbg(dbg, O_BRACKET + contact_contact + C_BRACKET);

            stmt.bind_text(1, contact_contact);
            stmt.bind_text(2, contact_cust_id);

            if (stmt.step() == DONE) {
                stmt.reset();

                var sql_query_ = SQL_GET_CONTACTS_BY_TYPE[1];
                       if (cont_type == PHONE) {
                    sql_query_ = SQL_GET_CONTACTS_BY_TYPE[0]
                               + SQL_ORDER_CONTACTS_BY_ID[0];
                } else if (cont_type == EMAIL) {
                    sql_query_ = SQL_GET_CONTACTS_BY_TYPE[1]
                               + SQL_ORDER_CONTACTS_BY_ID[1];
                }

                var res_ = cnx.prepare_v2(sql_query_+ SQL_DESC_LIMIT_1,
                                         (sql_query_+ SQL_DESC_LIMIT_1).length,
                                          out stmt);

                if (res_ != OK) { warning(cnx.errmsg()); } else {
                    stmt.bind_int(1, int.parse(contact_cust_id));

                    if (stmt.step() == ROW) {
                        var row = cont_type
                        + V_BAR + stmt.column_text(0); // getContact()

                        _dbg(dbg, O_BRACKET + row + C_BRACKET);
                    }
                }
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
            var cust_id = 2; // <== TODO: Replace with the actual one.
            _dbg(dbg, REST_CUST_ID + EQUALS + cust_id.to_string());

            stmt.bind_int(1, cust_id); // <== For retrieving phones.
            stmt.bind_int(2, cust_id); // <== For retrieving emails.

            while (stmt.step() == ROW) {
                var row = stmt.column_text(0); // getContact()

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
            var cust_id = 2; // <== TODO: Replace with the actual one.
            _dbg(dbg, REST_CUST_ID   + EQUALS + cust_id.to_string() + SPACE
    + V_BAR + SPACE + REST_CONT_TYPE + EQUALS + cont_type);

            stmt.bind_int(1, cust_id);

            while (stmt.step() == ROW) {
                var row = stmt.column_text(0); // getContact()

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }
        }
    }
}

// vim:set nu et ts=4 sw=4:
