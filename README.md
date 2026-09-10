# Customers API Lite microservice prototype :small_orange_diamond: <img src="https://vala.dev/favicon-96x96.png" style="border:0;width:32px" alt="Vala" />

**A daemon written in Vala, designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[Vala](https://vala.dev "Vala Programming Language")** port of the earlier developed **Customers API Lite microservice prototype**, written in V using **[veb](https://modules.vlang.io/veb.html "The V Web Server")** web server library/framework, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-vlang-veb/blob/main/README.md)** almost as is, without any principal modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

The data scheme chosen is very simplified and consisted of only three SQL database tables, but that's quite sufficient because the service operates on only two entities: a **Customer** and a **Contact** (phone or email). And a set of these operations is limited to the following ones:

* Create a new customer (put customer data to the database).
* Create a new contact for a given customer (put a contact regarding a given customer to the database).
* Retrieve from the database and list all customer profiles.
* Retrieve profile details for a given customer from the database.
* Retrieve from the database and list all contacts associated with a given customer.
* Retrieve from the database and list all contacts of a given type associated with a given customer.

As it is clearly seen, there are no *mutating*, usually expected operations like *update* or *delete* an entity and that's made intentionally.

The microservice incorporates the **[SQLite](https://sqlite.org "A small, fast, self-contained, high-reliability, full-featured, SQL database engine")** database as its persistent store. It is located in the `data/db/` directory as an XZ-compressed database file with minimal initial data &mdash; actually having two Customers and by six Contacts for each Customer. The database file is automatically decompressed during build process of the microservice and ready to use as is even when containerized with Docker.

Generally speaking, this project might be explored as a PoC (proof of concept) on how to amalgamate Vala REST API service backed by SQLite database, running standalone as a conventional daemon in host or VM environment, or in a containerized form as usually widely adopted nowadays.

Surely, one may consider this project to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building similar microservices, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

---

## Table of Contents

* **[Building](#building)**
* **[Running](#running)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**

## Building

The microservice might be built and run successfully under **Arch Linux** (proven). &mdash; First install the necessary dependencies (`base-devel`, `vala`, `docker`):

```
$ sudo pacman -Syu base-devel vala docker
...
```

**Build** the microservice using the **Vala compiler**:

```
$ BIN_DIR="bin"; \
  SRC_DIR="src"; \
  valac --pkg=posix --pkg=gio-2.0 --pkg=sqlite3 --pkg=libsoup-3.0 -d ${BIN_DIR} -o api-lited ${SRC_DIR}/* && \
  rm -vRf ${BIN_DIR}/${SRC_DIR}/ && \
  DB_PATH="data/db"; \
  DB_FILE="customers-api-lite.db.xz"; \
  if [ -f ${DB_PATH}/${DB_FILE} ]; then \
     unxz ${DB_PATH}/${DB_FILE}; \
  fi
...
```

Or **build** the microservice using **GNU Make** (optional, but for convenience &mdash; it covers the same **Vala compiler** build workflow under the hood):

```
$ make clean
...
$ make all  # <== Building the daemon.
...
```

## Running

**Run** the microservice using its executable directly, built previously by the Vala compiler or GNU Make's `all` target:

```
$ ./bin/api-lited; echo $?
...
```

To run the microservice as a *true* daemon, i.e. in the background, redirecting all the console output to `/dev/null`, the following form of invocation of its executable can be used:

```
$ ./bin/api-lited > /dev/null 2>&1 &
[1] <pid>
```

**Note:** This will suppress all the console output only; logging to a logfile and to the Unix syslog will remain unchanged.

The daemonized microservice then can be stopped gracefully at any time by issuing the following command:

```
$ kill -SIGTERM <pid>
$
[1]+  Done                       ./bin/api-lited > /dev/null 2>&1
```

## Consuming

The microservice should expose **six REST API endpoints** to web clients. They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

No. | Endpoint name                                      | Request method and REST URI                                   | Request body
--: | -------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------
1   | Create customer                                    | **PUT** `/v1/customers`                                       | `{"name":"{customer_name}"}`
2   | Create contact                                     | **PUT** `/v1/customers/contacts`                              | `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`
3   | List customers                                     | **GET** `/v1/customers`                                       | &ndash;
4   | Retrieve customer                                  | **GET** `/v1/customers/{customer_id}`                         | &ndash;
5   | List contacts for a given customer                 | **GET** `/v1/customers/{customer_id}/contacts`                | &ndash;
6   | List contacts of a given type for a given customer | **GET** `/v1/customers/{customer_id}/contacts/{contact_type}` | &ndash;

* The `{customer_name}` placeholder is a string &mdash; it usually means the full name given to a newly created customer.
* The `{customer_id}` placeholder is a decimal positive integer number, greater than `0`.
* The `{customer_contact}` placeholder is a string &mdash; it denotes a newly created customer contact (phone or email).
* The `{contact_type}` placeholder is a string and can take one of two possible values, case-insensitive: `phone` or `email`.

The following command-line snippets display the exact usage for these endpoints (the **cURL** utility is used as an example to access them)^:

1. **Create customer**

```
$ curl -vXPUT http://localhost:8765/v1/customers \
       -H 'content-type: application/json' \
       -d '{"name":"Jamison Palmer"}'
...
> PUT /v1/customers HTTP/1.1
...
> content-type: application/json
> Content-Length: 25
...
< HTTP/1.1 201 Created
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

2. **Create contact**

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"+12197654320"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 44
...
< HTTP/1.1 201 Created
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

Or create **email** contact:

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"jamison.palmer@example.com"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 58
...
< HTTP/1.1 201 Created
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/3
...
> GET /v1/customers/3 HTTP/1.1
...
< HTTP/1.1 200 OK
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts
...
> GET /v1/customers/3/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

6. **List contacts of a given type for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/phone
...
> GET /v1/customers/3/contacts/phone HTTP/1.1
...
< HTTP/1.1 404 Not Found
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

Or list **email** contacts:

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/email
...
> GET /v1/customers/3/contacts/email HTTP/1.1
...
< HTTP/1.1 200 OK
< Server: libsoup/3.6.6
...
< Content-Length: 0
...
```

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2026-09-06][08:20:00] [DEBUG] [Customers API Lite]
[2026-09-06][08:20:00] [DEBUG] [3cd2fe08]
[2026-09-06][08:20:00] [INFO ] Server started on port 8765
[2026-09-06][08:20:40] [DEBUG] [PUT]
[2026-09-06][08:20:40] [DEBUG] [/v1/customers]
[2026-09-06][08:20:40] [DEBUG] [1. add_customer]
[2026-09-06][08:20:40] [DEBUG] [JP]
[2026-09-06][08:20:40] [DEBUG] [3|JP]
[2026-09-06][08:20:50] [DEBUG] [PUT]
[2026-09-06][08:20:50] [DEBUG] [/v1/customers/contacts]
[2026-09-06][08:20:50] [DEBUG] [2. add_contact]
[2026-09-06][08:20:50] [DEBUG] customer_id=2
[2026-09-06][08:20:50] [DEBUG] [jp@example.com]
[2026-09-06][08:20:50] [DEBUG] [email|jp@example.com]
[2026-09-06][08:21:00] [DEBUG] [PUT]
[2026-09-06][08:21:00] [DEBUG] [/v1/customers/contacts]
[2026-09-06][08:21:00] [DEBUG] [2. add_contact]
[2026-09-06][08:21:00] [DEBUG] customer_id=2
[2026-09-06][08:21:00] [DEBUG] [jp@example.com]
[2026-09-06][08:21:00] [DEBUG] [email|jp@example.com]
[2026-09-06][08:21:10] [DEBUG] [GET]
[2026-09-06][08:21:10] [DEBUG] [/v1/customers]
[2026-09-06][08:21:10] [DEBUG] [3. list_customers]
[2026-09-06][08:21:10] [DEBUG] [1|Jammy Jellyfish]
[2026-09-06][08:21:10] [DEBUG] [2|Noble Numbat]
[2026-09-06][08:21:10] [DEBUG] [3|JP]
[2026-09-06][08:21:20] [DEBUG] [GET]
[2026-09-06][08:21:20] [DEBUG] [/v1/customers/3]
[2026-09-06][08:21:20] [DEBUG] [GET|/v1/customers/3]
[2026-09-06][08:21:30] [DEBUG] [GET]
[2026-09-06][08:21:30] [DEBUG] [/v1/customers/3/contacts]
[2026-09-06][08:21:30] [DEBUG] [GET|/v1/customers/3/contacts]
[2026-09-06][08:21:40] [DEBUG] [GET]
[2026-09-06][08:21:40] [DEBUG] [/v1/customers/3/contacts/phone]
[2026-09-06][08:21:40] [DEBUG] [GET|/v1/customers/3/contacts/phone]
[2026-09-06][08:21:50] [DEBUG] [GET]
[2026-09-06][08:21:50] [DEBUG] [/v1/customers/3/contacts/email]
[2026-09-06][08:21:50] [DEBUG] [GET|/v1/customers/3/contacts/email]
[2026-09-06][08:22:00] [INFO ] Server stopped
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Sep 06 08:20:00 <hostname> api-lited[<pid>]: [Customers API Lite]
Sep 06 08:20:00 <hostname> api-lited[<pid>]: [3cd2fe08]
Sep 06 08:20:00 <hostname> api-lited[<pid>]: Server started on port 8765
Sep 06 08:20:40 <hostname> api-lited[<pid>]: [PUT]
Sep 06 08:20:40 <hostname> api-lited[<pid>]: [/v1/customers]
Sep 06 08:20:40 <hostname> api-lited[<pid>]: [1. add_customer]
Sep 06 08:20:40 <hostname> api-lited[<pid>]: [JP]
Sep 06 08:20:40 <hostname> api-lited[<pid>]: [3|JP]
Sep 06 08:20:50 <hostname> api-lited[<pid>]: [PUT]
Sep 06 08:20:50 <hostname> api-lited[<pid>]: [/v1/customers/contacts]
Sep 06 08:20:50 <hostname> api-lited[<pid>]: [2. add_contact]
Sep 06 08:20:50 <hostname> api-lited[<pid>]: customer_id=2
Sep 06 08:20:50 <hostname> api-lited[<pid>]: [jp@example.com]
Sep 06 08:20:50 <hostname> api-lited[<pid>]: [email|jp@example.com]
Sep 06 08:21:00 <hostname> api-lited[<pid>]: [PUT]
Sep 06 08:21:00 <hostname> api-lited[<pid>]: [/v1/customers/contacts]
Sep 06 08:21:00 <hostname> api-lited[<pid>]: [2. add_contact]
Sep 06 08:21:00 <hostname> api-lited[<pid>]: customer_id=2
Sep 06 08:21:00 <hostname> api-lited[<pid>]: [jp@example.com]
Sep 06 08:21:00 <hostname> api-lited[<pid>]: [email|jp@example.com]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [GET]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [/v1/customers]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [3. list_customers]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [1|Jammy Jellyfish]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [2|Noble Numbat]
Sep 06 08:21:10 <hostname> api-lited[<pid>]: [3|JP]
Sep 06 08:21:20 <hostname> api-lited[<pid>]: [GET]
Sep 06 08:21:20 <hostname> api-lited[<pid>]: [/v1/customers/3]
Sep 06 08:21:20 <hostname> api-lited[<pid>]: [GET|/v1/customers/3]
Sep 06 08:21:30 <hostname> api-lited[<pid>]: [GET]
Sep 06 08:21:30 <hostname> api-lited[<pid>]: [/v1/customers/3/contacts]
Sep 06 08:21:30 <hostname> api-lited[<pid>]: [GET|/v1/customers/3/contacts]
Sep 06 08:21:40 <hostname> api-lited[<pid>]: [GET]
Sep 06 08:21:40 <hostname> api-lited[<pid>]: [/v1/customers/3/contacts/phone]
Sep 06 08:21:40 <hostname> api-lited[<pid>]: [GET|/v1/customers/3/contacts/phone]
Sep 06 08:21:50 <hostname> api-lited[<pid>]: [GET]
Sep 06 08:21:50 <hostname> api-lited[<pid>]: [/v1/customers/3/contacts/email]
Sep 06 08:21:50 <hostname> api-lited[<pid>]: [GET|/v1/customers/3/contacts/email]
Sep 06 08:22:00 <hostname> api-lited[<pid>]: Server stopped
```

**TBD** :cd:

---

**WIP** :dvd:
