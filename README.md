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

3) Compile a program named, for example, `filename.roll` with our compiler
   and create an executable named, for example, `filename.exe`:

`./compile.sh filename.roll`



## Description of each test case

- `fail-reassign-closure-id.roll` - detect attempted reassignment of a variable in closure. 
This is a **negative** test of a feature **not provided by MicroC**.

- `fail-not-in-scope.roll` - detect attempted access a variable that not in its scope. 
This is a **negative** test.

- `fail-no-return.roll` - detect that a lambda with a non-Void return type does not return anything. 
This is a **negative** test of a feature **not provided by MicroC**.

- `test-simple-lambda.roll` - tests compilation of a lambda expression.  
This is a **positive** test of a feature **not provided by MicroC**.

- `test-chained-assignment.roll` - tests that an assignment is an expression and can be evaluated.
This is a **positive** test.

- `test-recursion.roll` - tests a recursive lambda (reserved variable `self` can be used to make a recursive call).
This is a **positive** test of a feature **not provided by MicroC**.

- `test-for.roll` - tests a for loop.
This is a **positive** test.