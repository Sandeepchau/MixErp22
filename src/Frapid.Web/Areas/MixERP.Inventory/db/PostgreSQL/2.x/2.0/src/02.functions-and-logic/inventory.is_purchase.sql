DROP FUNCTION IF EXISTS inventory.is_purchase(_transaction_master_id bigint);

CREATE FUNCTION inventory.is_purchase(_transaction_master_id bigint)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE finance.transaction_master.transaction_master_id = $1
        AND book IN ('Purchase')
    ) THEN
            RETURN true;
    END IF;

    RETURN false;
END
$$
LANGUAGE plpgsql;
