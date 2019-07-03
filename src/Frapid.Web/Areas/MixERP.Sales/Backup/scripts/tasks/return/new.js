const transactionMasterId = window.getQueryStringByName("TransactionMasterId");
const header = $(`<div class='ui centered sales return header'>${window.translate("SalesReturn")}<span></span></a>`);
header.find("span").html(transactionMasterId);
$(".status.head").before(header);

function removeEls() {
    $(".pos.tabs").remove();
    $("[data-payment-type]").remove();
    $(".payment.type.container").remove();
    $(".coupon.code.item").parent().remove();
    $(".reprint.ticket.item").remove();
    $("#ShipperSelect").closest(".one.summary.items").remove();
};

removeEls();

$(document).on("posready", function() {
    $("#CheckoutButton").off("click").on("click", function() {
        function request(model) {
            const url = "/dashboard/sales/tasks/return/new";
            const data = JSON.stringify(model);
            return window.getAjaxRequest(url, "POST", data);
        };

        const model = window.getModel();
        model.TransactionMasterId = window.getQueryStringByName("TransactionMasterId");


        if (!model.Details.length) {
            window.displayMessage(window.translate("PleaseSelectItem"));
            return;
        };

        const confirmed = confirm(window.translate("AreYouSure"));

        if (!confirmed) {
            return;
        };


        $("#CheckoutButton").addClass("loading").prop("disabled", true);

        const ajax = request(model);

        ajax.success(function(response) {
            //const id = response;
            document.location = "/dashboard/sales/tasks/return";
        });

        ajax.fail(function(xhr) {
            $("#CheckoutButton").removeClass("loading").prop("disabled", false);
            window.displayMessage(JSON.stringify(xhr));
        });
    });
});