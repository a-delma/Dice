name="${1%.*}"
make
./toplevel.native $name.roll | llc -relocation-model=pic > $name.s
cc -o $name.exe $name.s cimport.o
$name.exe
echo
rm $name.s
rm $name.exe
