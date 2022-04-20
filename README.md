#  DICE HELLO WORLD README  

Andrew Delmastro,     
Ezra Szanton,         
Sasha Fedchin,        
Diego Griese          

## How to run the scripts provided

All the actions below have to be done from the base directory. 

1) Compile the Dice to LLVM compiler:

`make`

2) Run all tests:

`./test.sh tests/*`

Note that you can also test a specific file by passing it as argument to `./test.sh`
The test file should be in the `tests` directory.
The gold standard file has same name except that its extension is `.out` or `.err`
depending on whether the program is expected to successfully terminate or raise an error resp.

3) Compile a program named, for example, `filename.roll` with our compiler:

`./compile.sh filename.roll`


## Description of each test case

- `tests/test-simple-lambda.roll` - test a lambda expression.  
  This is a **positive** test of a feature **not provided by MicroC**