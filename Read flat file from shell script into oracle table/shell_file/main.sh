#!/bin/bash

#parameters
source /home/Other/shell_file/parameters.sh
echo "$username"
echo "$password"

#arrays
source /home/Other/shell_file/read.sh

max=${#inarray[@]}
count=3
while [ $count -lt $max ]
do
	first="${inarray[$count]}"
	second="${inarray[$count+1]}"
	third="${inarray[$count+2]}"
	count=$(( count+3 ))
#execute query
source /home/Other/shell_file/execute_query.sh
done