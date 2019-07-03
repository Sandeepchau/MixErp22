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


EXECUTE core.create_app 'MixERP.Sales', 'Sales', 'Sales', '1.0', 'MixERP Inc.', 'December 1, 2015', 'shipping blue', '/dashboard/sales/tasks/console', NULL;

EXECUTE core.create_menu 'MixERP.Sales', 'Tasks', 'Tasks', '', 'lightning', '';
EXECUTE core.create_menu 'MixERP.Sales', 'OpeningCash', 'Opening Cash', '/dashboard/sales/tasks/opening-cash', 'money', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesEntry', 'Sales Entry', '/dashboard/sales/tasks/entry', 'write', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'Receipt', 'Receipt', '/dashboard/sales/tasks/receipt', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesReturns', 'Sales Returns', '/dashboard/sales/tasks/return', 'minus square', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesQuotations', 'Sales Quotations', '/dashboard/sales/tasks/quotation', 'quote left', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesOrders', 'Sales Orders', '/dashboard/sales/tasks/order', 'file national character varying(1000) outline', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesEntryVerification', 'Sales Entry Verification', '/dashboard/sales/tasks/entry/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'ReceiptVerification', 'Receipt Verification', '/dashboard/sales/tasks/receipt/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesReturnVerification', 'Sales Return Verification', '/dashboard/sales/tasks/return/verification', 'checkmark box', 'Tasks';
--EXECUTE core.create_menu 'MixERP.Sales', 'CheckClearing', 'Check Clearing', '/dashboard/sales/tasks/checks/checks-clearing', 'minus square outline', 'Tasks';
EXECUTE core.create_menu 'MixERP.Sales', 'EOD', 'EOD', '/dashboard/sales/tasks/eod', 'money', 'Tasks';

EXECUTE core.create_menu 'MixERP.Sales', 'CustomerLoyalty', 'Customer Loyalty', 'square outline', 'user', '';
EXECUTE core.create_menu 'MixERP.Sales', 'GiftCards', 'Gift Cards', '/dashboard/sales/loyalty/gift-cards', 'gift', 'Customer Loyalty';
EXECUTE core.create_menu 'MixERP.Sales', 'AddGiftCardFund', 'Add Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund', 'pound', 'Customer Loyalty';
EXECUTE core.create_menu 'MixERP.Sales', 'VerifyGiftCardFund', 'Verify Gift Card Fund', '/dashboard/loyalty/tasks/gift-cards/add-fund/verification', 'checkmark', 'Customer Loyalty';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesCoupons', 'Sales Coupons', '/dashboard/sales/loyalty/coupons', 'browser', 'Customer Loyalty';
--EXECUTE core.create_menu 'MixERP.Sales', 'LoyaltyPointConfiguration', 'Loyalty Point Configuration', '/dashboard/sales/loyalty/points', 'selected radio', 'Customer Loyalty';

EXECUTE core.create_menu 'MixERP.Sales', 'Setup', 'Setup', 'square outline', 'configure', '';
EXECUTE core.create_menu 'MixERP.Sales', 'CustomerTypes','Customer Types', '/dashboard/sales/setup/customer-types', 'child', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'Customers', 'Customers', '/dashboard/sales/setup/customers', 'street view', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'PriceTypes', 'Price Types', '/dashboard/sales/setup/price-types', 'ruble', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'SellingPrices', 'Selling Prices', '/dashboard/sales/setup/selling-prices', 'in cart', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'CustomerwiseSellingPrices', 'Customerwise Selling Prices', '/dashboard/sales/setup/selling-prices/customer', 'in cart', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'LateFee', 'Late Fee', '/dashboard/sales/setup/late-fee', 'alarm mute', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'PaymentTerms', 'Payment Terms', '/dashboard/sales/setup/payment-terms', 'checked calendar', 'Setup';
EXECUTE core.create_menu 'MixERP.Sales', 'Cashiers', 'Cashiers', '/dashboard/sales/setup/cashiers', 'male', 'Setup';

EXECUTE core.create_menu 'MixERP.Sales', 'Reports', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'MixERP.Sales', 'AccountReceivables', 'Account Receivables', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivables.xml', 'certificate', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'AllGiftCards', 'All Gift Cards', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AllGiftCards.xml', 'certificate', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'GiftCardUsageStatement', 'Gift Card Usage Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardUsageStatement.xml', 'columns', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'CustomerAccountStatement', 'Customer Account Statement', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerAccountStatement.xml', 'content', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'TopSellingItems', 'Top Selling Items', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/TopSellingItems.xml', 'map signs', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesByOffice', 'Sales by Office', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesByOffice.xml', 'building', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'CustomerReceipts', 'Customer Receipts', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/CustomerReceipts.xml', 'building', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'DetailedPaymentReport', 'Detailed Payament Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/DetailedPaymentReport.xml', 'bar chart', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'GiftCardSummary', 'Gift Card Summary', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/GiftCardSummary.xml', 'list', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'QuotationStatus', 'Quotation Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/QuotationStatus.xml', 'list', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'OrderStatus', 'Order Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/OrderStatus.xml', 'bar chart', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'SalesDiscountStatus', 'Sales Discount Status', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/SalesDiscountStatus.xml', 'shopping basket icon', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'AccountReceivableByCustomer', 'Account Receivable By Customer Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountReceivableByCustomer.xml', 'list layout icon', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'ReceiptJournalSummary', 'Receipt Journal Summary Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ReceiptJournalSummary.xml', 'angle double left icon', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'AccountantSummary', 'Accountant Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/AccountantSummary.xml', 'address book outline icon', 'Reports';
EXECUTE core.create_menu 'MixERP.Sales', 'ClosedOut', 'Closed Out Report', '/dashboard/reports/view/Areas/MixERP.Sales/Reports/ClosedOut.xml', 'book icon', 'Reports';

DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'MixERP.Sales',
'{*}';


GO
