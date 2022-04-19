llc -relocation-model=pic example.ll > example.s
cc -o example.exe example.s cimport.o
./example.exe