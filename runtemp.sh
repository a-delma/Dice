llc -relocation-model=pic temp.ll > temp.s
cc -o temp.exe temp.s cimport.o
./temp.exe