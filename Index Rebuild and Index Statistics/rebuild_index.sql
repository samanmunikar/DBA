CREATE OR REPLACE PROCEDURE rebuild_index
    AS
BEGIN
    FOR x IN (
        SELECT
            index_name
        FROM
            user_indexes
        WHERE
            index_type = 'NORMAL'
    ) LOOP
        EXECUTE IMMEDIATE 'analyze index '
                          || x.index_name
                          || ' compute statistics';
        EXECUTE IMMEDIATE 'analyze index '
                          || x.index_name
                          || ' validate structure';
        FOR i IN (
            SELECT
                name,
                height,
                lf_rows,
                del_lf_rows,
                blks_gets_per_access,
                round( (del_lf_rows / lf_rows) * 100,2) AS ratio
            FROM
                index_stats
            WHERE
                (
                    lf_rows > 100
                    AND del_lf_rows > 0
                )
                AND (
                    height > 3
                    OR ( ( del_lf_rows / lf_rows ) * 100 ) > 20
                    OR blks_gets_per_access > 5
                )
        ) LOOP
            EXECUTE IMMEDIATE 'alter index '
                              || i.name
                              || ' rebuild';
        END LOOP;

    END LOOP;

    dbms_output.put_line('Success!!!!!');
END;
/

SET SERVEROUTPUT ON;

EXECUTE rebuild_index;