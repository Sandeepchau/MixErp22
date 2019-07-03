window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesChecklist") + window.tranId,
    ViewText: window.translate("ViewSales"),
    ViewUrl: "/dashboard/sales/tasks/entry",
    AddNewText: window.translate("AddNewSalesEntry"),
    AddNewUrl: "/dashboard/sales/tasks/entry/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + window.tranId
});
