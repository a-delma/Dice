name="${1%.*}"
echo $name
if [ $# -eq 2 ]
    then 
        make comp_seed SEED=$2 TARGET=$name
    else
        make comp_file TARGET=$name
fi
./$name.exe
echo
