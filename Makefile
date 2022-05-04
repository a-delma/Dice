
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native

#############################
# 
# Scanning and Parsing Step
#

cimport : cimport.c
	cc -c cimport -DBUILD_TEST cimport.c

toplevel.native : parser.mly scanner.mll codegen.ml semant.ml closure.ml cimport.o toplevel.ml sast.ml ast.ml pass.ml lambda.ml
	opam config exec -- \
	ocamlbuild -use-ocamlfind toplevel.native

############################
#
# Testing
#

TARGET="tests/*-tests/*"
SEED=1

test: toplevel.native cimport.o
	./test.sh $(TARGET).roll
	

comp_file: toplevel.native cimport.o
	./toplevel.native $(TARGET).roll > $(TARGET).ll
	llc -relocation-model=pic $(TARGET).ll > $(TARGET).s
	cc -o $(TARGET).exe $(TARGET).s cimport.o

comp_seed: toplevel.native cimport.o
	./toplevel.native -seed $(SEED) $(TARGET).roll > $(TARGET).ll
	llc -relocation-model=pic $(TARGET).ll > $(TARGET).s
	cc -o $(TARGET).exe $(TARGET).s cimport.o

small : small.ml
	ocamlbuild -use-ocamlfind small.native
#################################

clean :
	ocamlbuild -clean
	rm -f toplevel.native
	rm -f *.mli
	rm -f parser.ml
	rm -f parser.output
	rm -rf _build
	rm -f -r */*.ll
	rm -f -r */*.s
	rm -f -r */*.exe
	rm -f testall.log
	rm -f cimport.o

clean_test:
	rm -f -r *.ll
	rm -f -r *.s
	rm -f -r *.exe
	rm -f -r */*.ll
	rm -f -r */*.s
	rm -f -r */*.exe
	rm -f testall.log
