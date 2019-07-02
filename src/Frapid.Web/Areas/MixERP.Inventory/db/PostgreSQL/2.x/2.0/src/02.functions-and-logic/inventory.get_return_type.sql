DROP FUNCTION IF EXISTS inventory.get_return_type(_checkout_id bigint);


CREATE FUNCTION inventory.get_return_type(_checkout_id bigint)
RETURNS national character varying(50)
AS
$$
BEGIN
	RETURN
	(
		SELECT inventory.checkout_details.transaction_type
		FROM inventory.checkout_details
		WHERE inventory.checkout_details.checkout_id = _checkout_id
		LIMIT 1
	);
END
$$
LANGUAGE plpgsql;


