IF OBJECT_ID('inventory.get_cost_of_goods_sold') IS NOT NULL
DROP FUNCTION inventory.get_cost_of_goods_sold;

GO

CREATE FUNCTION inventory.get_cost_of_goods_sold(@item_id integer, @unit_id integer, @store_id integer, @quantity numeric(30, 6))
RETURNS numeric(30, 6)
AS
BEGIN
	IF(@quantity = 0)
	BEGIN
		RETURN 0;
	END;

    DECLARE @backup_quantity            numeric(30, 6);
    DECLARE @base_quantity              numeric(30, 6);
    DECLARE @base_unit_id               integer;
    DECLARE @base_unit_cost             numeric(30, 6);
    DECLARE @total_sold                 integer;
    DECLARE @office_id                  integer = inventory.get_office_id_by_store_id(@store_id);
    DECLARE @method                     national character varying(1000) = inventory.get_cost_of_good_method(@office_id);

    --backup base quantity in numeric(30, 6)
    SET @backup_quantity                = inventory.get_base_quantity_by_unit_id(@unit_id, @quantity);
    --convert base quantity to whole number
    SET @base_quantity                  = CEILING(@backup_quantity);
    SET @base_unit_id                   = inventory.get_root_unit_id(@unit_id);
        
    IF(@method = 'MAVCO')
    BEGIN
        RETURN inventory.get_mavcogs(@item_id, @store_id, @base_quantity, 1.00);
    END; 


    SELECT @total_sold = COALESCE(SUM(base_quantity), 0)
    FROM inventory.verified_checkout_details_view
    WHERE transaction_type='Cr'
    AND item_id = @item_id;


    DECLARE @temp_cost_of_goods_sold TABLE
    (
        id                     bigint IDENTITY,
        checkout_detail_id     bigint,
        audit_ts               DATETIMEOFFSET,
        value_date             date,
        price                  numeric(30, 6),
        transaction_type       national character varying(1000)
                    
    ) ;


    /*TODO:
    ALTERNATIVE AND MUCH EFFICIENT APPROACH
        SELECT
            *,
            (
                SELECT SUM(base_quantity)
                FROM inventory.verified_checkout_details_view AS i
                WHERE i.checkout_detail_id <= v.checkout_detail_id
                AND item_id = 1
            ) AS total
        FROM inventory.verified_checkout_details_view AS v
        WHERE item_id = 1
        ORDER BY value_date, checkout_id;
    */

    WITH stock_cte AS
    (
        SELECT
            checkout_detail_id, 
            audit_ts,
            value_date,
            series.generate_series AS series,
            (price * quantity) / base_quantity AS price,
            transaction_type
        FROM inventory.verified_checkout_details_view
        CROSS APPLY core.generate_series(1, CAST(inventory.verified_checkout_details_view.base_quantity AS integer)) AS series
        WHERE item_id = @item_id
        AND store_id = @store_id
    )
    
    INSERT INTO @temp_cost_of_goods_sold(checkout_detail_id, audit_ts, value_date, price, transaction_type)
    SELECT checkout_detail_id, audit_ts, value_date, price, transaction_type FROM stock_cte
    ORDER BY value_date, audit_ts, checkout_detail_id;


    IF(@method = 'LIFO')
    BEGIN
        SELECT @base_unit_cost = SUM(price)
        FROM 
        (
            SELECT price
            FROM @temp_cost_of_goods_sold
            WHERE transaction_type ='Dr'
            ORDER BY id DESC
            OFFSET @total_sold ROWS
            FETCH NEXT CAST(@base_quantity AS integer) ROWS ONLY
        ) S;
    END
    ELSE IF (@method = 'FIFO')
    BEGIN
        SELECT @base_unit_cost = SUM(price)
        FROM 
        (
            SELECT price
            FROM @temp_cost_of_goods_sold
            WHERE transaction_type ='Dr'
            ORDER BY id
            OFFSET @total_sold ROWS
            FETCH NEXT CAST(@base_quantity AS integer) ROWS ONLY
        ) S;
    END
    ELSE IF (@method != 'MAVCO')
    BEGIN
        RETURN 0;
        --RAISERROR('Invalid configuration: COGS method.', 13, 1);
    END;

	IF(@base_unit_cost IS NULL)
	BEGIN
		SET @base_unit_cost = inventory.get_item_cost_price(@item_id, @base_unit_id) * @base_quantity;
	END;

    --APPLY numeric(30, 6) QUANTITY PROVISON
    SET @base_unit_cost = @base_unit_cost * (@backup_quantity / @base_quantity);


    RETURN @base_unit_cost;
END;




GO

--SELECT inventory.get_cost_of_goods_sold(158, 2, 2, 12);

