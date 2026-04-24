#
# Makefile
# =============================================================================
# Customers API Lite microservice prototype (Vala port). Version 0.0.1
# =============================================================================
# A daemon written in Vala, designed and intended to be run as a microservice,
# implementing a special Customers API prototype with a smart yet simplified
# data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

BIN_DIR = bin
SRC_DIR = src

DMON = api-lited
EXEC = $(BIN_DIR)/$(DMON)
DEPS = $(SRC_DIR)/*

DB_PATH = data/db
DB_FILE = customers-api-lite.db.xz

# Specify flags and other vars here.
VALAC  = valac
VFLAGS = --pkg=posix -d $(BIN_DIR) -o $(DMON)

RMFLAGS = -vR
UNXZ    = unxz

# Making the target (the microservice executable).
$(EXEC): $(DEPS)
	$(VALAC) $(VFLAGS) $(DEPS) && \
	$(RM) $(RMFLAGS) $(BIN_DIR)/$(SRC_DIR)/ && \
	if [ -f $(DB_PATH)/$(DB_FILE) ]; then \
	   $(UNXZ) $(DB_PATH)/$(DB_FILE); \
	fi

.PHONY: all clean

all: $(EXEC)

clean:
	$(RM) $(RMFLAGS) $(BIN_DIR)

# vim:set nu et ts=4 sw=4:
