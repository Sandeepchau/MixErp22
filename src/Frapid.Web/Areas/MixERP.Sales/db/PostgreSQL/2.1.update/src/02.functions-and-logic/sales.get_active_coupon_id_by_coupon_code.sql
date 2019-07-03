DROP FUNCTION IF EXISTS sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100));

CREATE FUNCTION sales.get_active_coupon_id_by_coupon_code(_coupon_code national character varying(100))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.coupons.coupon_id
    FROM sales.coupons
    WHERE sales.coupons.coupon_code = _coupon_code
    AND COALESCE(sales.coupons.begins_from, NOW()::date) >= NOW()::date
    AND COALESCE(sales.coupons.expires_on, NOW()::date) <= NOW()::date
    AND NOT sales.coupons.deleted;
END
$$
LANGUAGE plpgsql;
