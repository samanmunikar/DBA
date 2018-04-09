CREATE OR REPLACE PROCEDURE reset_all_objects_from_schema (
    schema_name IN VARCHAR2
) AS
    sql_text   VARCHAR2(500);
BEGIN
-------------------------------------------------Disable all Constraints--------------------------------------------------------    
    ----------------------------------Disable all constraints except primary key first------------------------------------------
    FOR i IN (
        SELECT
            constraint_name,
            table_name,
            status
        FROM
            all_constraints
        WHERE
            owner = upper(schema_name)
            AND   constraint_type NOT IN (
                'P'
            )
            AND   constraint_name NOT LIKE 'BIN$%'
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' disable constraint '
        || i.constraint_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;
    
    ------------------------------------------------Disable primary key---------------------------------------------------

    FOR i IN (
        SELECT
            constraint_name,
            table_name,
            status
        FROM
            all_constraints
        WHERE
            owner = upper(schema_name)
            AND   constraint_type IN (
                'P'
            )
            AND   constraint_name NOT LIKE 'BIN$%'
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' disable constraint '
        || i.constraint_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;
    
--------------------------------------------------Disable all Triggers----------------------------------------------------------    

    FOR i IN (
        SELECT
            table_name
        FROM
            all_tables
        WHERE
            owner = upper(schema_name)
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' disable all triggers';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;

-------------------------------------------------Truncate all the tables--------------------------------------------------------

    FOR i IN (
        SELECT
            table_name
        FROM
            all_tables
        WHERE
            owner = upper(schema_name)
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'truncate table '
        || schema_name
        || '.'
        || i.table_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;

------------------------------------------------Reset all the sequences---------------------------------------------------------

    FOR i IN (
        SELECT
            sequence_name,
            min_value,
            increment_by,
            max_value,
            cache_size,
            cycle_flag,
            order_flag
        FROM
            all_sequences
        WHERE
            sequence_owner = upper(schema_name)
    ) LOOP
        --------------------------------Drop sequence---------------------------
        sql_text := 'drop sequence '
        || schema_name
        || '.'
        || i.sequence_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
        IF
            i.cache_size = 0 -- for nocached sequence
        THEN
            IF
                i.cycle_flag = 'Y'
            THEN
                IF
                    i.order_flag = 'Y'
                THEN
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' nocache '
                    || ' cycle'
                    ||        -- for nocached cycle sequence
                     ' order';         -- for order sequence    

                    EXECUTE IMMEDIATE sql_text;
                ELSE
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' nocache '
                    || ' cycle'
                    ||        -- for nocached cycle sequence
                     ' noorder';  -- for noorder sequence    

                    EXECUTE IMMEDIATE sql_text;
                END IF;

            ELSE
                IF
                    i.order_flag = 'Y'
                THEN
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' nocache '
                    || ' nocycle'
                    ||      -- for nocached nocycle sequence
                     ' order';          -- for order sequence

                    EXECUTE IMMEDIATE sql_text;
                ELSE
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' nocache '
                    || ' nocycle'
                    ||      -- for nocached nocycle sequence
                     ' noorder';       -- for no order sequence

                    EXECUTE IMMEDIATE sql_text;
                END IF;
            END IF;
        ELSE  --for cached sequence
            IF
                i.cycle_flag = 'Y'
            THEN
                IF
                    i.order_flag = 'Y'
                THEN
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' cache '
                    || i.cache_size
                    || ' cycle'
                    ||        -- for nocached cycle sequence
                     ' order';  -- for order sequence    

                    EXECUTE IMMEDIATE sql_text;
                ELSE
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' cache '
                    || i.cache_size
                    || ' cycle'
                    ||        -- for nocached cycle sequence
                     ' noorder';  -- for noorder sequence    

                    EXECUTE IMMEDIATE sql_text;
                END IF;

            ELSE
                IF
                    i.order_flag = 'Y'
                THEN
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' cache '
                    || i.cache_size
                    || ' nocycle'
                    ||      -- for nocached nocycle sequence
                     ' order';          -- for order sequence

                    EXECUTE IMMEDIATE sql_text;
                ELSE
                    sql_text := 'create sequence '
                    || schema_name
                    || '.'
                    || i.sequence_name
                    || ' 
                                minvalue '
                    || i.min_value
                    || ' maxvalue '
                    || i.max_value
                    || ' increment by '
                    || i.increment_by
                    || ' cache '
                    || i.cache_size
                    || ' nocycle'
                    ||      -- for nocached nocycle sequence
                     ' noorder';       -- for no order sequence

                    EXECUTE IMMEDIATE sql_text;
                END IF;
            END IF;
        END IF;

    END LOOP;
    
----------------------------------------------------Enable all constraints------------------------------------------------------
    -----------------------------------------------Enable first primary key constraints-----------------------------------------

    FOR i IN (
        SELECT
            constraint_name,
            table_name,
            status
        FROM
            all_constraints
        WHERE
            owner = upper(schema_name)
            AND   constraint_type IN (
                'P'
            )
            AND   constraint_name NOT LIKE 'BIN$%'
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' enable constraint '
        || i.constraint_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;
    
    ----------------------------------------------------------Enable other keys-------------------------------------------------

    FOR i IN (
        SELECT
            constraint_name,
            table_name,
            status
        FROM
            all_constraints
        WHERE
            owner = upper(schema_name)
            AND   constraint_type NOT IN (
                'P'
            )
            AND   constraint_name NOT LIKE 'BIN$%'
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' enable constraint '
        || i.constraint_name
        || '';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;
----------------------------------------------------Enable all triggers---------------------------------------------------------

    FOR i IN (
        SELECT
            table_name
        FROM
            all_tables
        WHERE
            owner = upper(schema_name)
            AND   table_name NOT LIKE 'BIN$%'
            AND   table_name NOT IN (
                SELECT
                    table_name
                FROM
                    all_external_tables
                WHERE
                    owner = upper(schema_name)
            )
    ) LOOP
        sql_text := 'alter table '
        || schema_name
        || '.'
        || i.table_name
        || ' enable all triggers';
        --dbms_output.put_line(sql_text);

        EXECUTE IMMEDIATE sql_text;
    END LOOP;

    dbms_output.put_line('Success!!!!!!!!!!!!');
END;
/

SET SERVEROUTPUT ON;
-- reset_all_objects_from_schema('schema_name'); 
EXEC reset_all_objects_from_schema('saman');