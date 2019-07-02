DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Inventory'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Inventory'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.Inventory';


SELECT * FROM core.create_app('MixERP.Inventory', 'Inventory', 'Inventory', '1.0', 'MixERP Inc.', 'December 1, 2015', 'cart teal', '/dashboard/inventory/tasks/inventory-transfers', NULL::text[]);

SELECT * FROM core.create_menu('MixERP.Inventory', 'Tasks', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransfers', 'Inventory Transfers', '/dashboard/inventory/tasks/inventory-transfers', 'exchange', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryAdjustments', 'Inventory Adjustments', '/dashboard/inventory/tasks/inventory-adjustments', 'grid layout', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferVerification', 'Inventory Transfer Verification', '/dashboard/inventory/tasks/inventory-transfers/verification', 'checkmark box', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryAdjustmentVerification', 'Inventory Adjustment Verification', '/dashboard/inventory/tasks/inventory-adjustments/verification', 'checkmark', 'Tasks');
-- SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferRequest', 'Inventory Transfer Request', '/dashboard/inventory/tasks/inventory-transfer/request', 'food', 'Tasks');
-- SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferAuthorization', 'Inventory Transfer Authorization', '/dashboard/inventory/tasks/inventory-transfer/authorization', 'keyboard', 'Tasks');
-- SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferDelivery', 'Inventory Transfer Delivery', '/dashboard/inventory/tasks/inventory-transfer/delivery', 'users', 'Tasks');
-- SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferAcknowledgement', 'Inventory Transfer Acknowledgement', '/dashboard/inventory/tasks/inventory-transfer/acknowledgement', 'users', 'Tasks');
-- SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryTransferAcknowledgement', 'Inventory Transfer Acknowledgement', '/dashboard/inventory/tasks/inventory-transfer/acknowledgement', 'users', 'Tasks');

SELECT * FROM core.create_menu('MixERP.Inventory', 'Setup', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryItems', 'Inventory Items', '/dashboard/inventory/setup/inventory-items', 'content', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'ItemGroups', 'Item Groups', '/dashboard/inventory/setup/item-groups', 'cubes', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'ItemTypes', 'Item Types', '/dashboard/inventory/setup/item-types', 'ellipsis vertical', 'Setup');
--SELECT * FROM core.create_menu('MixERP.Inventory', 'CostPrices', 'Cost Prices', '/dashboard/inventory/setup/cost-prices', 'money', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'StoreTypes', 'Store Types', '/dashboard/inventory/setup/store-types', 'block layout', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Stores', 'Stores', '/dashboard/inventory/setup/stores', 'cube', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Counters', 'Counters', '/dashboard/inventory/setup/counters', 'square outline', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'CustomerTypes', 'Customer Types', '/dashboard/inventory/setup/customer-types', 'users', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'SupplierTypes', 'Supplier Types', '/dashboard/inventory/setup/supplier-types', 'spy', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Customers', 'Customers', '/dashboard/inventory/setup/customers', 'user', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Suppliers', 'Suppliers', '/dashboard/inventory/setup/suppliers', 'male', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Brands', 'Brands', '/dashboard/inventory/setup/brands', 'bold', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'UnitsOfMeasure', 'Units of Measure', '/dashboard/inventory/setup/units-of-measure', 'underline', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'CompoundUnitsOfMeasure', 'Compound Units of Measure', '/dashboard/inventory/setup/compound-units-of-measure', 'move', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Shippers', 'Shippers', '/dashboard/inventory/setup/shippers', 'ship', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Attributes', 'Attributes', '/dashboard/inventory/setup/attributes', 'crosshairs', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'Variants', 'Variants', '/dashboard/inventory/setup/variants', 'align center', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'ItemVariants', 'Item Variants', '/dashboard/inventory/setup/item-variants', 'unordered list', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'OpeningInventories', 'Opening Inventories', '/dashboard/inventory/setup/opening-inventories', 'toggle on', 'Setup');
SELECT * FROM core.create_menu('MixERP.Inventory', 'OpeningInventoryVerification', 'Opening Inventory Verification', '/dashboard/inventory/setup/opening-inventories/verification', 'check circle outline', 'Setup');

SELECT * FROM core.create_menu('MixERP.Inventory', 'Reports', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryAccountStatement', 'Inventory Account Statement', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/AccountStatement.xml', 'book', 'Reports');
SELECT * FROM core.create_menu('MixERP.Inventory', 'PhysicalCount', 'Physical Count', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/PhysicalCount.xml', 'circle', 'Reports');
SELECT * FROM core.create_menu('MixERP.Inventory', 'CustomerContacts', 'Customer Contacts', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/CustomerContacts.xml', 'users', 'Reports');
SELECT * FROM core.create_menu('MixERP.Inventory', 'LowInventoryReport', 'Low Inventory Report', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/LowInventory.xml', 'battery low', 'Reports');
SELECT * FROM core.create_menu('MixERP.Inventory', 'ProfitStatusByItem', 'Profit Status by Item', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/ProfitStatusByItem.xml', 'bar chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Inventory', 'InventoryDailyReport', 'Inventory Daily Report', '/dashboard/reports/view/Areas/MixERP.Inventory/Reports/InventoryDailyReport.xml', 'sticky note outline icon', 'Reports');


SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Inventory',
    '{*}'::text[]
);

