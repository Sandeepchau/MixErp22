function getLocalStorageKey(id) {
    return "posTab" + id;
};

function getModel() {
    function getDetails() {
        const items = $("#SalesItems .item");
        var model = [];

        $.each(items, function () {
            const el = $(this);
            const itemId = window.parseInt(el.attr("data-item-id"));
            const quantity = window.parseFloat2(el.find("input.quantity").val()) || 0;
            const unitId = window.parseInt(el.find("select.unit").val());
            const price = window.parseFloat2(el.find("input.price").val()) || 0;
            const discountRate = window.parseFloat2(el.find("input.discount").val()) || 0;
            const discount = (price * quantity) * (discountRate / 100);

            model.push({
                StoreId: $("#StoreSelect").val(),
                ItemId: itemId,
                Quantity: quantity,
                UnitId: unitId,
                Price: price,
                DiscountRate: discountRate,
                Discount: discount
            });
        });

        return model;
    };

    //Cash
    const tender = window.parseFloat2($("#TenderInputText").val()) || 0;
    const change = window.parseFloat2($("#ChangeInputText").val()) || 0;

    //Credit
    const counterId = window.parseInt($("#CounterSelect").val()) || null;
    const paymentTermId = window.parseInt($("#PaymentTermSelect").val()) || null;

    //Check
    const checkAmount = window.parseFloat2($("#CheckAmountInputText").val()) || null;
    const bankName = $("#BankNameInputText").val();
    const checkNumber = $("#CheckNumberInputText").val();
    const checkDate = $("#CheckDateInputText").datepicker("getDate");

    //Gift Card
    const giftCardNumber = $("#GiftCardNumberInputText").val();


    //Discount Coupon
    const couponCode = $("#CouponCodeInputText").val();

    //Discount
    const discountType = window.parseInt($("#DiscountTypeSelect").val());
    const discount = window.parseFloat2($("#DiscountInputText").val()) || 0;

    const valueDate = $("#ValueDateInputText").datepicker("getDate");
    const bookDate = $("#BookDateInputText").datepicker("getDate");
    const costCenterId = window.parseInt($("#CostCenterSelect").val()) || null;
    const referenceNumber = $("#ReferenceNumberInputText").val();
    const statementReference = $("#StatementReferenceInputText").val();
    const customerId = window.parseInt($("#CustomerInputText").attr("data-customer-id")) || null;
    const customerName = $("#CustomerInputText").val();
    const priceTypeId = $("#PriceTypeSelect").val();
    const shipperId = $("#ShipperSelect").val();
    const storeId = $("#StoreSelect").val();
    const details = getDetails();
    const quotationId = window.parseInt(window.getQueryStringByName("QuotationId")) || null;
    const orderId = window.parseInt(window.getQueryStringByName("OrderId")) || null;

    return {
        Tender: tender,
        Change: change,
        PaymentTermId: paymentTermId,
        CheckAmount: checkAmount,
        CheckBankName: bankName,
        CheckNumber: checkNumber,
        CheckDate: checkDate,
        CounterId: counterId,
        GiftCardNumber: giftCardNumber,
        CouponCode: couponCode,
        DiscountType: discountType,
        IsFlatDiscount: discountType === 2,
        Discount: discount,
        ValueDate: valueDate,
        BookDate: bookDate,
        CostCenterId: costCenterId,
        ReferenceNumber: referenceNumber,
        StatementReference: statementReference,
        CustomerId: customerId,
        CustomerName: customerName,
        PriceTypeId: priceTypeId,
        ShipperId: shipperId,
        StoreId: storeId,
        Details: details,
        SalesQuotationId: quotationId,
        SalesOrderId: orderId
    };
};

function getModelById(id) {
    const key = getLocalStorageKey(id);
    const item = localStorage.getItem(key);

    if (item) {
        return JSON.parse(item);
    };

    return null;
};

function removeModelById(id) {
    const key = getLocalStorageKey(id);
    localStorage.removeItem(key);
};

function clearState() {
    $.each(localStorage, function (key) {
        if (key.substr(0, 6) === "posTab") {
            localStorage.removeItem(key);
        };
    });
};
clearState();

function getSelectedTabId() {
    const id = window.parseInt($(".tabs .selected.item:not(.new)").html());
    return id;
};

function loadState() {
    const id = getSelectedTabId();

    if (id) {
        loadModelById(id);
    };
};

function saveState() {
    const id = getSelectedTabId();

    if (!id) {
        window.displayMessage(window.translate("PleaseSelectTab"));
        return;
    };

    const model = window.getModel();
    const key = getLocalStorageKey(id);
    localStorage.setItem(key, JSON.stringify(model));
};

function removeState() {
    const id = getSelectedTabId();

    if (id) {
        removeModelById(id);
    };
};

