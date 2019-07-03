DROP FUNCTION IF EXISTS sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24));

CREATE FUNCTION sales.get_late_fee_id_by_late_fee_code(_late_fee_code national character varying(24))
RETURNS integer
AS
$$
BEGIN
    RETURN sales.late_fee.late_fee_id
    FROM sales.late_fee
    WHERE sales.late_fee.late_fee_code = _late_fee_code
    AND NOT sales.late_fee.deleted;    
END
$$
LANGUAGE plpgsql;
