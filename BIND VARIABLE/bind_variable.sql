alter system flush shared_pool;
set serveroutput on;

--------------------------------------No BIND VARIABLE--------------------------------------------------------------------------
declare
    type rc is ref cursor;
    l_rc rc;
    l_dummy all_objects.object_name%type;
    l_start number default dbms_utility.get_time;
begin
    for i in 1..100
    loop
        open l_rc for 
        'select object_name from all_objects where 
        object_id= '||i;
        fetch l_rc into l_dummy;
        close l_rc;
        --dbms_output.put_line(l_dummy);
    end loop;
    
dbms_output.put_line(round((dbms_utility.get_time - l_start)/100, 2) || ' Seconds');
end;
/
------------------------------------------------------BIND VARIABLE-------------------------------------------------------------
declare
    type rc is ref cursor;
    l_rc rc;
    l_dummy all_objects.object_name%type;
    l_start number default dbms_utility.get_time;
begin
    for i in 1..100
    loop
        open l_rc for 
        'select object_name from all_objects where 
        object_id=:x' using i;
        fetch l_rc into l_dummy;
        close l_rc;
        --dbms_output.put_line(l_dummy);
    end loop;
    
dbms_output.put_line(round((dbms_utility.get_time-l_start)/100, 2) || ' Seconds');
end;
/
---------------------------------------------PL/SQL with buildin bind variable--------------------------------------------------
declare
    l_dummy all_objects.object_name%type;
    l_start number default dbms_utility.get_time;
 begin
   for i in 1 .. 100 
   loop
     begin
       select object_name
       into   l_dummy
       from   all_objects
       where  object_id = i;
     exception
       when no_data_found then null;
     end;
     --dbms_output.put_line(l_dummy);
   end loop;
   dbms_output.put_line(round((dbms_utility.get_time-l_start)/100, 2) || ' Seconds');
 end;
/
----------------------------------------------------create table emp_table---------------------------------------------------
create table emp_table(
emp_id number,
salary number(8,2)
);

--drop table emp_table;

begin
    insert into emp_table values (1, 100);
    insert into emp_table values (2, 200);
    insert into emp_table values (3, 300);
    insert into emp_table values (4, 400);
    insert into emp_table values (5, 500);
    insert into emp_table values (6, 600);
    insert into emp_table values (7, 700);
    insert into emp_table values (8, 800);
    insert into emp_table values (9, 900);
    insert into emp_table values (10, 1000);
end;
/

select * from emp_table;

--------------------------------------------Dynamic SQL without Bind Variable-------------------------------------------------
create or replace procedure double_salary(emp_id in number)
as
l_start number default dbms_utility.get_time;
begin
    execute immediate
    'update emp_table set salary = salary *2 where emp_id= ' ||emp_id;
    commit;
   dbms_output.put_line(round((dbms_utility.get_time-l_start)/100, 2) || ' Seconds');
end;
/

-------------------------------------------------Bind Variable in Dynamic SQL-------------------------------------------------
create or replace procedure double_salary(emp_id in number)
as
l_start number default dbms_utility.get_time;
begin
    execute immediate
    'update emp_table set salary = salary *2 where emp_id= :x' using emp_id;
    commit;
   dbms_output.put_line(round((dbms_utility.get_time-l_start)/100, 2) || ' Seconds');
end;
/

set serveroutput on;
exec double_salary(1);