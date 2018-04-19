-----------------------------------------------------Create table---------------------------------------------------------------

CREATE TABLE employee (
    emp_id      NUMBER,
    name        VARCHAR2(50),
    hire_date   DATE
);

CREATE TABLE this_year_employees (
    emp_id      NUMBER,
    name        VARCHAR2(50),
    hire_date   DATE
);

CREATE TABLE employees
    AS
        SELECT
            *
        FROM
            hr.employees
        WHERE
            employee_id < 150;
----------------------------------------------------Describe employees table----------------------------------------------------

DESC employees;

--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------Cursor----------------------------------------------------------------
----------------------------------------------------Cursor FOR LOOP-------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    sql_txt     VARCHAR2(500);
    sql_start   NUMBER;
BEGIN
    sql_start := dbms_utility.get_time;
    FOR i IN (
        SELECT
            employee_id,
            first_name,
            hire_date
        FROM
            employees
    )--Cursor FOR LOOP
     LOOP
        IF
            ( extract ( YEAR FROM i.hire_date ) = extract ( YEAR FROM SYSDATE ) )
        THEN
            sql_txt := 'insert into this_year_employees values ('
                       || i.employee_id
                       || ', '''
                       || i.first_name
                       || ''', to_date('''
                       || i.hire_date
                       || ''', ''DD-MON-RR''))';
            --dbms_output.put_line(sql_txt);

            EXECUTE IMMEDIATE sql_txt;
        END IF;
    END LOOP;

    dbms_output.put_line('Cursor For Loop: '
                           || (dbms_utility.get_time - sql_start)
                           || ' hsecs');

END;
/
--------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------Explicit Cursor--------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    CURSOR employees_cur IS SELECT  --Declare Cursor
        employee_id,
        first_name,
        last_name,
        hire_date,
        salary
                            FROM
        employees;

    l_emp_var   employees_cur%rowtype;
    l_start     NUMBER;
BEGIN
    l_start := dbms_utility.get_time;
    OPEN employees_cur; --Open Cursor
    LOOP
        FETCH employees_cur INTO l_emp_var; --Fetch the records from cursor
        EXIT WHEN employees_cur%notfound;
        dbms_output.put_line('Hello, '
                               || l_emp_var.first_name
                               || ' '
                               || l_emp_var.last_name
                               || ', Your employee id is '
                               || l_emp_var.employee_id
                               || '. You have joined our company since '
                               || l_emp_var.hire_date
                               || ' with a salary '
                               || l_emp_var.salary
                               || '.');

    END LOOP;

    CLOSE employees_cur;    --Close Cursor
    dbms_output.put_line('Explicit Cursor: '
                           || (dbms_utility.get_time - l_start)
                           || ' hsecs');

END;
/

DROP TABLE employee;

CREATE TABLE employee (
    emp_id      NUMBER,
    name        VARCHAR2(50),
    hire_date   DATE
);

--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Explicit Cursor FOR LOOP---------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
    total             NUMBER;
    CURSOR employee_cur --Declare cursor
     IS SELECT
        name
                           FROM
        employee;

    l_employee_name   employee.name%TYPE;
    l_start           NUMBER;
BEGIN
    l_start := dbms_utility.get_time;
    OPEN employee_cur; --Open a cursor
    SELECT  --Select into to get one value into a variable
        COUNT(*)
    INTO total
    FROM
        employee;

    FOR i IN 1..total LOOP
        FETCH employee_cur INTO l_employee_name; --Fetch the values from cursor into a variable
        dbms_output.put_line(l_employee_name);
    END LOOP;
    --dbms_output.put_line(total);

    CLOSE employee_cur; --Close a cursor
    dbms_output.put_line('Explicit Cursor FOR LOOP: '
                           || (dbms_utility.get_time - l_start)
                           || ' hsecs');

END;
/
--------------------------------------------------------------------------------------------------------------------------------
----------------------------cursor FOR loop to display the last names of all employees in department 1-------------------------- 
--------------------------------------------------------------------------------------------------------------------------------
BEGIN
    FOR employee_rec IN (
        SELECT
            *
        FROM
            employee
        WHERE
            department_id = 1
    ) LOOP
        dbms_output.put_line(employee_rec.last_name);
    END LOOP;
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Cursor FOR loop explicitly declared---------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------------------------
DECLARE
    CURSOR employees_in_1_cur IS SELECT
        *
                                 FROM
        employee
                                 WHERE
        department_id = 1;

BEGIN
    FOR employee_rec IN employees_in_1_cur LOOP
        dbms_output.put_line(employee_rec.last_name);
    END LOOP;
END;
/
--------------------------------------------------------------------------------------------------------------------------------
----------------------------------------Bulk Collect when we know the upper limit varray type-----------------------------------
--------------------------------------------------------------------------------------------------------------------------------
DROP TABLE training_months;

CREATE TABLE training_months (
    month_name   VARCHAR2(100)
)

BEGIN
   /* No trainings in the depths of summer and winter... */
    INSERT INTO training_months VALUES ( 'March' );

    INSERT INTO training_months VALUES ( 'April' );

    INSERT INTO training_months VALUES ( 'May' );

    INSERT INTO training_months VALUES ( 'June' );

    INSERT INTO training_months VALUES ( 'September' );

    INSERT INTO training_months VALUES ( 'October' );

    INSERT INTO training_months VALUES ( 'November' );

    COMMIT;
END;
/

SET SERVEROUTPUT ON;

DECLARE
    TYPE at_most_twelve_t IS
        VARRAY ( 12 ) OF VARCHAR2(100);
    l_month   at_most_twelve_t;
    l_start   NUMBER;
BEGIN
    l_start := dbms_utility.get_time;
    SELECT
        month_name
    BULK COLLECT
    INTO l_month
    FROM
        training_months;

    FOR indx IN 1..l_month.count LOOP
        dbms_output.put_line(l_month(indx) );
    END LOOP;

    dbms_output.put_line('BULK COLLECT WITH VARRAY: '
                           || (dbms_utility.get_time - l_start)
                           || ' hsecs');

END;
/
--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------BULK COLLECT WITH LIMIT CLAUSE---------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE bulk_with_limit (
    dept_id_in   IN employees.department_id%TYPE,
    limit_in     IN PLS_INTEGER DEFAULT 100
) IS

    CURSOR employees_cur IS SELECT
        *
                            FROM
        employees
                            WHERE
        department_id = dept_id_in;

    TYPE employee_tt IS
        TABLE OF employees_cur%rowtype;
    l_employees   employee_tt;
BEGIN
    OPEN employees_cur;
    LOOP
        FETCH employees_cur BULK COLLECT INTO l_employees LIMIT limit_in;
        FOR indx IN 1..l_employees.count LOOP
            dbms_output.put_line(l_employees(indx).first_name);
        END LOOP;

        EXIT WHEN employees_cur%notfound;
    END LOOP;

    CLOSE employees_cur;
END;
/

SET SERVEROUTPUT ON;

EXEC bulk_with_limit(100,1000);