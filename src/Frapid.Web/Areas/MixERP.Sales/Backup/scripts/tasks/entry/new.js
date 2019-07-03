function mergeInfo(model) {
    $("#CustomerInputText").attr("data-customer-id", model.CustomerId).val(model.CustomerName);
    $("#PriceTypeSelect").val(model.PriceTypeId);
    $("#ShipperSelect").val(model.ShipperId);
    $("#ReferenceNumberInputText").val(model.ReferenceNumber);
};

function mergeDetails(model) {
    $(document).off("itemAdded").on("itemAdded", function (e, tabId, itemId, el) {
        const item = window.Enumerable.From(model).Where(function (x) {
            return x.ItemId === window.parseInt(itemId);
        }).FirstOrDefault();

        const quantityInput = el.find("input.quantity");
        const priceInput = el.find("input.price");
        const discountInput = el.find("input.discount");
        const unitSelect = el.find("select.unit");

        unitSelect.val(item.UnitId).trigger("change");
        priceInput.val(item.Price).trigger("keyup");

        setTimeout(function () {
            quantityInput.val(item.Quantity).trigger("keyup");
        }, 1000);

        discountInput.val(item.DiscountRate).trigger("keyup").trigger("blur");
    });

    $.each(model, function () {
        $("#POSItemList [data-item-id='" + this.ItemId + "']").trigger("click");
    });
};

function mergeOrder(orderId) {
    function request() {
        var url = "/dashboard/sales/tasks/order/merge-model/{orderId}";
        url = url.replace("{orderId}", orderId);

        return window.getAjaxRequest(url);
    };

    $(".pos.tabs").html("");
    const ajax = request();

    ajax.success(function (response) {
        window.mergeInfo(response.Order);
        window.mergeDetails(response.Details);
    });
};

function mergeQuotation(quotationId) {
    function request() {
        var url = "/dashboard/sales/tasks/quotation/merge-model/{quotationId}";
        url = url.replace("{quotationId}", quotationId);

        return window.getAjaxRequest(url);
    };

    $(".pos.tabs").html("");
    const ajax = request();


    ajax.success(function (response) {
        window.mergeInfo(response.Quotation);
        window.mergeDetails(response.Details);
    });
};

$(document).on("itemFetched", function () {
    const orderId = window.getQueryStringByName("OrderId");

    if (orderId) {
        mergeOrder(orderId);
        return;
    };

    const quotationId = window.getQueryStringByName("QuotationId");

    if (quotationId) {
        mergeQuotation(quotationId);
    };
});