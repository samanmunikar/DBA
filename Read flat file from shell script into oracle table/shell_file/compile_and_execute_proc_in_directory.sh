#!/bin/bash


create_filelist(){
        wh_schema=$1
        appid=$2
        output="$(sqlplus -S $wh_schema/oracle<<EOF
SET LINES 32000;
SET ECHO OFF NEWP 0 SPA 0 PAGES 0 FEED OFF HEAD OFF TRIMS ON TAB OFF;
SET TERMOUT OFF;
SET SERVEROUTPUT OFF;
SET DEFINE OFF;
WHENEVER SQLERROR EXIT 1
spool procedures.txt
SELECT '/home/oracle/saman/SS_ROWDMAP_PROCEDURES/'||TRIM(PROCEDURE_ID)||'_'||PROC_NAME||'.sql' FROM NVHAWKEYERULES.HR_950_SSRDM_EXEC_PROCS@NVPROCD1 WHERE APPID='$appid' ORDER BY EXEC_ORDER;
spool off;
commit;
SET DEFINE ON;
EOF
)"

#echo "$output"

}

current_location=`pwd`
ss_schema=$1
wh_schema=$2
sessionid=$3
appid=$4
plink=$5
cpdlink=$6
execflag=$7
create_filelist $wh_schema $appid
echo `sqlplus $wh_schema/oracle <<EOF
WHENEVER SQLERROR EXIT
@10011_SP_SSRDM_EXEC_INITIATOR.sql
exec SP_SSRDM_EXEC_INITIATOR('$ss_schema','$wh_schema','${sessionid:-NULL}','$appid','$plink','$cpdlink','${execflag:-Y}');
EOF` > "${current_location}/log.txt"
while read -r lines; do
        if [[ -f ${lines} ]]; then
                echo `sqlplus $wh_schema/oracle <<EOF
                        @$lines
EOF` >> "${current_location}/log.txt"
        fi
done < "${current_location}/procedures.txt"
echo `sqlplus $wh_schema/oracle <<EOF
exec SP_SSRDM_EXECUTOR('$ss_schema', '$wh_schema');
EOF` >> "${current_location}/executor_log.txt"
