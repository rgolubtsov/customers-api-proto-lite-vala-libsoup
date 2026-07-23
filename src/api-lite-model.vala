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

    /**
     * The SQL query for retrieving profile details for a given customer.
     *
     * Used by the {{{GET /v1/customers/{customer_id}}}} REST endpoint.
     */
    const string SQL_GET_CUSTOMER_BY_ID = """
        select id , -- as 'Customer ID'
               name -- as 'Customer Name'
         from
               customers
         where
              (id = ?)""";

    /**
     * The SQL query for retrieving all contacts for a given customer.
     *
     * Used by the {{{GET /v1/customers/{customer_id}/contacts}}}
     * REST endpoint.
     */
    const string SQL_GET_ALL_CONTACTS = """
        select phones.contact -- as 'Phone(s)'
         from
               contact_phones phones,
               customers      cust
         where
              (cust.id = phones.customer_id) and
              (cust.id =                  ?)
         union
        select emails.contact -- as 'Email(s)'
         from
               contact_emails emails,
               customers      cust
         where
              (cust.id = emails.customer_id) and
              (cust.id =                  ?)""";

    /**
     * An array of SQL queries for retrieving all contacts of a given type
     * for a given customer.
     *
     * Used by
     * the {{{GET /v1/customers/{customer_id}/contacts/{contact_type}}}}
     * REST endpoint.
     */
    const string[] SQL_GET_CONTACTS_BY_TYPE = {"""
        select phones.contact -- as 'Phone(s)'
         from
               contact_phones phones,
               customers      cust
         where
              (cust.id = phones.customer_id) and
              (cust.id =                  ?)""","""
        select emails.contact -- as 'Email(s)'
         from
               contact_emails emails,
               customers      cust
         where
              (cust.id = emails.customer_id) and
              (cust.id =                  ?)"""};
}

// vim:set nu et ts=4 sw=4:
