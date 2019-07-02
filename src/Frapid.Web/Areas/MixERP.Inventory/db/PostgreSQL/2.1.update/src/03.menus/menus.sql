SELECT * FROM core.create_menu('MixERP.Inventory', 'InventorySetup', 'Inventory Setup', '/dashboard/inventory/setup/is', 'content', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'TransactionDetails', 'Transaction Details', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/TransactionDetails.xml', 'content', 'Setup');


SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Inventory',
    '{*}'::text[]
);

