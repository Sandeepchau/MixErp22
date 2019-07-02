IF OBJECT_ID('inventory.create_item_variant') IS NOT NULL
DROP PROCEDURE inventory.create_item_variant;

GO

CREATE PROCEDURE inventory.create_item_variant
(
    @variant_of             integer,
    @item_id                integer,
    @item_code              national character varying(12),
    @item_name              national character varying(100),
    @variants               national character varying(MAX),
    @user_id                integer,
	@variant_id				integer OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @variant_ids TABLE
	(
		variant_id			integer
	);

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count = 0)
        BEGIN
            BEGIN TRANSACTION
        END;

    	INSERT INTO @variant_ids(variant_id)
    	SELECT * FROM core.array_split(@variants);

        IF(COALESCE(@item_id, 0) = 0)
    	BEGIN
            INSERT INTO inventory.items
            (
                item_code, 
                item_name, 
                item_group_id, 
                item_type_id, 
                brand_id, 
                preferred_supplier_id, 
                lead_time_in_days, 
                unit_id,
                hot_item,
                cost_price,
                selling_price,
                selling_price_includes_tax,
                reorder_unit_id,
                reorder_level,
                reorder_quantity,
                maintain_inventory,
                audit_user_id,
                photo,
                is_variant_of
            )
            SELECT
                @item_code, 
                @item_name, 
                item_group_id, 
                item_type_id, 
                brand_id, 
                preferred_supplier_id, 
                lead_time_in_days, 
                unit_id,
                hot_item,
                cost_price,
                selling_price,
                selling_price_includes_tax,
                reorder_unit_id,
                reorder_level,
                reorder_quantity,
                maintain_inventory,
                @user_id,
                photo,
                @variant_of
            FROM inventory.items
            WHERE item_id = @variant_of;

            SET @variant_id = SCOPE_IDENTITY();
        END;

        DELETE FROM inventory.item_variants
        WHERE item_id = @variant_id
        AND variant_id NOT IN
        (
            SELECT * FROM @variant_ids
        );

        WITH variants
        AS
        (
            SELECT * FROM @variant_ids
        ),
        new
        AS
        (
            SELECT variant_id FROM variants 
    		WHERE variant_id NOT IN
            (
                SELECT inventory.item_variants.variant_id
                FROM inventory.item_variants
                WHERE item_id = @variant_id
            )
        )
        
        INSERT INTO inventory.item_variants(item_id, variant_id, audit_user_id)
        SELECT @variant_id, variant_id, @user_id
        FROM new;
    
                
        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


