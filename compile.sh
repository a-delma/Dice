name="${1%.*}"
echo $name
make comp_file TARGET=$name
./$name.exe
echo
