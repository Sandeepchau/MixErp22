IF OBJECT_ID('inventory.delete_variant_item') IS NOT NULL
DROP PROCEDURE inventory.delete_variant_item;

GO

CREATE PROCEDURE inventory.delete_variant_item(@item_id integer)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY
		DECLARE @tran_count int = @@TRANCOUNT;
		
		IF(@tran_count= 0)
		BEGIN
			BEGIN TRANSACTION
		END;

	    DELETE FROM inventory.item_variants WHERE item_id = @item_id;
	    DELETE FROM inventory.items WHERE item_id = @item_id;

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

		DECLARE @ErrorMessage national character varying(4000)	= ERROR_MESSAGE();
		DECLARE @ErrorSeverity int								= ERROR_SEVERITY();
		DECLARE @ErrorState int									= ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH;
END;

GO
