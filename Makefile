
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native printbig

#############################
# 
# Scanning and Parsing Step
#

verbose : toplevel.ml ast.ml parser.mly scanner.mll
	ocamlyacc -v parser.mly

printbig : printbig.c
	cc -o printbig.o -DBUILD_TEST printbig.c

toplevel.native : parser.mly scanner.mll codegen.ml semant.ml microc.ml
	opam config exec -- \
	ocamlbuild -use-ocamlfind toplevel.native


# toplevel.native : toplevel.ml ast.ml sast.ml semant.ml parser.mly  \
# 					scanner.mll codegen.ml
# 	          ocamlbuild toplevel.native

############################
#
# Testing
#

test :  toplevel.native
	pip3 install lit
	lit tests

#################################

clean :
	ocamlbuild -clean
	rm -f toplevel.native
	rm *.mli
	rm parser.ml
	rm parser.output
	rm printbig
