----------------------------------------------show audit parameter----------------------------------------------------
show parameter audit;
---------------------------alter the audit parameter to db extended which captures the sql command  also -------------

alter system set audit_trail=db,extended scope=spfile;

---------------------------------after this , you have to restart the database instance -------------------------------

----------------------------enable auditing on a table-----------------------------------------------------------------

audit all on DEMO_TABLE by ACCESS; --CREATE AUDIT FOR WHATEVER CHANGES DONE ON TABLE 'DEMO_TABLE'

--------------------------------------create table that stores the audit information-----------------------------------

create  table audit_users_table (
user_id varchar2(30),
user_host varchar2(30),
object_creator varchar2(30),
object_name varchar2(50),
created_timestamp timestamp(6),
new_id varchar2(50),
sql_text varchar2(2000)
)

select * from log_ddl.audit_users_table;

---------------------------create procedure that updates inserts and updates the audit information table --------------------

CREATE OR REPLACE
 procedure  update_audit_table
 as
 begin
 
  insert into audit_users_table(user_id,user_host,object_creator,object_name,created_timestamp,new_id,sql_text) 
  select USERID, USERHOST,OBJ$CREATOR,OBJ$NAME,
  NTIMESTAMP#,sessionid||entryid,SQLTEXT FROM sys.aud$ WHERE OBJ$NAME NOT LIKE '%$%' AND USERID not in ('SYS','SYSMAN','SYSTEM')and
  OBJ$CREATOR NOT IN('SYS','SYSTEM','APEX_030200','MDSYS','XDB')AND OBJ$NAME NOT IN ('SYSTEM')
  AND sessionid||entryid not in(
  select new_id from audit_users_table);
 end;
/

SELECT * FROM AUDIT_USERS_TABLE;

EXECUTE UPDATE_AUDIT_TABLE;


--------------------------------------------------CREATE A DIRECTORY------------------------------------------------------------

CREATE OR REPLACE DIRECTORY USER_DIR AS 'C:/Oracle/user_dir';

--------------------------------------------------CREATE A CSV OUTPUT FILE------------------------------------------------------
 
CREATE OR REPLACE PROCEDURE AUDIT_CSV AS
  CURSOR c_data IS
    SELECT user_id, user_host,object_creator,object_name,sql_text
    FROM   AUDIT_USERS_TABLE
    where to_char(created_timestamp,'YYYYMMDD')=to_char(sysdate,'YYYYMMDD');
  
  v_file  UTL_FILE.FILE_TYPE;
  FILE_NAME VARCHAR2(30) := 'AUDIT_'||TO_CHAR(SYSDATE,'YYYYMMDD');
 
BEGIN
 v_file := UTL_FILE.FOPEN('USER_DIR',
                         FILE_NAME||'.csv',
                          'A',
                         32767);
  FOR cur_rec IN c_data LOOP
    UTL_FILE.PUT_LINE(v_file,
                      cur_rec.user_id    || ',' ||
                      cur_rec.user_host    || ',' ||
                      cur_rec.object_creator    || ',' ||
                      cur_rec.object_name    || ',' ||
                      cur_rec.sql_text);
  END LOOP;
  UTL_FILE.FCLOSE(v_file);
  
EXCEPTION
  WHEN OTHERS THEN
    UTL_FILE.FCLOSE(v_file);
    RAISE;  
END;
/

EXECUTE audit_csv;
    
-----------------------------------create a job that runs the procedure frequently---------------------------------------------

------------DAILY INSERT THE AUDIT OF SYS.AUD$ TABLE INTO OUR CUSTOM TABLE 'AUDIT_USERS_TABLE' 
begin

    DBMS_SCHEDULER.CREATE_JOB (
         job_name           => 'UPDATE_AUDIT_TABLE_JOB_DAILY',
         job_type           => 'STORED_PROCEDURE',
         job_action         => 'UPDATE_AUDIT_TABLE',
         start_date         => current_timestamp,
         repeat_interval    => 'FREQ=DAILY',
         enabled            => true);

end;
/

------------------DAILY CREATE THE CSV FILE OF THE CONTENT OF 'AUDIT_USERS_TABLE'
begin

    DBMS_SCHEDULER.CREATE_JOB (
         job_name           => 'AUDIT_CSV_JOB_DAILY',
         job_type           => 'STORED_PROCEDURE',
         job_action         => 'AUDIT_CSV',
         start_date         => current_timestamp,
         repeat_interval    => 'FREQ=DAILY',
         enabled            => true);

end;
/

SELECT * FROM ALL_SCHEDULER_JOBS;

-------------------------------------------drop job (if the job is no longer needed )-------------------------------------------

begin
DBMS_SCHEDULER.DROP_JOB('SUNDAY_FULLBACKUP');
end;
/
 
 commit;