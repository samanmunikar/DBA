set serveroutput on;
create directory UTL_FILE_DIR as 'C:\Oracle\directory\UTL_FILE';

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


 DECLARE
    F UTL_FILE.FILE_TYPE;
    V_LINE VARCHAR2 (1000);
    V_EMPNO NUMBER;
    V_ENAME VARCHAR2(25);
    V_ADDR VARCHAR2(50);
    V_SAL NUMBER(8,2); 
 BEGIN
    F := UTL_FILE.FOPEN ('UTL_FILE_DIR', 'EMP.CSV', 'R');
  IF UTL_FILE.IS_OPEN(F) THEN
      LOOP
      BEGIN
          UTL_FILE.GET_LINE(F, V_LINE, 1000);
          IF V_LINE IS NULL THEN
            EXIT;
          END IF;
          V_EMPNO := REGEXP_SUBSTR(V_LINE, '[^,]+', 1, 1);
          V_ENAME := REGEXP_SUBSTR(V_LINE, '[^,]+', 1, 2);
          V_ADDR := REGEXP_SUBSTR(V_LINE, '[^,]+', 1, 3);
          V_SAL := REGEXP_SUBSTR(V_LINE, '[^,]+', 1, 4);
          --dbms_output.put_line(V_EMPNO||' '||to_char(V_ENAME)||' '||to_char(V_ADDR)||' '||V_SAL);
         
          MERGE INTO emp e
          USING (SELECT V_EMPNO as eno, V_ENAME as ename, V_ADDR as eaddr, V_SAL as esal  FROM DUAL) 
          ON (e.emp_id = eno)
          WHEN MATCHED THEN
          UPDATE 
          SET e.emp_salary = esal*1.1
          DELETE WHERE e.emp_salary > 15000
          WHEN NOT MATCHED THEN
          INSERT (e.emp_id, e.emp_name, e.emp_address, e.emp_salary)
          VALUES (eno, TO_CHAR(ename), TO_CHAR(eaddr), esal);
        
         COMMIT;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
        END;
      END LOOP;
    END IF;
    UTL_FILE.FCLOSE(F);
  END;
 /