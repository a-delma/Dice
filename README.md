#  DICE HELLO WORLD README  

Andrew Delmastro,     
Ezra Szanton,         
Sasha Fedchin,        
Diego Griese          

## How to run the scripts provided

All the actions below have to be done from the base directory. 

1) Compile the Dice to LLVM compiler:

`make`

2) Compile a program named, for example, `filename.roll` with our compiler:

`./compile.sh filename.roll`

3) Test a specific file against the gold standard:

`./test.sh tests/test-hello.roll`

The test file should be in the `tests` directory.
The gold standard file has same name except that its extension is `.out`


## Description of our test case -

The Dice program in `tests/test-hello.roll` repeatedly calls the built-in `putchar` function to print the string `HELLO WORLD!`

We validate that the compiled llvm code prints `HELLO WORLD!` using the modified version of the `testall.sh` file from MicroC (which itself uses diff and checks its output).

While putchar is a built-in function imported from C, we generate code for function calls in a manner that is agnostic to the function being called and supports first-class functions using function pointers and closures. Since we have not implemented code generation of lambda expressions, we can only test function calls on this built-in funciton. 
