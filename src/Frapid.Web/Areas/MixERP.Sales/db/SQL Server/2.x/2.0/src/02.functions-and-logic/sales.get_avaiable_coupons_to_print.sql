IF OBJECT_ID('sales.get_avaiable_coupons_to_print') IS NOT NULL
DROP FUNCTION sales.get_avaiable_coupons_to_print;

GO

CREATE FUNCTION sales.get_avaiable_coupons_to_print(@tran_id bigint)
RETURNS @result TABLE
(
    coupon_id               integer
)
AS
BEGIN
    DECLARE @price_type_id                  integer;
    DECLARE @total_amount                   numeric(30, 6);
    DECLARE @customer_id                    integer;

    DECLARE @temp_coupons TABLE
    (
        coupon_id                           integer,
        maximum_usage                       integer,
        total_used                          integer
    );
    
    SELECT
        @price_type_id = sales.sales.price_type_id,
        @total_amount = sales.sales.total_amount,
        @customer_id = sales.sales.customer_id        
    FROM sales.sales
    WHERE sales.sales.transaction_master_id = @tran_id;


    INSERT INTO @temp_coupons(coupon_id, maximum_usage)
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE sales.coupons.deleted = 0
    AND sales.coupons.enable_ticket_printing = 1
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
    AND sales.coupons.for_ticket_of_price_type_id IS NULL
    AND COALESCE(sales.coupons.for_ticket_having_minimum_amount, 0) = 0
    AND COALESCE(sales.coupons.for_ticket_having_maximum_amount, 0) = 0
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    INSERT INTO @temp_coupons(coupon_id, maximum_usage)
    SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
    FROM sales.coupons
    WHERE sales.coupons.deleted = 0
    AND sales.coupons.enable_ticket_printing = 1
    AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
    AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
    AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
    AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
    AND sales.coupons.for_ticket_of_unknown_customers_only IS NULL;

    IF(COALESCE(@customer_id, 0) > 0)
    BEGIN
        INSERT INTO @temp_coupons(coupon_id, maximum_usage)
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE sales.coupons.deleted = 0
        AND sales.coupons.enable_ticket_printing = 1
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
        AND sales.coupons.for_ticket_of_unknown_customers_only = 0;
    END
    ELSE
    BEGIN
        INSERT INTO @temp_coupons(coupon_id, maximum_usage)
        SELECT sales.coupons.coupon_id, sales.coupons.maximum_usage
        FROM sales.coupons
        WHERE sales.coupons.deleted = 0
        AND sales.coupons.enable_ticket_printing = 1
        AND (sales.coupons.begins_from IS NULL OR sales.coupons.begins_from >= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.expires_on IS NULL OR sales.coupons.expires_on <= CAST(GETUTCDATE() AS date))
        AND (sales.coupons.for_ticket_of_price_type_id IS NULL OR for_ticket_of_price_type_id = @price_type_id)
        AND (sales.coupons.for_ticket_having_minimum_amount IS NULL OR sales.coupons.for_ticket_having_minimum_amount <= @total_amount)
        AND (sales.coupons.for_ticket_having_maximum_amount IS NULL OR sales.coupons.for_ticket_having_maximum_amount >= @total_amount)
        AND sales.coupons.for_ticket_of_unknown_customers_only = 1;    
    END;

    UPDATE @temp_coupons
    SET total_used = 
    (
        SELECT COUNT(*)
        FROM sales.sales
        WHERE sales.sales.coupon_id = coupon_id 
    );

    DELETE FROM @temp_coupons WHERE total_used > maximum_usage;
    
    INSERT INTO @result
    SELECT coupon_id FROM @temp_coupons;

    RETURN;
END;



--SELECT * FROM sales.get_avaiable_coupons_to_print(2);

GO