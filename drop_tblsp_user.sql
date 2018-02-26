CREATE OR REPLACE PROCEDURE drop_tbl_user
(username varchar2,
 tblsp_name varchar2)
IS
cur_sid number;
demo varchar2(500);
usr_lck_sql varchar2(500);
drp_usr_sql varchar2(500);
drp_datafile_sql varchar2(500);
BEGIN
    --my current session
    execute immediate 'select sid from v$mystat where rownum < 2' into cur_sid;
    dbms_output.put_line(cur_sid);
    
    --kill session
    for sess in (select * from v$session where osuser not in(upper('system')) and sid not in (cur_sid))
    loop
        execute immediate 'alter system kill session '''||sess.sid||', '||sess.serial#||''' immediate';
    end loop;
    dbms_output.put_line('Successfully killed all session');
    
    --lock account
    usr_lck_sql := 'alter user '||username||' account lock';
    execute immediate usr_lck_sql;
    dbms_output.put_line('Succesfully locked '||username);
    
    --drop user
    drp_usr_sql := 'drop user '||username||' cascade';
    execute immediate drp_usr_sql;
    dbms_output.put_line('Succesfully dropped '||username);
    
    --drop tablespace
    drp_datafile_sql := 'drop tablespace '||tblsp_name||' including contents and datafiles cascade constraints';
    --dbms_output.put_line(drp_datafile_sql);
    execute immediate drp_datafile_sql;
    dbms_output.put_line('Successfully dropped '||tblsp_name||' tablespace');
    
    --commit
    commit;
END;
/

/*

--execute procedure
set serveroutput on;
execute drop_tbl_user('demosaman', 'delete_mesaman');

*/