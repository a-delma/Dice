# Dice: Probability based language

Authors: Diego Griese (diego.griese@tufts.edu), 
Ezra Szanton (ezra.szanton@tufts.edu), 
Andrew DelMastro (andrew.delmastro@tufts.edu), 
and Aleksandr Fedchin (aleksandr.fedchin@tufts.edu)

To compile the parser please run `make toplevel.native` from the root directory.
To execute the tests, please run `make test` from the root directory.
**The script assumes that you are running Ubuntu, have internet connection,
and have `ocaml`, `ocamlbuild`, `python`, and `pip` installed.**
The internet connection is used to automatically install `lit` testing engine 
via `pip install lit`. We have specifically tested on GitHub Workflow's 
`ubuntu-latest` virtual machine. We expect the tests might fail on anything that
is not Ubuntu. Upon successfully running the tests, `lit` should print the 
following:

```bash
  Passed           : 19
  Expectedly Failed: 13
```

For this assignment we have implemented the parser for all language features
that we have planned, including first class functions, record types 
(structs), and parametric polymorphism. We have built off the MicroC parser, so
other language features should be similar (with a few changes such as requiring
all type identifiers be uppercase - see the tests).