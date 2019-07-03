IF OBJECT_ID('sales.get_late_fee_id_by_late_fee_code') IS NOT NULL
DROP FUNCTION sales.get_late_fee_id_by_late_fee_code;

GO

CREATE FUNCTION sales.get_late_fee_id_by_late_fee_code(@late_fee_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.late_fee.late_fee_id
	    FROM sales.late_fee
	    WHERE sales.late_fee.late_fee_code = @late_fee_code
	    AND sales.late_fee.deleted = 0
    );
END;




GO
