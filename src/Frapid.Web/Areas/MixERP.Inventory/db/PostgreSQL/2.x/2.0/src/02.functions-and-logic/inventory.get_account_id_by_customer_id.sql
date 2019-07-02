DROP FUNCTION IF EXISTS inventory.get_account_id_by_customer_id(_customer_id integer);

CREATE FUNCTION inventory.get_account_id_by_customer_id(_customer_id integer)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN inventory.customers.account_id
    FROM inventory.customers
    WHERE inventory.customers.customer_id=_customer_id
    AND NOT inventory.customers.deleted;
END
$$
LANGUAGE plpgsql;

