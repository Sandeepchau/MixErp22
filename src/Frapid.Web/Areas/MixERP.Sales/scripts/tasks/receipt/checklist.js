window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("ReceiptChecklist") + window.tranId,
    ViewText: window.translate("ViewReceipts"),
    ViewUrl: "/dashboard/sales/tasks/receipt",
    AddNewText: window.translate("AddNewReceiptEntry"),
    AddNewUrl: "/dashboard/sales/tasks/receipt/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Receipt.xml?transaction_master_id=" + window.tranId
});
