/*
 * src/api-lite-handler.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.4
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Soup;
using Json;

using Helper;
using Controller;
using ControllerX;

/**
 * The request handler namespace of the daemon.
 *
 * @since 0.0.9
 */
namespace Handler {
    /**
     * The request "early" handler callback, commonly known as a request filter
     * for the "/v1/customers"-prefixed URI path.
     *
     * @param server The Soup web server.
     * @param msg    The request message being processed.
     * @param path   The path component of the request message URI.
     * @param query  The parsed query component of the request message URI.
     */
    void request_filter(Server                     server,
                        ServerMessage              msg,
                        string                     path,
                        HashTable<string, string>? query) {

        msg.get_response_headers().append(HDR_X_REQ_M, msg.get_method());
    }

    /**
     * The request handler callback for the "/v1/customers"-prefixed URI path.
     * Used to process the incoming request.
     *
     * Allowed and properly handled routes are the following ones:
     *
     * {{{
     * PUT /v1/customers
     * PUT /v1/customers/contacts
     * GET /v1/customers
     * GET /v1/customers/{customer_id}
     * GET /v1/customers/{customer_id}/contacts
     * GET /v1/customers/{customer_id}/contacts/{contact_type}
     * }}}
     *
     * @param server The Soup web server.
     * @param msg    The request message being processed.
     * @param path   The path component of the request message URI.
     * @param query  The parsed query component of the request message URI.
     */
    void request_handler(Server                     server,
                         ServerMessage              msg,
                         string                     path,
                         HashTable<string, string>? query) {

        var method = msg.get_method();
        _dbg(dbg_, O_BRACKET + method + C_BRACKET);
        _dbg(dbg_, O_BRACKET + path   + C_BRACKET);

               if (method == HTTP_PUT) {
                   if (path ==  REST_CONTEXT) {
                add_customer(dbg_, cnx_, msg);
            } else if (path == (REST_CONTEXT + SLASH + REST_CONTACTS)) {
                add_contact(dbg_, cnx_, msg);
            } else {
                // For any other route Soup will automatically respond
                // with the HTTP 404 Not Found status code, or respond
                // with the following:
                msg.set_response(MIME_TYPE, COPY,
                   _get_err_json_body(ERR_REQ_NOT_FOUND_1));
                msg.set_status(Status.NOT_FOUND, null);
            }
        } else if ((method == HTTP_GET) || (method == HTTP_HEAD)) {
            try {
                var get_customer_path_regex
                    = new Regex(REST_CONTEXT + SLASH + REST_CUST_ID_R + EOL_R);
                var list_contacts_path_regex
                    = new Regex(REST_CONTEXT + SLASH + REST_CUST_ID_R + SLASH
                                                     + REST_CONTACTS  + EOL_R);
                var contact_type = _get_contact_type(path);
                var list_contacts_by_type_path_regex
                    = new Regex(REST_CONTEXT + SLASH + REST_CUST_ID_R + SLASH
                                                     + REST_CONTACTS  + SLASH
                                                     + contact_type   + EOL_R);

                       if (path ==  REST_CONTEXT) {
                    list_customers(dbg_, cnx_, msg);
                } else if (get_customer_path_regex.match(path)) {
                    get_customer(dbg_, cnx_, msg);
                } else if (list_contacts_path_regex.match(path)) {
                    list_contacts(dbg_, cnx_, msg);
                } else if (list_contacts_by_type_path_regex.match(path)) {
                    list_contacts_by_type(dbg_, cnx_, msg, contact_type);
                } else {
                    // For any other route Soup will automatically respond
                    // with the HTTP 404 Not Found status code, or respond
                    // with the following:
                    msg.set_response(MIME_TYPE, COPY,
                       _get_err_json_body(ERR_REQ_NOT_FOUND_1));
                    msg.set_status(Status.NOT_FOUND, null);
                }
            } catch (RegexError e) {}
        } else {
            msg.get_response_headers().append(HDR_ALLOW, HDR_ALLOWED);
            msg.set_response(MIME_TYPE, COPY,
               _get_err_json_body(ERR_REQ_NOT_ALLOWED));
            msg.set_status(Status.METHOD_NOT_ALLOWED, null);
        }
    }

    // Helper method. Returns a serialized JSON object for a given error
    //                message to use directly as an HTTP response body.
    uint8[] _get_err_json_body(string err_msg) {
        var json_obj  = new Json.Object();
        var json_node = new Json.Node(OBJECT);
        var json_gen  = new Generator();
        var json_body = new StringBuilder();

        json_obj.set_string_member(JSON_ERROR, err_msg);
        json_node.init_object(json_obj);
        json_gen.set_root(json_node);
        json_gen.to_gstring(json_body);

        return json_body.data;
    }

    // Helper method. Used to find a valid contact type in the route path
    //                and (if found such) returns the type of contact:
    //                phone or email.
    string _get_contact_type(string path) {
             if (path.contains(SLASH + REST_CONTACTS + SLASH + PHONE))
            return PHONE;
        else if (path.contains(SLASH + REST_CONTACTS + SLASH + EMAIL))
            return EMAIL;
        else
            return EMPTY_STRING;
    }
}

// vim:set nu et ts=4 sw=4:
