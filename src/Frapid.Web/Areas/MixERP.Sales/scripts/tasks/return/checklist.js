window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesReturnChecklist") + window.tranId,
    ViewText: window.translate("ViewSalesReturns"),
    ViewUrl: "/dashboard/sales/tasks/return",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Return.xml?transaction_master_id=" + window.tranId
});