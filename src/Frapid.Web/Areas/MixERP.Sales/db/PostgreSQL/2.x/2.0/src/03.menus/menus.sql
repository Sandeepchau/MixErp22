DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Sales'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Sales'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.Sales';


SELECT * FROM core.create_app('MixERP.Sales', 'Sales', 'Sales', '1.0', 'MixERP Inc.', 'December 1, 2015', 'shipping blue', '/dashboard/sales/tasks/console', NULL::text[]);

SELECT * FROM core.create_menu('MixERP.Sales', 'Tasks', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'OpeningCash', 'Opening Cash', '/dashboard/sales/tasks/opening-cash', 'money', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesEntry', 'Sales Entry', '/dashboard/sales/tasks/entry', 'write', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'Receipt', 'Receipt', '/dashboard/sales/tasks/receipt', 'checkmark box', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesReturns', 'Sales Returns', '/dashboard/sales/tasks/return', 'minus square', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesQuotations', 'Sales Quotations', '/dashboard/sales/tasks/quotation', 'quote left', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesOrders', 'Sales Orders', '/dashboard/sales/tasks/order', 'file text outline', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesEntryVerification', 'Sales Entry Verification', '/dashboard/sales/tasks/entry/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'ReceiptVerification', 'Receipt Verification', '/dashboard/sales/tasks/receipt/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesReturnVerification', 'Sales Return Verification', '/dashboard/sales/tasks/return/verification', 'checkmark box', 'Tasks');
--SELECT * FROM core.create_menu('MixERP.Sales', 'CheckClearing', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'minus square outline', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Sales', 'EOD', 'EOD', '/dashboard/sales/tasks/eod', 'money', 'Tasks');

SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerLoyalty', 'Customer Loyalty', 'square outline', 'user', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCards', 'Gift Cards', '/dashboard/sales/loyalty/gift-cards', 'gift', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'AddGiftCardFund', 'Add Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund', 'pound', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'VerifyGiftCardFund', 'Verify Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund/verification', 'checkmark', 'Customer Loyalty');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesCoupons', 'Sales Coupons', '/dashboard/sales/loyalty/coupons', 'browser', 'Customer Loyalty');
--SELECT * FROM core.create_menu('MixERP.Sales', 'LoyaltyPointConfiguration', 'Loyalty Point Configuration', '/dashboard/sales/loyalty/points', 'selected radio', 'Customer Loyalty');

SELECT * FROM core.create_menu('MixERP.Sales', 'Setup', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerTypes', 'Customer Types', '/dashboard/sales/setup/customer-types', 'child', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'Customers', 'Customers', '/dashboard/sales/setup/customers', 'street view', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'PriceTypes', 'Price Types', '/dashboard/sales/setup/price-types', 'ruble', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'SellingPrices', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'in cart', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerwiseSellingPrices', 'Customerwise Selling Prices', '/dashboard/sales/setup/selling-prices/customer', 'in cart', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'LateFee', 'Late Fee', '/dashboard/sales/setup/late-fee', 'alarm mute', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'PaymentTerms', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'checked calendar', 'Setup');
SELECT * FROM core.create_menu('MixERP.Sales', 'Cashiers', 'Cashiers', '/dashboard/sales/setup/cashiers', 'male', 'Setup');

SELECT * FROM core.create_menu('MixERP.Sales', 'Reports', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountReceivables', 'Account Receivables', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivables.xml', 'certificate', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AllGiftCards', 'All Gift Cards', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AllGiftCards.xml', 'certificate', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCardUsageStatement', 'Gift Card Usage Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardUsageStatement.xml', 'columns', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerAccountStatement', 'Customer Account Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerAccountStatement.xml', 'content', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'TopSellingItems', 'Top Selling Items', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/TopSellingItems.xml', 'map signs', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesByOffice', 'Sales by Office', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesByOffice.xml', 'building', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'CustomerReceipts', 'Customer Receipts', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerReceipts.xml', 'building', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'DetailedPaymentReport', 'Detailed Payment Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/DetailedPaymentReport.xml', 'bar chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'GiftCardSummary', 'Gift Card Summary', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardSummary.xml', 'list', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'QuotationStatus', 'Quotation Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/QuotationStatus.xml', 'list', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'OrderStatus', 'Order Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/OrderStatus.xml', 'bar chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'SalesDiscountStatus', 'Sales Discount Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesDiscountStatus.xml', 'shopping basket icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountReceivableByCustomer', 'Account Receivable By Customer Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivableByCustomer.xml', 'list layout icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'ReceiptJournalSummary', 'Receipt Journal Summary Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ReceiptJournalSummary.xml', 'angle double left icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'AccountantSummary', 'Accountant Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountantSummary.xml', 'address book outline icon', 'Reports');
SELECT * FROM core.create_menu('MixERP.Sales', 'ClosedOut', 'Closed Out Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ClosedOut.xml', 'book icon', 'Reports');

SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Sales',
    '{*}'::text[]
);

