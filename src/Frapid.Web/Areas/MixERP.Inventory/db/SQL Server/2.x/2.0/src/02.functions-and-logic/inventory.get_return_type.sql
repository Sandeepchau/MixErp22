IF OBJECT_ID('inventory.get_return_type') IS NOT NULL
DROP FUNCTION inventory.get_return_type;

GO


CREATE FUNCTION inventory.get_return_type(@checkout_id bigint)
RETURNS national character varying(50)
AS
BEGIN
	RETURN
	(
		SELECT TOP 1 inventory.checkout_details.transaction_type
		FROM inventory.checkout_details
		WHERE inventory.checkout_details.checkout_id = @checkout_id
	)
END;


GO

GRANT EXECUTE ON inventory.get_return_type TO report_user;

GO
