#!/bin/bash

inputfile="record.csv"
OLDIFS="$IFS"
IFS='|'
i=0
#read each row from a csv file and store it into myarray 
while read -r lines ; do
    myarray[i]=$lines
    (( i++ ))
done < "$inputfile" 
#store each field from myarray into inarray
j=0
for i in ${myarray[@]}
do
	inarray[j]=$i
	(( j++ ))
done