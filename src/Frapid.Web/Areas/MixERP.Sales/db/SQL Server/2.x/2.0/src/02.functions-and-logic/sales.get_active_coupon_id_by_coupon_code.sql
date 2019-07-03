IF OBJECT_ID('sales.get_active_coupon_id_by_coupon_code') IS NOT NULL
DROP FUNCTION sales.get_active_coupon_id_by_coupon_code;

GO

CREATE FUNCTION sales.get_active_coupon_id_by_coupon_code(@coupon_code national character varying(100))
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT sales.coupons.coupon_id
	    FROM sales.coupons
	    WHERE sales.coupons.coupon_code = @coupon_code
	    AND COALESCE(sales.coupons.begins_from, CAST(GETUTCDATE() AS date)) >= CAST(GETUTCDATE() AS date)
	    AND COALESCE(sales.coupons.expires_on, CAST(GETUTCDATE() AS date)) <= CAST(GETUTCDATE() AS date)
	    AND sales.coupons.deleted = 0
    );
END;




GO