function loadModelData(model) {
    if (!model) {
        return;
    };

    window.clearScreen();


    $("#TenderInputText").val(model.Tender);
    $("#ChangeInputText").val(model.Change);

    $("#PaymentTermSelect").val(model.PaymentTermId);

    $("#CheckAmountInputText").val(model.CheckAmount);
    $("#BankNameInputText").val(model.CheckBankName);
    $("#CheckNumberInputText").val(model.CheckNumber);

    if (model.CheckDate) {
        $("#CheckDateInputText").datepicker("setDate", new Date(model.CheckDate));
    };


    $("#GiftCardNumberInputText").val(model.GiftCardNumber).trigger("change");
    $("#CouponCodeInputText").val(model.CouponCode);

    $("#DiscountTypeSelect").val(model.DiscountType);

    $("#DiscountInputText").val(model.Discount);

    if (model.ValueDate) {
        $("#ValueDateInputText").datepicker("setDate", new Date(model.ValueDate));
    };

    if (model.BookDate) {
        $("#BookDateInputText").datepicker("setDate", new Date(model.BookDate));
    };

    $("#CostCenterSelect").val(model.CostCenterId);
    $("#ReferenceNumberInputText").val(model.ReferenceNumber);
    $("#StatementReferenceInputText").val(model.StatementReference);

    $("#CustomerInputText").attr("data-customer-id", model.CustomerId).val(model.CustomerCode);

    if (model.PriceTypeId) {
        $("#PriceTypeSelect").val(model.PriceTypeId);
    };

    if (model.ShipperId) {
        $("#ShipperSelect").val(model.ShipperId);
    };

    if (model.StoreId) {
        $("#StoreSelect").val(model.StoreId).attr("data-counter-id", model.CounterId).trigger("change");
    };


    $.each(model.Details, function () {
        const lineItem = this;

        const itemId = lineItem.ItemId;
        const selector = "#POSItemList .item[data-item-id=" + itemId + "]";
        $(selector).trigger("click");
    });
};

function loadModelById(id) {
    const model = getModelById(id);
    loadModelData(model);
};

function showTicket(id) {
    const url = "/dashboard/sales/ticket/" + id;

    $("#TicketIframe").attr("src", url);
    $(".ticket.panel").show();
};

function updateTenderInfo() {
    const total = window.parseFloat2($(".amount.item .money").text());
    const tender = window.parseFloat2($("#TenderInputText").val()) || 0;

    var change = window.round(tender - total, 2);

    if (change < 0) {
        $("#ChangeInputText").val("ERROR");
        return;
    };

    $("#ChangeInputText").val(window.getFormattedNumber(change));
};

$("#TenderInputText").on("keyup", function () {
    updateTenderInfo();
});

$("#CheckoutButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/sales/tasks/entry/new";
        const data = JSON.stringify(model);
        return window.getAjaxRequest(url, "POST", data);
    };

    function validate() {
        var transactionTotal = window.parseFloat2($("div.amount .money").text());
        var cashTender = window.parseFloat2($("#TenderInputText").val()) || 0;
        var paymentTerm = window.parseInt($("#PaymentTermSelect").val()) || null;
        var checkAmount = window.parseFloat2($("#CheckAmountInputText").val()) || 0;
        var bankName = $("#BankNameInputText").val();
        var checkDate = $("#CheckDateInputText").datepicker("getDate");
        var checkNumber = $("#CheckNumberInputText").val();
        var giftCardNumber = $("#GiftCardNumberInputText").val();
        var giftCardBalance = $("#GiftCardNumberBalanceInputText").val();

        if (cashTender >= transactionTotal) {
            //Cash Transaction

            $("#CheckAmountInputText").val("");
            $("#BankNameInputText").val("");
            $("#CheckDateInputText").val("");
            $("#CheckNumberInputText").val("");
            //Todo: Remove Semantic UI Dropdown dependency 
            // $("#PaymentTermSelect").dropdown("set selected", "Select");
            $("#PaymentTermSelect").val("Select");
            $("#GiftCardNumberInputText").val("");
            $("#GiftCardNumberBalanceInputText").val("");
            return true;
        };

        if (checkAmount >= transactionTotal) {
            //Paid via Check/Cheque
            if (!bankName) {
                window.displayMessage(window.translate("PleaseEnterBankName"));
                return false;
            };

            if (!checkNumber) {
                window.displayMessage(window.translate("PleaseEnterCheckNumber"));
                return false;
            };

            if (!checkDate) {
                window.displayMessage(window.translate("PleaseEnterCheckDate"));
                return false;
            };

            $("#TenderInputText").val("");
            $("#ChangeInputText").val("");
            //Todo: Remove Semantic UI Dropdown dependency 
            // $("#PaymentTermSelect").dropdown("set selected", "Select");
            $("#PaymentTermSelect").val("Select");
            $("#GiftCardNumberInputText").val("");
            $("#GiftCardNumberBalanceInputText").val("");


            return true;
        };

        if (giftCardBalance >= transactionTotal) {
            //Paid via Gift Card

            if (!giftCardNumber) {
                window.displayMessage(window.translate("PleaseEnterGiftCardNumber"));
                return false;
            };

            $("#TenderInputText").val("");
            $("#ChangeInputText").val("");
            $("#CheckAmountInputText").val("");
            $("#BankNameInputText").val("");
            $("#CheckDateInputText").val("");
            $("#CheckNumberInputText").val("");
            //Todo: Remove Semantic UI Dropdown dependency 
            // $("#PaymentTermSelect").dropdown("set selected", "Select");
            $("#PaymentTermSelect").val("Select");

            return true;
        };

        //Credit transaction
        $("#TenderInputText").val("");
        $("#ChangeInputText").val("");
        $("#CheckAmountInputText").val("");
        $("#BankNameInputText").val("");
        $("#CheckDateInputText").val("");
        $("#CheckNumberInputText").val("");
        $("#GiftCardNumberInputText").val("");
        $("#GiftCardNumberBalanceInputText").val("");

        if (!paymentTerm) {
            window.displayMessage(window.translate("PleaseSelectPaymentTerm"));
            return false;
        };

        return true;
    };

    const isValid = validate();

    if (!isValid) {
        return;
    };

    const model = window.getModel();

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

    ajax.success(function (response) {
        const id = response;
        window.clearScreen();

        window.showTicket(id);
        $("#CheckoutButton").removeClass("loading").prop("disabled", false);
    });

    ajax.fail(function (xhr) {
        $("#CheckoutButton").removeClass("loading").prop("disabled", false);
        window.displayMessage(JSON.stringify(xhr));
    });
});
