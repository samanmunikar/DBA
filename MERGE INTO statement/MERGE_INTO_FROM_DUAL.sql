create table emp(
emp_id number,
emp_name    varchar2(25),
emp_address  varchar2(50),
emp_salary number(8,2)
);

drop table emp;

BEGIN
    INSERT INTO emp values (1, 'Saman', 'Naxal', 10000);
    INSERT INTO emp values (2, 'Prajeeta', 'Baneshwor', 15000);
    INSERT INTO emp values (3, 'Sumin', 'Mangalbazar', 10000);
    INSERT INTO emp values (4, 'Suresh', 'Kalanki', 25000);
    INSERT INTO emp values (5, 'Bikram', 'Putalisadak', 15000);
    INSERT INTO emp values (6, 'Nitish', 'Satdobato', 10000);
    INSERT INTO emp values (7, 'Rowan', 'Putalisadak', 18000);
    INSERT INTO emp values (8, 'Rabin', 'Suryabinayak', 10000);
    INSERT INTO emp values (9, 'Kripesh', 'Satdobato', 50000);
    INSERT INTO emp values (10, 'Dikendra', 'Putalisadak', 18000);
    INSERT INTO emp values (11, 'Bishal', 'Anamnagar', 100000);
END;
/

SELECT * FROM EMP;

MERGE INTO emp e
          USING (
            SELECT	1	AS EMPNO,	'Saman'	AS ENAME,	'Naxal'	AS ADDR,	10000	AS SAL	FROM DUAL	UNION ALL
            SELECT	2	AS EMPNO,	'Prajeeta'	AS ENAME,	'Baneshwor'	AS ADDR,	15000	AS SAL	FROM DUAL	UNION ALL
            SELECT	3	AS EMPNO,	'Sumin'	AS ENAME,	'Mangalbazar'	AS ADDR,	10000	AS SAL	FROM DUAL	UNION ALL
            SELECT	4	AS EMPNO,	'Suresh'	AS ENAME,	'Kalanki'	AS ADDR,	25000	AS SAL	FROM DUAL	UNION ALL
            SELECT	5	AS EMPNO,	'Bikram'	AS ENAME,	'Putalisadak'	AS ADDR,	15000	AS SAL	FROM DUAL	UNION ALL
            SELECT	6	AS EMPNO,	'Nitish'	AS ENAME,	'Satdobato'	AS ADDR,	10000	AS SAL	FROM DUAL	UNION ALL
            SELECT	7	AS EMPNO,	'Rowan'	AS ENAME,	'Putalisadak'	AS ADDR,	18000	AS SAL	FROM DUAL	UNION ALL
            SELECT	8	AS EMPNO,	'Rabin'	AS ENAME,	'Suryabinayak'	AS ADDR,	10000	AS SAL	FROM DUAL	UNION ALL
            SELECT	9	AS EMPNO,	'Kripesh'	AS ENAME,	'Satdobato'	AS ADDR,	50000	AS SAL	FROM DUAL	UNION ALL
            SELECT	10	AS EMPNO,	'Dikendra'	AS ENAME,	'Putalisadak'	AS ADDR,	18000	AS SAL	FROM DUAL	UNION ALL
            SELECT	11	AS EMPNO,	'Bishal'	AS ENAME,	'Anamnagar'	AS ADDR,	100000	AS SAL	FROM DUAL	UNION ALL
            SELECT	12	AS EMPNO,	'Sameer'	AS ENAME,	'Swoyambhu'	AS ADDR,	12000	AS SAL	FROM DUAL	UNION ALL
            SELECT	13	AS EMPNO,	'Juman'	AS ENAME,	'Swoyambhu'	AS ADDR,	11000	AS SAL	FROM DUAL	          
          ) 
          ON (e.emp_id = EMPNO)
          WHEN MATCHED THEN
          UPDATE 
          SET e.emp_salary = SAL*1.1
          DELETE WHERE SAL > 15000
          WHEN NOT MATCHED THEN
          INSERT (e.emp_id, e.emp_name, e.emp_address, e.emp_salary)
          VALUES (EMPNO, TO_CHAR(ENAME), TO_CHAR(ADDR), SAL);
