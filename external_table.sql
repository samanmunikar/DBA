---------------------------------------create a directory containing flat file--------------------------------------------------
create or replace directory external_table as 'C:\Oracle\External' ;
select * from dba_directories;

-------------------------------------------Drop external table if any-----------------------------------------------------------
drop table ext_table;

-------------------------------------------Create an external Table-------------------------------------------------------------
create table ext_table(
    id number,
    name varchar2(25),
    address varchar2(50)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY external_table
    Access parameters (
    RECORDS DELIMITED BY NEWLINE
    BADFILE bdump:'read_alert_%a_%p.bad'
    LOGFILE bdump:'read_alert_%a_%p.log'
    SKIP 1
    FIELDS TERMINATED BY '|'
    )
    LOCATION ('sample_file.csv')
)
PARALLEL
REJECT LIMIT UNLIMITED;

---------------------------------------------Select from external table---------------------------------------------------------
select * from ext_table;