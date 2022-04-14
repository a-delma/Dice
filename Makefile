
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native

#############################
# 
# Scanning and Parsing Step
#

cimport : cimport.c
	cc -c cimport -DBUILD_TEST cimport.c

verbose : toplevel.ml ast.ml parser.mly scanner.mll
	ocamlyacc -v parser.mly

toplevel.native : parser.mly scanner.mll codegen.ml semant.ml closure.ml cimport.o toplevel.ml
	opam config exec -- \
	ocamlbuild -use-ocamlfind toplevel.native

############################
#
# Testing
#

TARGET="tests/*"

test: toplevel.native
	./test.sh $(TARGET).roll
	

comp_file: toplevel.native
	./toplevel.native $(TARGET).roll > $(TARGET).ll
	llc -relocation-model=pic $(TARGET).ll > $(TARGET).s
	cc -o $(TARGET).exe $(TARGET).s

simple_test: toplevel.native
	./toplevel.native -l simpleTest.roll > simpleTest.ll
	cat simpleTest.ll

#################################

clean :
	ocamlbuild -clean
	rm -f toplevel.native
	rm -f *.mli
	rm -f parser.ml
	rm -f parser.output
	rm -rf _build
	rm -f *.ll
	rm -f *.s
	rm -f *.exe
	rm -f testall.log
	rm -f cimport.o

