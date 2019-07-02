DROP FUNCTION IF EXISTS inventory.get_customer_code_by_customer_id(_customer_id integer);

CREATE FUNCTION inventory.get_customer_code_by_customer_id(_customer_id integer)
RETURNS national character varying(500)
AS
$$
BEGIN
    RETURN inventory.customers.customer_code
    FROM inventory.customers
    WHERE inventory.customers.customer_id = _customer_id;
END
$$
LANGUAGE plpgsql;
