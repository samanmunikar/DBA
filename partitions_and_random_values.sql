---------------------------------------------------CREATING TABLE WITH PARTITIONS-----------------------------------------------

--PARTITION BY RANGE
create table test_range_PARTITION (
id  number,
name varchar2(25),
address varchar2(50),
salary number(8,2),
constraint test_range_id_pk primary key(id)
)
partition by range(salary)
(partition low_salary values less than (10000) tablespace TEST,
partition medium_salary values less than (50000) tablespace TEST,
partition high_salary values less than (150000) tablespace TEST
);
 
--PARTITION BY HASH
create table test_hash_partition(
id number,
department varchar2(50),
join_date date,
constraint test_hash_partition_pk primary key(id)
)
partition by hash(id)
partitions 4
store in (TEST);

--COMPOSITE PARTITION
create table test_composite_partition(
id number,
department varchar2(50),
join_date date,
constraint test_composite_partition_pk primary key(id)
)
partition by range(join_date)
subpartition by hash(id)
subpartitions 8
(partition before_2000 values less than(TO_DATE('01/01/2000', 'DD/MM/YYYY')),
partition before_2010 values less than (TO_DATE('01/01/2010', 'DD/MM/YYYY')),
partition before_current_date values less than (TO_DATE(SYSDATE, 'DD/MM/YYYY'))
);

------------------------------------------------------CREATING SEQUENCE---------------------------------------------------------

--TEST_RANGE_PARTITION TABLE SEQUENCE
create sequence test_range_partition_sq 
    minvalue 0
    start with 0
    increment by 1
    nocache
    nocycle;

--TEST_HASH_PARTITION TABLE SEQUENCE
create sequence test_HASH_partition_sq 
    minvalue 0
    start with 0
    increment by 1
    nocache
    nocycle;

--TEST_COMPOSITE_PARTITION TABLE SEQUENCE
create sequence test_COMPOSITE_partition_sq 
    minvalue 0
    start with 0
    increment by 1
    nocache
    nocycle;

------------------------------------------------INSERTING RECORDS IN TABLE------------------------------------------------------

--INSERT RECORDS INTO TEST_RANGE_PARTITION TABLE
declare
RAND_SALARY number(8,2);
RAND_NAME_NO NUMBER(1);
RAND_NAME VARCHAR2(25);
RAND_ADDRESS_NO NUMBER(1);
RAND_ADDRESS VARCHAR2(50);
begin
    for i in 1..1000
    loop
        RAND_SALARY := dbms_random.value(1000,150000); --USED TO GENERATE RANDOM NUMBER BETWEEN 1000 TO 150000
        
        -----------------------------------GET RANDOM NAME----------------------------------------------
        RAND_NAME_NO := DBMS_RANDOM.VALUE(1,8);
        IF RAND_NAME_NO = 1 
            THEN RAND_NAME := 'SAMAN';
        ELSIF RAND_NAME_NO = 2 
            THEN RAND_NAME := 'SURESH';
        ELSIF RAND_NAME_NO = 3 
            THEN RAND_NAME := 'SUMIN';
        ELSIF RAND_NAME_NO = 4 
            THEN RAND_NAME := 'NITISH';
        ELSIF RAND_NAME_NO = 5 
            THEN RAND_NAME := 'ROBIN';
        ELSIF RAND_NAME_NO = 6 
            THEN RAND_NAME := 'ROWAN';
        ELSIF RAND_NAME_NO = 7 
            THEN RAND_NAME := 'BIKRAM';
        ELSIF RAND_NAME_NO = 8 
            THEN RAND_NAME := 'KRIPISH';
        END IF;
        --DBMS_OUTPUT.PUT_LINE(RAND_NAME);
        
        -------------------------------------------GET RANDOM ADDRESS----------------------------------
        RAND_ADDRESS_NO := DBMS_RANDOM.VALUE(1,5);
        IF RAND_ADDRESS_NO = 1 
            THEN RAND_ADDRESS := 'NAXAL';
        ELSIF RAND_ADDRESS_NO = 2 
            THEN RAND_ADDRESS := 'KALANKI';
        ELSIF RAND_ADDRESS_NO = 3 
            THEN RAND_ADDRESS := 'MANGALBAZAR';
        ELSIF RAND_ADDRESS_NO = 4 
            THEN RAND_ADDRESS := 'CHAPAGAUN';
        ELSIF RAND_ADDRESS_NO = 5 
            THEN RAND_ADDRESS := 'SATDOBATO';
        END IF;
        
        --DBMS_OUTPUT.PUT_LINE(RAND_ADDRESS);
    
        insert into test_RANGE_partition values (test_RANGE_partition_sq.NEXTVAL, RAND_NAME, RAND_ADDRESS, RAND_SALARY);
    end loop;
end;
/

