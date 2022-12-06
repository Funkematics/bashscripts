#!/bin/bash
#a script to check harddrives in a server


letters=({a..z})
echo -e "Enter how many drives "
read drives


echo "you have $drives drives"


for (( x = 0; x < $drives; x++))
do
    echo "$x"
    smartctl -H /dev/sd${letters[x]}
done

