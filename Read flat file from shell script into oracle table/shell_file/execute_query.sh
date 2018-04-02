#!/bin/bash
source /home/Other/shell_file/parameters.sh
echo `sqlplus $username/$password@$server:$port/$service<<EOF
insert into records values($first, '$second', '$third', to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'), '${filename%.*}');
$query
EOF`