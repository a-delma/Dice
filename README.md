# Dice: Probability based language

Authors: Diego Griese (diego.griese@tufts.edu), 
Ezra Szanton (ezra.szanton@tufts.edu), 
Andrew DelMastro (andrew.delmastro@tufts.edu), 
and Aleksandr Fedchin (aleksandr.fedchin@tufts.edu)

To compile and test the parser please run `make` from the root directory.
The script assumes that you have `ocaml`, `ocamlbuild`, and `python3` installed.
The script also installs `lit` testing engine using `pip install lit`, so you
need internet connection. The tests will work on Ubuntu (we have specifically 
tested on GitHub Workflow's `ubuntu-latest` virtual machine). We have not 
tried running the tests on other operation systems.

For this assignment we have implemented the parser for all language features
that we have planned, including first class functions and record types 
(structs). We were thinking of adding support for parametric polymorphism
in the future if we have time.