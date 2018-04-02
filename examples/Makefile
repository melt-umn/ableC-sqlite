
# Path from current directory to top level ableC repository
ABLEC_BASE?=../../../ableC
# Path from current directory to top level extensions directory
EXTS_BASE?=../../../extensions

# All directories containing grammars that may be included
GRAMMAR_DIRS=$(ABLEC_BASE)/grammars $(EXTS_BASE)/ableC-sqlite/grammars

# All silver files in included grammars, to be included as dependancies
GRAMMAR_SOURCES=$(shell find $(GRAMMAR_DIRS) -name *.sv -print0 | xargs -0)
# Flags passed to silver including the appropriate directories
override SVFLAGS+=$(addprefix -I ,$(GRAMMAR_DIRS))

# Flags passed to ableC including the appropriate directories
override XCFLAGS+=-I $(EXTS_BASE)/ableC-sqlite/include
# Flags passed to Java when invoking ableC
override JAVAFLAGS+=-Xss6M

# Flags passed to the C compiler, e.g. to enable various compiler extensions
override CFLAGS+=

# All directories containing extension libraries that may be linked
LIB_DIRS=$(wildcard $(EXTS_BASE)/ableC-sqlite/lib)
# Flags passed to the linker specifying the appropriate directories
override LDFLAGS+=$(addprefix -L,$(LIB_DIRS))
# Flags passed to the linker specifying libraries to link
LDLIBS=-Wl,-Bstatic -lsqlite -Wl,-Bdynamic -lpthread -ldl

all: ableC.jar examples

# All extension library targets
libs: $(EXTS_BASE)/ableC-sqlite/src
	cd $(EXTS_BASE)/ableC-sqlite/src && $(MAKE)

ableC.jar: $(GRAMMAR_SOURCES)
	touch artifact/Artifact.sv
	silver -o $@ -I $(ABLEC_BASE) \
		     -I $(EXTS_BASE)/ableC-sqlite/grammars \
		     $(SVFLAGS) artifact

examples: join_person_details.out populate_tables_random.out populate_tables.out print_person_table.out

join_person_details.c: join_person_details.xc ableC.jar
	java $(JAVAFLAGS) -jar ableC.jar join_person_details.xc $(XCFLAGS)

populate_tables_random.c: populate_tables_random.xc ableC.jar
	java $(JAVAFLAGS) -jar ableC.jar populate_tables_random.xc $(XCFLAGS)

populate_tables.c: populate_tables.xc ableC.jar
	java $(JAVAFLAGS) -jar ableC.jar populate_tables.xc $(XCFLAGS)

print_person_table.c: print_person_table.xc ableC.jar
	java $(JAVAFLAGS) -jar ableC.jar print_person_table.xc $(XCFLAGS)

join_person_details.out: join_person_details.o $(SRC_SOURCES) | libs
	$(CC) $(LDFLAGS) join_person_details.o $(LOADLIBES) $(LDLIBS) -o $@

populate_tables_random.out: populate_tables_random.o $(SRC_SOURCES) | libs
	$(CC) $(LDFLAGS) populate_tables_random.o $(LOADLIBES) $(LDLIBS) -o $@

populate_tables.out: populate_tables.o $(SRC_SOURCES) | libs
	$(CC) $(LDFLAGS) populate_tables.o $(LOADLIBES) $(LDLIBS) -o $@

print_person_table.out: print_person_table.o $(SRC_SOURCES) | libs
	$(CC) $(LDFLAGS) print_person_table.o $(LOADLIBES) $(LDLIBS) -o $@

%.test: %.out
	@echo "Running $<..."
	@./$< || echo "(exit $$?)"
	touch $@

clean:
	rm -f *~ *.i *.c *.o *.out *.test *.jar *.copperdump.html build.xml

.PHONY: all libs clean
