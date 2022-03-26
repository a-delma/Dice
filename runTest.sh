make
./toplevel.native temp.roll > temp.ll
llc -relocation-model=pic temp.ll > temp.s
cc -o temp.exe temp.s printbig.o
./temp.exe
# code temp.ll
