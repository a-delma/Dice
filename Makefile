
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native test 

#############################
# 
# Scanning and Parsing Step
#

verbose : toplevel.ml ast.ml parser.mly scanner.mll
	ocamlyacc -v parser.mly

toplevel.native : toplevel.ml ast.ml parser.mly scanner.mll
	          ocamlbuild toplevel.native

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
