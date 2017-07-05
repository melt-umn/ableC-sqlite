
# The directory in which to place intermediate object files
OBJECT_DIR=../bin
# The directory in which to place compiled libraries
LIB_DIR=../lib

# The base name of the library to build
LIB_NAME=sqlite
# The name of the shared library.
SHARED_LIBRARY=$(LIB_DIR)/lib$(LIB_NAME).so
# The name of the static library.
STATIC_LIBRARY=$(LIB_DIR)/lib$(LIB_NAME).a

# All C files to compile
C_FILES=$(wildcard *.c)
# All object files that should be generated
OBJECTS=$(addprefix $(OBJECT_DIR)/,$(C_FILES:.c=.o))

# Flags passed to the C compiler, e.g. to enable various compiler extensions
CFLAGS=-fpic
# Flags passed to the linker when building the shared library
LDFLAGS=-shared

all: $(SHARED_LIBRARY) $(STATIC_LIBRARY)

$(OBJECT_DIR)/%.o: %.c | $(OBJECT_DIR)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $^ -o $@

$(SHARED_LIBRARY): $(OBJECTS) | $(LIB_DIR)
	$(CC) $(LDFLAGS) $^ -o $@

$(STATIC_LIBRARY): $(OBJECTS) | $(LIB_DIR)
	$(AR) rcs $@ $^

$(OBJECT_DIR):
	mkdir -p $@

$(LIB_DIR):
	mkdir -p $@

clean:
	rm -rf *~ $(OBJECT_DIR) $(LIB_DIR)

.PHONY: all clean
