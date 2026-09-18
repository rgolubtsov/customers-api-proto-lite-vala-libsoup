/*
 * src/api-lite-controller.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.6
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Sqlite;
using Soup;
using Json;

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
     * @param msg The request message being processed.
     */
    void add_customer(bool dbg, Database cnx, ServerMessage msg) {
        Statement stmt;

        // Creating a new customer (putting customer data to the database).
        var res = cnx.prepare_v2(SQL_PUT_CUSTOMER,
                                 SQL_PUT_CUSTOMER.length, out stmt);

        if (res != OK) {
            warning(cnx.errmsg());

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);
        } else {
            var customer_name = "JP"; // <== TODO: Replace with the actual one.
            _dbg(dbg, O_BRACKET + customer_name + C_BRACKET);

            stmt.bind_text(1, customer_name);

            if (stmt.step() == DONE) {
                stmt.reset();

                var res_ = cnx.prepare_v2(SQL_GET_ALL_CUSTOMERS
                                        + SQL_DESC_LIMIT_1,
                                         (SQL_GET_ALL_CUSTOMERS
                                        + SQL_DESC_LIMIT_1).length, out stmt);

                if (res_ != OK) {
                    warning(cnx.errmsg());

                    msg.set_response(MIME_TYPE, COPY,
                       _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
                    msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);

                    return;
                } else {
                    if (stmt.step() == ROW) {
                        var row = stmt.column_int (0).to_string() // getId()
                        + V_BAR + stmt.column_text(1);            // getName()

                        _dbg(dbg, O_BRACKET + row + C_BRACKET);
                    }
                }
            }

            msg.set_status(Soup.Status.CREATED, null);
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
     * @param msg The request message being processed.
     */
    void add_contact(bool dbg, Database cnx, ServerMessage msg) {
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

        if (res != OK) {
            warning(cnx.errmsg());

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);
        } else {
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

                if (res_ != OK) {
                    warning(cnx.errmsg());

                    msg.set_response(MIME_TYPE, COPY,
                       _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
                    msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);

                    return;
                } else {
                    stmt.bind_int(1, int.parse(contact_cust_id));

                    if (stmt.step() == ROW) {
                        var row = cont_type
                        + V_BAR + stmt.column_text(0); // getContact()

                        _dbg(dbg, O_BRACKET + row + C_BRACKET);
                    }
                }
            }

            msg.set_status(Soup.Status.CREATED, null);
        }
    }

    /**
     * The {{{GET /v1/customers/{customer_id}/contacts}}} endpoint.
     *
     * Retrieves from the database and lists all contacts
     * associated with a given customer.
     *
     * @param dbg         The debug logging enabler.
     * @param cnx         The database connection.
     * @param msg         The request message being processed.
     * @param customer_id The customer ID.
     */
    void list_contacts(bool          dbg,
                       Database      cnx,
                       ServerMessage msg,
                       int           customer_id) {

        _dbg(dbg, REST_CUST_ID + EQUALS + customer_id.to_string());

        Statement stmt;

        // Retrieving all contacts associated with a given customer
        // from the database.
        var res = cnx.prepare_v2(SQL_GET_ALL_CONTACTS,
                                 SQL_GET_ALL_CONTACTS.length, out stmt);

        if (res != OK) {
            warning(cnx.errmsg());

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);
        } else {
            stmt.bind_int(1, customer_id); // <== For retrieving phones.
            stmt.bind_int(2, customer_id); // <== For retrieving emails.

            Contact[] contacts = { Contact(EMPTY_STRING, EMPTY_STRING) };

            while (stmt.step() == ROW)
                contacts += Contact(stmt.column_text(0),
                                    customer_id.to_string());

            if (contacts.length == 1) {
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_NOT_FOUND_3));
                msg.set_status(Soup.Status.NOT_FOUND, null);

                return;
            }

            // Eliminating the unneeded first element from the contacts array.
            if (contacts.length > 1) contacts = contacts[1:contacts.length];

            var json_ary  = new Json.Array();
            var json_node = new Json.Node(ARRAY);
            var json_gen  = new Generator();
            var json_body = new StringBuilder();

            foreach (var contact in contacts) {
                var json_obj = new Json.Object();
                json_obj.set_string_member(JSON_CONTACT, contact.contact);
                json_ary.add_object_element(json_obj);
            }

            json_node.init_array(json_ary);
            json_gen.set_root(json_node);
            json_gen.to_gstring(json_body);

            _dbg(dbg, O_BRACKET + contacts[0].contact // getContact()
                    + C_BRACKET);

            msg.set_response(MIME_TYPE, COPY, json_body.data);
            msg.set_status(Soup.Status.OK, null);
        }
    }

    /**
     * The {{{GET /v1/customers/{customer_id}/contacts/{contact_type}}}}
     * endpoint.
     *
     * Retrieves from the database and lists all contacts of a given type
     * associated with a given customer.
     *
     * @param dbg          The debug logging enabler.
     * @param cnx          The database connection.
     * @param msg          The request message being processed.
     * @param customer_id  The customer ID.
     * @param contact_type The type of contact: phone or email.
     */
    void list_contacts_by_type(bool          dbg,
                               Database      cnx,
                               ServerMessage msg,
                               int           customer_id,
                               string        contact_type) {

        _dbg(dbg, REST_CUST_ID   + EQUALS + customer_id.to_string() + SPACE
+ V_BAR + SPACE + REST_CONT_TYPE + EQUALS + contact_type);

        var sql_query = SQL_GET_CONTACTS_BY_TYPE[1];
               if (contact_type == PHONE) {
            sql_query = SQL_GET_CONTACTS_BY_TYPE[0];
        } else if (contact_type == EMAIL) {
            sql_query = SQL_GET_CONTACTS_BY_TYPE[1];
        }

        Statement stmt;

        // Retrieving all contacts of a given type associated
        // with a given customer from the database.
        var res = cnx.prepare_v2(sql_query, sql_query.length, out stmt);

        if (res != OK) {
            warning(cnx.errmsg());

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_SRV_INTERNAL_ERROR));
            msg.set_status(Soup.Status.INTERNAL_SERVER_ERROR, null);
        } else {
            stmt.bind_int(1, customer_id);

            while (stmt.step() == ROW) {
                var row = stmt.column_text(0); // getContact()

                _dbg(dbg, O_BRACKET + row + C_BRACKET);
            }

            msg.set_status(Soup.Status.OK, null);
        }
    }
}

// vim:set nu et ts=4 sw=4:
