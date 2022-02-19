
# This Makefile is inspired by one provided by Stephen Edwards for his Compilers
# course at Columbia University.

all : toplevel.native 

#############################
# 
# Scanning and Parsing Step
#


toplevel.native : toplevel.ml ast.ml parser.mly scanner.mll
	ocamlbuild toplevel.native

#################################

clean :
	ocamlbuild -clean
	rm -f toplevel.native 