--INSERT RECORDS INTO TEST_HASH_PARTITION TABLE
declare
RAND_DAY NUMBER(2);
RAND_MON NUMBER(2);
RAND_YR NUMBER(4);
RAND_DATE VARCHAR2(25);
RAND_DEPT_NO NUMBER(1);
RAND_DEPT VARCHAR2(25);
begin
    for i in 1..1000
    loop
        RAND_DAY := DBMS_RANDOM.VALUE(1,30);
        RAND_MON := DBMS_RANDOM.VALUE(1,12);
        RAND_YR := DBMS_RANDOM.VALUE(1994,2018);
        RAND_DEPT_NO := DBMS_RANDOM.VALUE(1,3);
        
        ------------------------------------------GET RANDOM DATE-----------------------------------------
        RAND_DATE := TO_CHAR(RAND_DAY||'/'||RAND_MON||'/'||RAND_YR);
        --DBMS_OUTPUT.PUT_LINE(RAND_DATE);
        
        ------------------------------------------GET RANDOM DEPARTMENT----------------------------------- 
        CASE RAND_DEPT_NO
            WHEN 1 THEN RAND_DEPT := 'JAVA';
            WHEN 2 THEN RAND_DEPT := 'DATABASE';
            WHEN 3 THEN RAND_DEPT := 'ANGULAR';
            ELSE RAND_DEPT := 'HELPER';
        END CASE;
        /* ALTERNATE TO CASE WHEN
        IF RAND_DEPT_NO = 1 
            THEN RAND_DEPT := 'JAVA';
        ELSIF RAND_DEPT_NO = 2 
            THEN RAND_DEPT := 'DATABASE';
        ELSIF RAND_DEPT_NO = 3 
            THEN RAND_DEPT := 'ANGULAR';
        ELSE RAND_DEPT := 'HELPER';
        END IF;
        */
        --DBMS_OUTPUT.PUT_LINE(RAND_DEPT);
        
        insert into test_hash_partition values (TEST_HASH_PARTITION_SQ.NEXTVAL, RAND_DEPT, TO_DATE(RAND_DATE, 'DD/MM/YYYY'));
    end loop;
end;
/

--INSERT RECORDS INTO TEST_COMPOSITE_PARTITION TABLE
declare
RAND_DAY NUMBER(2);
RAND_MON NUMBER(2);
RAND_YR NUMBER(4);
RAND_DATE VARCHAR2(25);
RAND_DEPT_NO NUMBER(1);
RAND_DEPT VARCHAR2(25);
begin
    for i in 1..1000
    loop
        RAND_DAY := DBMS_RANDOM.VALUE(1,30);
        RAND_MON := DBMS_RANDOM.VALUE(1,12);
        RAND_YR := DBMS_RANDOM.VALUE(1994,2018);
        RAND_DEPT_NO := DBMS_RANDOM.VALUE(1,3);
        
        ----------------------------GET RANDOM DATE----------------------------------
        RAND_DATE := TO_CHAR(RAND_DAY||'/'||RAND_MON||'/'||RAND_YR);
        --DBMS_OUTPUT.PUT_LINE(RAND_DATE);
        
        ---------------------------GET RAMDOM DEPARTMENT------------------------------
        CASE RAND_DEPT_NO
            WHEN 1 THEN RAND_DEPT := 'JAVA';
            WHEN 2 THEN RAND_DEPT := 'DATABASE';
            WHEN 3 THEN RAND_DEPT := 'ANGULAR';
            ELSE RAND_DEPT := 'HELPER';
        END CASE;
        /* ALTERNATE TO CASE WHEN
        IF RAND_DEPT_NO = 1 
            THEN RAND_DEPT := 'JAVA';
        ELSIF RAND_DEPT_NO = 2 
            THEN RAND_DEPT := 'DATABASE';
        ELSIF RAND_DEPT_NO = 3 
            THEN RAND_DEPT := 'ANGULAR';
        ELSE RAND_DEPT := 'HELPER';
        END IF;
        */
        --DBMS_OUTPUT.PUT_LINE(RAND_DEPT);
        
        insert into test_COMPOSITE_partition values (TEST_COMPOSITE_PARTITION_SQ.NEXTVAL, RAND_DEPT, TO_DATE(RAND_DATE, 'DD/MM/YYYY'));
    end loop;
end;
/

DROP TABLE TEST_hash_partition;
DROP SEQUENCE test_hash_partition_sq;
select count(*) from test_partition;
select * from test_partition;

-------------------------------------------------CREATING A LOCAL PREFIXED INDEX------------------------------------------------
create index test_RANGE_partition_salary_idx on test_RANGE_partition(salary) LOCAL;

----------------------------------------------CREATING A LOCAL NON-PREFIXED INDEX-----------------------------------------------
create index test_RANGE_partition_id_idx on test_RANGE_partition(id) LOCAL;

-----------------------------------------------CREATING A GLOBAL PREFIXED INDEX-------------------------------------------------
create index test_RANGE_partition_salary_global_idx on test_RANGE_partition(salary)
GLOBAL partition by range(salary)
(partition low_salary values less than (10000) tablespace TEST,
partition medium_salary values less than (50000) tablespace TEST,
partition high_salary values less than (150000) tablespace TEST
);
-----------------------------------------------------GATHER TABLE STATS OF TABLE------------------------------------------------
exec dbms_stats.gather_table_stats('SAMAN', 'TEST_RANGE_PARTITION', cascade => TRUE);

-------------------------------------------------DISPLAY TABLE PARTITION INFO---------------------------------------------------
SELECT table_name, partition_name, high_value, num_rows FROM user_tab_partitions ORDER BY table_name, partition_name;
