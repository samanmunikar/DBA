create or replace procedure reset_all_objects_from_schema(schema_name in varchar2)
as
sql_text varchar2(500);
begin
-------------------------------------------------Disable all Constraints--------------------------------------------------------    
    ----------------------------------Disable all constraints except primary key first------------------------------------------
    for i in (select constraint_name, table_name, status from all_constraints where owner=upper(schema_name) and constraint_type not in ('P') 
    and constraint_name not like 'BIN$%'  and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' disable constraint '||i.constraint_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;
    
    ------------------------------------------------Disable primary key---------------------------------------------------
    for i in (select constraint_name, table_name, status from all_constraints where owner=upper(schema_name) and constraint_type in ('P')
    and constraint_name not like 'BIN$%' and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' disable constraint '||i.constraint_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;
    
--------------------------------------------------Disable all Triggers----------------------------------------------------------    
    for i in (select table_name from all_tables where owner=upper(schema_name)
    and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' disable all triggers';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;

-------------------------------------------------Truncate all the tables--------------------------------------------------------
    for i in (select table_name from all_tables where owner=upper(schema_name)
    and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'truncate table '||schema_name||'.'||i.table_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;

------------------------------------------------Reset all the sequences---------------------------------------------------------
    for i in (select sequence_name,min_value,increment_by,max_value,cache_size,cycle_flag,order_flag from all_sequences 
    where sequence_owner=upper(schema_name))
    loop
        --------------------------------Drop sequence---------------------------
        sql_text := 'drop sequence '||schema_name||'.'||i.sequence_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
        
        if i.cache_size = 0 -- for nocached sequence
         then 
                if i.cycle_flag = 'Y' then 
                        if i.order_flag = 'Y' then
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' nocache '||
                                ' cycle'||        -- for nocached cycle sequence
                                ' order';         -- for order sequence    
                            execute immediate sql_text;
                        else
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' nocache '||
                                ' cycle'||        -- for nocached cycle sequence
                                ' noorder';  -- for noorder sequence    
                            execute immediate sql_text;
                        end if;
                    else
                        if i.order_flag = 'Y' then
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' nocache '||
                                ' nocycle'||      -- for nocached nocycle sequence
                                ' order';          -- for order sequence
                            execute immediate sql_text;
                        else
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' nocache '||
                                ' nocycle'||      -- for nocached nocycle sequence
                                ' noorder';       -- for no order sequence
                            execute immediate sql_text;
                        end if;
                    end if;
         else  --for cached sequence
                if i.cycle_flag = 'Y' then 
                        if i.order_flag = 'Y' then
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' cache '||i.cache_size||
                                ' cycle'||        -- for nocached cycle sequence
                                ' order';  -- for order sequence    
                            execute immediate sql_text;
                        else
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' cache '||i.cache_size||
                                ' cycle'||        -- for nocached cycle sequence
                                ' noorder';  -- for noorder sequence    
                            execute immediate sql_text;
                        end if;
                    else
                        if i.order_flag = 'Y' then
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' cache '||i.cache_size||
                                ' nocycle'||      -- for nocached nocycle sequence
                                ' order';          -- for order sequence
                            execute immediate sql_text;
                        else
                            sql_text := 'create sequence '||schema_name||'.'||i.sequence_name||' 
                                minvalue '||i.min_value||
                                ' maxvalue '||i.max_value||
                                ' increment by '||i.increment_by||
                                ' cache '||i.cache_size||
                                ' nocycle'||      -- for nocached nocycle sequence
                                ' noorder';       -- for no order sequence
                            execute immediate sql_text;
                        end if;
                    end if;
        end if;
    end loop;
    
----------------------------------------------------Enable all constraints------------------------------------------------------
    -----------------------------------------------Enable first primary key constraints-----------------------------------------
    for i in (select constraint_name, table_name, status from all_constraints where owner=upper(schema_name) and constraint_type in ('P') 
    and constraint_name not like 'BIN$%' and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' enable constraint '||i.constraint_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;
    
    ----------------------------------------------------------Enable other keys-------------------------------------------------
    for i in (select constraint_name, table_name, status from all_constraints where owner=upper(schema_name) and constraint_type not in ('P') 
    and constraint_name not like 'BIN$%' and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' enable constraint '||i.constraint_name||'';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;
----------------------------------------------------Enable all triggers---------------------------------------------------------
    for i in (select table_name from all_tables where owner=upper(schema_name) and table_name not like 'BIN$%'
    and table_name not in (select table_name from all_external_tables where owner=upper(schema_name)))
    loop
        sql_text := 'alter table '||schema_name||'.'||i.table_name||' enable all triggers';
        --dbms_output.put_line(sql_text);
        execute immediate sql_text;
    end loop;
    
        dbms_output.put_line('Success!!!!!!!!!!!!');
        
end;
/

set serveroutput on;
-- reset_all_objects_from_schema('schema_name'); 
exec reset_all_objects_from_schema('saman');
