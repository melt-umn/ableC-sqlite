
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

# All directories contining header files that may be included
INCLUDE_DIRS=../include
# All header files that may be included, to be included as dependencies
INCLUDE_SOURCES=$(foreach dir,$(INCLUDE_DIRS),$(wildcard $(dir)/*.h))
# Flags passed to the C preprocessor including the appropriate directories
override CPPFLAGS+=$(addprefix -I,$(INCLUDE_DIRS))

# Flags passed to the C compiler, e.g. to enable various compiler extensions
override CFLAGS+=-fpic
# Flags passed to the linker when building the shared library
override LDFLAGS+=-shared

all: $(SHARED_LIBRARY) $(STATIC_LIBRARY)

$(OBJECT_DIR)/%.o: %.c $(INCLUDE_SOURCES) | $(OBJECT_DIR)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

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
