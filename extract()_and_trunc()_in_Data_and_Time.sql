-------------------------------------------------------Create a table----------------------------------------------------------
create table employee(
emp_id number,
name varchar2(50),
hire_date date
);

create table this_year_employees(
emp_id number,
name varchar2(50),
hire_date date
);

create table emp(
name varchar2(25),
name varchar2(50),
hire_date date
);

select * from employee;
select * from this_year_employees;

----------------------------------Get this year employee using extract(dateandtime)---------------------------------------------
set serveroutput on;
declare
sql_txt varchar2(500);
begin
    for i in (select emp_id,name,hire_date from employee)
    loop
        if (extract(year from i.hire_date) = extract(year from sysdate)) then
            sql_txt := 'insert into this_year_employees values ('||i.emp_id||', '''||i.name||''', to_date('''||i.hire_date||''', ''DD-MON-RR''))';
            --dbms_output.put_line(sql_txt);
            execute immediate sql_txt;
        end if;
    end loop;
end;
/
------------------------------------Alternatively get the begining of the year using trunc()------------------------------------
select trunc(sysdate, 'YEAR') from dual;

