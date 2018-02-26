create or replace PROCEDURE create_tbl_user
(tblsp_name varchar2,
 username varchar2,
 pswd varchar2,
 permission varchar2)
IS
sql_stat varchar2(500);
l_count varchar2(10);
sql_stat1 varchar2(500);
user_stat varchar2(500);
permission_stat varchar2(500);
BEGIN
--checking the presence of tablespace
    sql_stat := 'select count(*) from user_tablespaces where tablespace_name=upper('''||tblsp_name||''')';
    --dbms_output.put_line(sql_stat);
    execute immediate (sql_stat) into l_count;
    --dbms_output.put_line(l_count);

    IF l_count != 0 THEN 
        dbms_output.put_line('Tablespace with name '||tblsp_name||' already present');
        --dbms_output.put_line('You wanted to replace new_tblsp');
/*
        IF upper(&new_tblsp) = upper('yes') THEN
            execute immediate 'drop tablespace '||tblsp_name||' including contents and datafiles cascade constraints';
            dbms_output.put_line('creating a new tablespace with '||tblsp_name||' name');
        ELSE 
            dbms_output.put_line('Sorry '||tblsp_name||' tablespace already exist.');
            RETURN;
        END IF;
  */
    ELSE 
        --creating tablespace
        sql_stat1 := 'create tablespace '||tblsp_name||' datafile ''C:\ORACLE\ORADATA\SAMAN\'||tblsp_name||'_datafile.dbf'' size 10M autoextend on';
        execute immediate sql_stat1;
        dbms_output.put_line('Successfully created tablespace '||tblsp_name);
    END IF;
    
--creating a user
    user_stat := 'create user '||username||' identified by '||pswd||' default tablespace '||tblsp_name||' QUOTA 5M ON '||tblsp_name;
    execute immediate user_stat;
    dbms_output.put_line('Successfully user created with username '||username||' and password '||pswd||' .');
    execute immediate 'GRANT CONNECT TO '||username;
    dbms_output.put_line('Successfully granted '||username||' with CONNECT access.'); 
    execute immediate ' GRANT CREATE SESSION TO '||username;
    dbms_output.put_line('Successfully granted '||username||' with CREATE SESSION access.'); 
    
--Granting Permission
    IF (upper(permission) = upper('f')) THEN 
        dbms_output.put_line('You selected full access');
        permission_stat := 'GRANT ALL PRIVILEGES TO '||username;
        execute immediate (permission_stat);
        dbms_output.put_line('Successfully granted '||username||' with full access.'); 
    ELSIF (upper(permission) = upper('dba')) THEN
        dbms_output.put_line('You selected full and dba access');
        permission_stat := 'GRANT DBA, ALL PRIVILEGES TO '||username;
        execute immediate (permission_stat);
        dbms_output.put_line('Successfully granted '||username||' with full and dba access.');
    ELSIF (upper(permission) = upper('s')) THEN 
        dbms_output.put_line('You selected only select access');
        FOR t IN (select * from all_tables where owner=tblsp_name)
        LOOP
            permission_stat := 'GRANT SELECT ON '||t.owner||'.'||t.table_name||' TO '||username;
            dbms_output.put_line(permission_stat);    
            execute immediate (permission_stat);
        END LOOP;
        dbms_output.put_line('Successfully granted '||username||' with select access.');
     ELSIF (upper(permission) = upper('d')) THEN 
        dbms_output.put_line('You selected only select and DDL access');
        FOR t IN (select * from all_tables where owner=tblsp_name)
        LOOP
            permission_stat := 'GRANT SELECT, CREATE, ALTER, DROP, REPLACE, TRUNCATE, REFERENCES,INDEX ON '||t.owner||'.'||t.table_name||' TO '||username;
            dbms_output.put_line(permission_stat);    
            execute immediate (permission_stat);
        END LOOP;
        dbms_output.put_line('Successfully granted '||username||' with select and DDL access.');
    ELSE
        dbms_output.put_line('Incorrect access. Please select F for full access and S for Select access.');
    END IF;

commit;
END;
/
/*
-- To execute a procedure

set serveroutput on;
--create_tbl_user(tablespacename, username, passeord, permission access);
EXEC CREATE_TBL_USER('delete_mesaman','demosaman', 'demosaman','dba');

*/
