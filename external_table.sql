create or replace directory external_table as 'C:\Oracle\External' ;
select * from dba_directories;

drop table ext_table;
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
NOBADFILE
NOLOGFILE
NODISCARDFILE
SKIP 1
FIELDS TERMINATED BY '|'
)
LOCATION (EXTERNAL_TABLE :'sample_file.csv')
)
REJECT LIMIT UNLIMITED;

select * from ext_table;