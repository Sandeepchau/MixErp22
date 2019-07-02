INSERT INTO inventory.inventory_setup(office_id, inventory_system, cogs_calculation_method, default_discount_account_id)
SELECT office_id, 'Perpetual', 'FIFO', finance.get_account_id_by_account_number('40270')
FROM core.offices;


GO
