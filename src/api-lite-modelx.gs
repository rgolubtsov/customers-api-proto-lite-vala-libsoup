[indent=4]/*
 * src/api-lite-modelx.gs
 * ============================================================================
 * Customers API Lite microservice prototype (Vala port). Version 0.1.1
 * ============================================================================
 * A daemon written in Vala, designed and intended to be run as a microservice,
 * implementing a special Customers API prototype with a smart yet simplified
 * data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

/**
 * The model namespace of the daemon (in Genie).
 *
 * This module is written solely to demonstrate how to use Genie code
 * in a Vala project. It simply could have been written in Vala,
 * but chosen to be written in the Genie programming language:
 *
 * [[https://docs.vala.dev/genie/]]
 *
 * @since 0.0.7
 */
namespace ModelX
    /**
     * The SQL query for creating a new customer
     * (putting customer data to the database).
     *
     * Used by the {{{PUT /v1/customers}}} REST endpoint.
     */
    const SQL_PUT_CUSTOMER:string = "insert into customers (name) values (?)"

    /**
     * An array of SQL queries for creating a new contact for a given customer
     * (putting a contact regarding a given customer to the database).
     *
     * Used by the {{{PUT /v1/customers/contacts}}} REST endpoint.
     */
    const SQL_PUT_CONTACT:array of string = {
        "insert into contact_phones (contact, customer_id) values (?, ?)",
        "insert into contact_emails (contact, customer_id) values (?, ?)"}

    /**
     * The intermediate part of an SQL query,
     * used to order contact records by ID.
     */
    const SQL_ORDER_CONTACTS_BY_ID:array of string = {
        " order by phones.id",
        " order by emails.id"}

    /**
     * The terminating part of an SQL query,
     * used to retrieve the last record created.
     */
    const SQL_DESC_LIMIT_1:string = " desc limit 1"

// vim:set nu et ts=4 sw=4:
