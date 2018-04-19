create table hr_records(
emp_id number,
name    varchar2(25),
address  varchar2(50),
salary number(8,2)
);

truncate table dept_records;
truncate table hr_records;

create table dept_records(
emp_id number,
dept_id number,
name varchar2(25),
address varchar2(50),
salary number(8,2)
);

BEGIN
    INSERT INTO hr_records values (1, 'Saman', 'Naxal', 10000);
    INSERT INTO hr_records values (2, 'Sumin', 'Mangalbazar', 10000);
    INSERT INTO hr_records values (3, 'Suresh', 'Kalanki', 25000);
    INSERT INTO hr_records values (4, 'Bikram', 'Putalisadak', 15000);
    INSERT INTO hr_records values (5, 'Nitish', 'Satdobato', 10000);
    INSERT INTO hr_records values (6, 'Rowan', 'Putalisadak', 18000);
    INSERT INTO hr_records values (7, 'Rabin', 'Suryabinayak', 10000);
    INSERT INTO hr_records values (8, 'Kripesh', 'Satdobato', 50000);
    INSERT INTO hr_records values (9, 'Dikendra', 'Putalisadak', 18000);
    INSERT INTO hr_records values (10, 'Bishal', 'Anamnagar', 100000);
END;
/

select * from hr_records;

BEGIN
    INSERT INTO dept_records values (1,100, 'Saman', 'Naxal', 10000);
    INSERT INTO dept_records values (2,110, 'Sumin', 'Mangalbazar', 10000);
    INSERT INTO dept_records values (3,100, 'Suresh', 'Kalanki', 25000);
    INSERT INTO dept_records values (4,800, 'Bikram', 'Putalisadak', 15000);
    INSERT INTO dept_records values (5,110, 'Nitish', 'Satdobato', 10000);
    INSERT INTO dept_records values (6,800, 'Rowan', 'Putalisadak', 18000);
    INSERT INTO dept_records values (7,900, 'Rabin', 'Suryabinayak', 10000);
    INSERT INTO dept_records values (8,600, 'Kripesh', 'Satdobato', 50000);
    INSERT INTO dept_records values (9,800, 'Dikendra', 'Putalisadak', 18000);
    INSERT INTO dept_records values (10,400, 'Bishal', 'Anamnagar', 100000);
    --Extra two records in dept_records table
    INSERT INTO dept_records values (11,10, 'Sameer', 'Swoyambhu', 180000);
    INSERT INTO dept_records values (12,10, 'Juman', 'Swoyambhu', 100000);
END;
/

select * from dept_records;

--There are some records in dept_records but not reached to hr_records. We have to insert extra records from dept_records into 
--hr_records and update the existing salary records with 10%. Then, it is efficient to use MERGE INTO Statement.
set serveroutput on;
DECLARE
    l_start number;
BEGIN
    l_start := DBMS_UTILITY.get_time;
    
    MERGE INTO hr_records H
    USING dept_records D
    ON (H.emp_id = D.emp_id)
    WHEN MATCHED THEN 
    UPDATE
    SET H.salary = H.salary*1.1
    WHEN NOT MATCHED THEN
    INSERT (H.emp_id, H.name, H.address, H.salary) VALUES(D.emp_id, D.name, D.address, D.salary);
    
    DBMS_OUTPUT.PUT_LINE('MERGE :'||(DBMS_UTILITY.get_time - l_start)||' hsecs');
END;
/
