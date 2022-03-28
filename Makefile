
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native

#############################
# 
# Scanning and Parsing Step
#

verbose : toplevel.ml ast.ml parser.mly scanner.mll
	ocamlyacc -v parser.mly

toplevel.native : parser.mly scanner.mll codegen.ml semant.ml
	opam config exec -- \
	ocamlbuild -use-ocamlfind toplevel.native

############################
#
# Testing
#

TARGET="hello"

test :  comp_file
	./$(TARGET).exe > $(TARGET).out
	diff $(TARGET).out $(TARGET).expect

comp_file: toplevel.native
	./toplevel.native $(TARGET).roll > $(TARGET).ll
	llc -relocation-model=pic $(TARGET).ll > $(TARGET).s
	cc -o $(TARGET).exe $(TARGET).s


#################################

clean :
	ocamlbuild -clean
	rm -f toplevel.native
	rm -f *.mli
	rm -f parser.ml
	rm -f parser.output
	rm -rf _build
	rm -f hello.ll
	rm -f hello.s
	rm -f hello.exe
