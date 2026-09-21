/*
 * src/api-lite-controller.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.2.0
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
using ControllerX;

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
     * as {{{{"name":"{customer_name}"}}}}. It should be passed
     * with the accompanied request header {{{content-type}}}
     * just like the following:
     *
     * {{{
     * -H 'content-type: application/json' -d '{"name":"{customer_name}"}'
     * }}}
     *
     * {{{{customer_name}}}} is a name assigned to a newly created customer.
     *
     * @param dbg The debug logging enabler.
     * @param cnx The database connection.
     * @param msg The request message being processed.
     */
    void add_customer(bool dbg, Database cnx, ServerMessage msg) {
        var payload = msg.get_request_body().data;

        if (payload.length == 0) {
            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        var    json_parser = new Parser();
        string customer_name;

        try {
            json_parser.load_from_data((string) payload);
            var json_node = json_parser.get_root();

            if (json_node.get_node_type() != OBJECT) {
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_MALFORMED));
                msg.set_status(Soup.Status.BAD_REQUEST, null); return;
            }

            customer_name = json_node.get_object()
                .get_string_member_with_default(JSON_NAME, EMPTY_STRING);

            if (customer_name == EMPTY_STRING) {
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_MALFORMED));
                msg.set_status(Soup.Status.BAD_REQUEST, null); return;
            }
        } catch (Error e) {
            warning(e.message);

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        _dbg(dbg, O_BRACKET + customer_name + C_BRACKET);

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
                        var customer = Customer(stmt.column_int (0),
                                                stmt.column_text(1));

                        var json_obj  = new Json.Object();
                        var json_node = new Json.Node(OBJECT);
                        var json_gen  = new Generator();
                        var json_body = new StringBuilder();

                        json_obj.set_int_member(   JSON_ID,   customer.id  );
                        json_obj.set_string_member(JSON_NAME, customer.name);
                        json_node.init_object(json_obj);
                        json_gen.set_root(json_node);
                        json_gen.to_gstring(json_body);

                        _dbg(dbg, O_BRACKET + customer.id.to_string()
                                + V_BAR     + customer.name
                                + C_BRACKET);

                        msg.get_response_headers().append(HDR_LOCATION,
                            REST_CONTEXT + SLASH + customer.id.to_string());
                        msg.set_response(MIME_TYPE, COPY, json_body.data);
                        msg.set_status(Soup.Status.CREATED, null);
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
     * {{{{"customer_id":"{customer_id}","contact":"{customer_contact}"}}}}.
     * It should be passed with the accompanied request header
     * {{{content-type}}} just like the following:
     *
     * {{{
     * -H 'content-type: application/json' -d '{"customer_id":"{customer_id}","contact":"{customer_contact}"}'
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
        var payload = msg.get_request_body().data;

        if (payload.length == 0) {
            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        var    json_parser = new Parser();
        string contact_cust_id;
        string contact_contact;

        try {
            json_parser.load_from_data((string) payload);
            var json_node = json_parser.get_root();

            if (json_node.get_node_type() != OBJECT) {
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_MALFORMED));
                msg.set_status(Soup.Status.BAD_REQUEST, null); return;
            }

            var json_obj = json_node.get_object();
            contact_cust_id = json_obj
                .get_string_member_with_default(REST_CUST_ID, EMPTY_STRING);
            contact_contact = json_obj
                .get_string_member_with_default(JSON_CONTACT, EMPTY_STRING);

            if ((   contact_cust_id == EMPTY_STRING)
                || (contact_contact == EMPTY_STRING)) {

                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_MALFORMED));
                msg.set_status(Soup.Status.BAD_REQUEST, null); return;
            }
        } catch (Error e) {
            warning(e.message);

            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        _dbg(dbg, REST_CUST_ID + EQUALS + contact_cust_id);
        _dbg(dbg, O_BRACKET + contact_contact + C_BRACKET);

        // Parsing and validating the request payload {customer_id}.
        var customer_id = int.parse(contact_cust_id);
        if (customer_id == 0) {
            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        // Analyzing whether a given customer exists in the database.
        if (!get_customer(dbg, cnx, msg, customer_id, true)) return;

        // Parsing and validating a customer contact: phone or email.
        var contact_type = _parse_contact(contact_contact);
        if (contact_type == EMPTY_STRING) {
            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_MALFORMED));
            msg.set_status(Soup.Status.BAD_REQUEST, null); return;
        }

        var sql_query = SQL_PUT_CONTACT[1];
               if (contact_type == PHONE) {
            sql_query = SQL_PUT_CONTACT[0];
        } else if (contact_type == EMAIL) {
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
            stmt.bind_text(1, contact_contact);
            stmt.bind_int( 2, customer_id    );

            if (stmt.step() == DONE) {
                stmt.reset();

                var sql_query_ = SQL_GET_CONTACTS_BY_TYPE[1];
                       if (contact_type == PHONE) {
                    sql_query_ = SQL_GET_CONTACTS_BY_TYPE[0]
                               + SQL_ORDER_CONTACTS_BY_ID[0];
                } else if (contact_type == EMAIL) {
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
                    stmt.bind_int(1, customer_id);

                    if (stmt.step() == ROW) {
                        var contact = Contact(stmt.column_text(0),
                                              customer_id.to_string());

                        var json_obj  = new Json.Object();
                        var json_node = new Json.Node(OBJECT);
                        var json_gen  = new Generator();
                        var json_body = new StringBuilder();

                        json_obj.set_string_member(JSON_CONTACT,
                                                   contact.contact);
                        json_node.init_object(json_obj);
                        json_gen.set_root(json_node);
                        json_gen.to_gstring(json_body);

                        _dbg(dbg, O_BRACKET + contact_type
                                + V_BAR     + contact.contact // getContact()
                                + C_BRACKET);

                        msg.get_response_headers().append(HDR_LOCATION,
                            REST_CONTEXT  + SLASH + contact.customer_id + SLASH
                          + REST_CONTACTS + SLASH + contact_type);
                        msg.set_response(MIME_TYPE, COPY, json_body.data);
                        msg.set_status(Soup.Status.CREATED, null);
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
                   _get_err_json_body(ERR_REQ_NOT_FOUND_4));
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

            Contact[] contacts = { Contact(EMPTY_STRING, EMPTY_STRING) };

            while (stmt.step() == ROW)
                contacts += Contact(stmt.column_text(0),
                                    customer_id.to_string());

            if (contacts.length == 1) {
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_NOT_FOUND_4));
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

    // Helper method. Used to parse and validate a customer contact.
    //                Returns the type of contact: phone or email.
    string _parse_contact(string contact) {
        try {
                 if (new Regex(PHONE_REGEX).match(contact))
                return PHONE;
            else if (new Regex(EMAIL_REGEX).match(contact))
                return EMAIL;
        } catch (RegexError e) {}

        return EMPTY_STRING;
    }
}

// vim:set nu et ts=4 sw=4:
