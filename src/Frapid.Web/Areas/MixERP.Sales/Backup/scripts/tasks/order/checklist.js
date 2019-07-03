window.prepareChecklist({
    TranId: window.tranId,
    Title: window.translate("SalesOrderChecklist") + " #" + window.tranId,
    ViewText: window.translate("ViewSalesOrders"),
    ViewUrl: "/dashboard/sales/tasks/order",
    AddNewText: window.translate("AddNewSalesOrder"),
    AddNewUrl: "/dashboard/sales/tasks/order/new",
    ReportPath: "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Order.xml?order_id=" + window.tranId
});

$("#WithdrawDiv").remove();
$(".withdraw.button").text(window.translate("Cancel")).off("click").on("click", function () {
    function request(id) {
        var url = "/dashboard/sales/tasks/order/{id}/cancel";
        url = url.replace("{id}", id);

        return window.getAjaxRequest(url, "DELETE");
    };

    if (!window.confirmAction()) {
        return;
    };

    const ajax = request(window.tranId);

    ajax.success(function () {
        window.displaySuccess();
        document.location = document.location;
    });

    ajax.fail(function (xhr) {
        window.logAjaxErrorMessage(xhr);
    });
});
