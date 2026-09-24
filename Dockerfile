#
# Dockerfile
# =============================================================================
# Customers API Lite microservice prototype (Vala port). Version 0.3.0
# =============================================================================
# A daemon written in Vala, designed and intended to be run as a microservice,
# implementing a special Customers API prototype with a smart yet simplified
# data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# === Stage 1: Install dependencies ===========================================
FROM       alpine:latest
RUN        ["apk", "add", "make"         ]
RUN        ["apk", "add", "vala"         ]
RUN        ["apk", "add", "gcc"          ]
RUN        ["apk", "add", "musl-dev"     ]
RUN        ["apk", "add", "libsoup3-dev" ]
RUN        ["apk", "add", "json-glib-dev"]

# === Stage 2: Build the microservice =========================================
USER       daemon
WORKDIR    var/tmp
COPY       src      api-lite/src/
COPY       etc      api-lite/etc/
COPY       data/db  api-lite/data/db/
COPY       Makefile api-lite/
WORKDIR    api-lite
USER       root
RUN        ["chown", "-R", "daemon:daemon", "."]
USER       daemon
RUN        ["make", "clean"]
RUN        ["make", "all"  ]

# === Stage 3: Run the microservice ===========================================
ENTRYPOINT ["bin/api-lited"]

# vim:set nu ts=4 sw=4:
