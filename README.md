#  DICE README  

Andrew Delmastro,     
Ezra Szanton,         
Sasha Fedchin,        
Diego Griese          

## How to run the scripts provided

All the actions below have to be done from the base directory. 

1) Compile the Dice to LLVM compiler:

`make`

2) Run all tests:

`make test`

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

- `test-if.roll` - test an if statement with a boolean predicate.
This is a **positive** test.

- `test-for.roll` - tests a for loop.
This is a **positive** test.

- `test-closure.roll` - tests closures by creating a curried sum function (the first argument is being stored in the closure).
This is a **positive** test of a feature **not provided by MicroC**.

- `test-hello.roll` - test built-in putChar function and the fact that it is a first-class function.
This is a **positive** test of a feature **not provided by MicroC**.

- `test-crazy-closure.roll` - test closure with first class function, with local and formal variables.
This is a **positive** test of a feature **not provided by MicroC**.

- `test-formal-lambda.roll` - test passing a first-class function as a parameter.
This is a **positive** test of a feature **not provided by MicroC**.

- `test-import.roll` - test import feature, content is pow function.
This is a **positive** test of a feature **not provided by MicroC**.

- `test-import-recursive.roll` - test importing a file which imports another file (depends on test-import.roll).
This is a **positive** test of a feature **not provided by MicroC**.

- `test-precedence-paren.roll` - test that parentheses have highest precedence.
This is a **positive** test.

- `test-recursion2.roll` - test recursion with a global first class function (instead of using self).
This is a **positive** test of a feature **not provided by MicroC**.

- `test-printing.roll` - test standard library print functions.
This is a **positive** test.

- `test-null.roll` - test comparison of variables with null.
This is a **positive** test.

- `test-struct-declaration.roll` - test struct declarations.
This is a **positive** test.

- `test-struct-init.roll` - test for the initialization and assignment of a struct.
This is a **positive** test.

- `test-struct-access.roll` - test for extracting a field from a struct.
This is a **positive** test.

- `test-struct-nested` - test for structs that contain other structs. Tests both initialization and access of the inner fields. 
This is a **positive** test.

- `test-struct-closure` - test to ensure that structs can be stored in the the closure of function call.
This is a **positive** test.

- `test-struct-return` - test to ensure that structs are returned from functions correctly. 
This is a **positive** test.

- `test-struct-return2` - another test to ensure that structs are returned from functions correctly, with if / else. 
This is a **positive** test.

We validate all tests using the modified version of the `testall.sh` file from MicroC (which itself uses diff and checks its output against a golden standard).
