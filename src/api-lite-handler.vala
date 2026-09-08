/*
 * src/api-lite-handler.vala
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.2
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

using Soup;

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

        var method = msg.get_method();
        _dbg(dbg_, O_BRACKET + method + C_BRACKET);
        _dbg(dbg_, O_BRACKET + path   + C_BRACKET);
    }

    /**
     * The request handler callback for the "/v1/customers"-prefixed URI path.
     * Used to process the incoming request.
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

        // --- /v1/customers -----------------------------------------
        var REST_CONTEXT = SLASH + REST_VERSION + SLASH + REST_PREFIX;

        try {
            var get_customer_path_regex          = new Regex(
                REST_CONTEXT + SLASH + REST_CUST_ID_R + EOL_R);
            var list_contacts_path_regex         = new Regex(
                REST_CONTEXT + SLASH + REST_CUST_ID_R + SLASH + REST_CONTACTS
                                                      + EOL_R);
            var list_contacts_by_type_path_regex = new Regex(
                REST_CONTEXT + SLASH + REST_CUST_ID_R + SLASH + REST_CONTACTS
                                                      + SLASH + EMAIL + EOL_R);
            //                                                    ^
            //                                                    |
            // TODO: Replace with the actual one. ----------------+

                   if (method == HTTP_PUT) {
                       if (path ==  REST_CONTEXT) {
                    add_customer(dbg_, cnx_);
                } else if (path == (REST_CONTEXT + SLASH + REST_CONTACTS)) {
                    add_contact(dbg_, cnx_);
                } else {
                    _dbg(dbg_, O_BRACKET + method + V_BAR + path + C_BRACKET);
                }
            } else if ((method == HTTP_GET) || (method == HTTP_HEAD)) {
                       if (path ==  REST_CONTEXT) {
                    list_customers(dbg_, cnx_);
                } else if (get_customer_path_regex.match(path)) {
                    get_customer(dbg_, cnx_);
                } else if (list_contacts_path_regex.match(path)) {
                    list_contacts(dbg_, cnx_);
                } else if (list_contacts_by_type_path_regex.match(path)) {
                    list_contacts_by_type(dbg_, cnx_);
                } else {
                    _dbg(dbg_, O_BRACKET + method + V_BAR + path + C_BRACKET);
                }
            } else {
                _dbg(dbg_, O_BRACKET + method + V_BAR + path + C_BRACKET);
            }
        } catch (RegexError e) {}

        msg.set_status(Status.OK, null);
    }
}

// vim:set nu et ts=4 sw=4:
