set serveroutput on;
create or replace procedure redefinition(
schema_name varchar2,
table_name varchar2
)
IS
sql_text varchar2(500);
l_num_errors PLS_INTEGER;
tbl_size number(8,3);
begin
    ------------------------------------------------------BEFORE SIZE-----------------------------------------------------------
    dbms_output.put_line('-------------------BEFORE SEGMENT SIZE----------------------');
    select bytes/1024/1024 into tbl_size from dba_segments where segment_name=UPPER(table_name) AND owner=UPPER(schema_name);
    dbms_output.put_line(tbl_size||'MB');
    dbms_output.new_line();

    ----------------------------------------------CREATE INTERIM TABLE----------------------------------------------------------
    sql_text := 'create table '|| schema_name||'.'||table_name || '_interim AS 
                SELECT * FROM '|| schema_name||'.'||table_name || ' where 1=2';
    EXECUTE IMMEDIATE sql_text;
    
    -----------------------------------------VERIFY REDEFINITION IN TABLE-------------------------------------------------------
    DBMS_REDEFINITION.can_redef_table(upper(schema_name), upper(table_name));
    
    -------------------------------------------------START REDEFINITION---------------------------------------------------------
    DBMS_REDEFINITION.start_redef_table(upper(schema_name), upper(table_name), upper(table_name)||'_INTERIM');
    
    -------------------------------------------COPY DEPENDENT OBJECTS-----------------------------------------------------------
    DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
    uname               => upper(schema_name),
    orig_table          => upper(table_name),
    int_table           => upper(table_name)||'_INTERIM',
    num_errors          => l_num_errors
    );
    DBMS_OUTPUT.PUT_LINE('NUM_ERRORS '||l_num_errors);
    dbms_output.new_line();
    
    --------------------------------------------------SYNCHRONIZE INTERIM TABLE-------------------------------------------------
    DBMS_REDEFINITION.SYNC_INTERIM_TABLE(upper(schema_name), upper(table_name), upper(table_name)||'_interim');
    
    ---------------------------------------------------FINISH REDEF TABLE--------------------------------------------------------
    DBMS_REDEFINITION.FINISH_REDEF_TABLE(upper(schema_name), upper(table_name), upper(table_name)||'_interim');
    
    ----------------------------------------------------DROP INTERIM TABLE------------------------------------------------------
    execute immediate 'drop table '||table_name||'_interim';
    
    -------------------------------------------------------AFTER SIZE-----------------------------------------------------------
    dbms_output.put_line('-------------------AFTER SEGMENT SIZE----------------------');
    select bytes/1024/1024 into tbl_size from dba_segments where segment_name=UPPER(table_name) AND owner=UPPER(schema_name);
    dbms_output.put_line(tbl_size||'MB');
    dbms_output.new_line();
    
    DBMS_OUTPUT.PUT_LINE('SUCCESS!!!!');

end;
/
--REDEFINITION('SCHEMA_NAME', 'TABLE_NAME');
exec redefinition('saman', 'test');
