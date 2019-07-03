window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesQuotationChecklist") + window.tranId,
    ViewText: window.translate("ViewSalesQuotations"),
    ViewUrl: "/dashboard/sales/tasks/quotation",
    AddNewText: window.translate("AddNewSalesQuotation"),
    AddNewUrl: "/dashboard/sales/tasks/quotation/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Quotation.xml?quotation_id=" + window.tranId
});

$("#WithdrawDiv").remove();

$(".withdraw.button").text(window.translate("Cancel")).off("click").on("click", function () {
    function request(id) {
        var url = "/dashboard/sales/tasks/quotation/{id}/cancel";
        url = url.replace("{id}", id);

        return window.getAjaxRequest(url, "DELETE");
    };

    if (!window.confirmAction()) {
        return;
    };

    const ajax = request(window.tranId);

    ajax.success(function() {
        window.displaySuccess();
        document.location = document.location;
    });

    ajax.fail(function(xhr) {
        window.logAjaxErrorMessage(xhr);
    });
});
