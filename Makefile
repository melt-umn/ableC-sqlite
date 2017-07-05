# To build and/or test the extension, run one of the following commands:
#
# `make`: build the artifact and run all tests
#
# `make build`: build the artifact
#
# `make examples`: compile the example uses of the extension
#
# `make analyses`: run the modular analyses that provide strong composability
#                  guarantees
#
# `make mda`: run the modular determinism analysis that ensures that the
#             composed specification of the lexical and context-free syntax is
#             free of ambiguities
#
# `make mwda`: run the modular well-definedness analysis that ensures that the
#              composed attribute grammar is well-defined and thus the semantic
#              analysis and code generation phases will complete successfully
#
# `make test`: run the extension's test suite
#
# note: the modular analyses and tests will not be rerun if no changes to the
#       source have been made. To force the tests to run, use make's -B option,
#       e.g. `make -B analyses`, `make -B mwda`, etc.
#

all: examples analyses test

build:
	@cd examples && make ableC.jar

examples:
	@cd examples && make examples

analyses: mda mwda

mda:
	@cd modular_analyses && make mda

mwda:
	@cd modular_analyses && make mwda

test:
	# the -j option runs the tests in parallel
	@cd test && make -j

clean:
	rm -f *~ 
	@cd examples && make clean
	@cd modular_analyses && make clean
	@cd test && make clean

.PHONY: all examples analyses mda mwda test clean
.NOTPARALLEL: # Avoid running multiple Silver builds in parallel

