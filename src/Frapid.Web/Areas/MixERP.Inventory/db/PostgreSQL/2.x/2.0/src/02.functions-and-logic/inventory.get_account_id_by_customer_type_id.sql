DROP FUNCTION IF EXISTS inventory.get_account_id_by_customer_type_id(_customer_type_id integer);

CREATE FUNCTION inventory.get_account_id_by_customer_type_id(_customer_type_id integer)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN account_id
    FROM inventory.customer_types
    WHERE customer_type_id=_customer_type_id;
END;
$$
LANGUAGE plpgsql;

--SELECT * FROM inventory.get_account_id_by_customer_type_id(1);