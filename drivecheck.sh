#!/bin/bash
#a script to check harddrives in a server


letters=({a..z})
echo -e "Enter how many drives "
read drives


echo "you have $drives drives"

if (($drives < 24))
then
    for (( x = 0; x < $drives; x++))
    do
        echo "$x"
        echo "/dev/sd${letters[x]}"
        printf "/dev/sd${letters[x]}" >> output.txt
        printf "\n--------------------------------------------------------------------------------------------------------------------VVVV\n" >> output.txt
        smartctl -H -A /dev/sd${letters[x]} >> output.txt
        printf "\n------------------------------------------------------------------------------------------------------------------------\n" >> output.txt
    done
fi

