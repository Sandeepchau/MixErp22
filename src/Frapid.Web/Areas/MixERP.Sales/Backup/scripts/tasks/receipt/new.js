window.overridePath = "/dashboard/sales/tasks/receipt";
window.loadDatepicker();
var exchangeRateLocalized = window.translate("ExchangeRateWithValue");

var receiptTypeDiv = $("#ReceiptType");

//Variables
var homeCurrency = "";

receiptTypeDiv.find(".button").click(function () {
    toggleTransactionType($(this));
});


$("#GoButton").off("click").on("click", function () {
    function getCustomerInfo(customerId) {
        function request() {
            var url = "/dashboard/sales/tasks/receipt/customer/transaction-summary/{customerId}";
            url = url.replace("{customerId}", customerId);

            return window.getAjaxRequest(url);
        };

        const ajax = request();


        ajax.success(function (response) {
            const due = response.OfficeDueAmount;
            const customerCurrency = response.CurrencyCode;

            if (!customerCurrency) {
                window.displayMessage(window.translate("ThisCustomerDoesNotHaveDefaultCurrency"));
            };

            $("#DueAmountInputText").val(due);
            $("#CurrencyInputText").val(customerCurrency);
        });

    };

    function getCurrencyInfo() {
        function request() {
            const url = "/dashboard/sales/tasks/receipt/home-currency";
            return window.getAjaxRequest(url);
        };

        const ajax = request();

        ajax.done(function (response) {
            homeCurrency = response;
            getExchangeRates();
            $("#AmountInputText").focus();
        });

        ajax.fail(function (xhr) {
            window.logAjaxErrorMessage(xhr);
        });
    };


    const customerId = $("#CustomerIdSelect").val();
    if (!customerId) {
        window.displayMessage(window.translate("PleaseSelectCustomer"));
        return;
    };


    getCurrencyInfo();
    getCustomerInfo(customerId);
});

$(document).ready(function () {
    $("#receipt").appendTo("#home");
    loadCurrencies();
    loadCustomers();
    loadCashRepositories();
    loadBankAccounts();
    loadCostCenters();
    loadCashAccounts();
});

//Control Events

$("#SaveButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/sales/tasks/receipt/new";

        const data = JSON.stringify(model);

        return window.getAjaxRequest(url, "POST", data);
    };

    function getModel() {
        const model = window.serializeForm($(".receipt.form"));
        model.CustomerId = $("#CustomerIdSelect").val();

        return model;
    };

    const model = getModel();

    $("#SaveButton").addClass("loading").prop("disabled", true);
    const ajax = request(model);

    ajax.success(function (id) {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.location = `/dashboard/sales/tasks/receipt/checklist/${id}`;
    });

    ajax.fail(function (xhr) {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.logAjaxErrorMessage(xhr);
    });
});

$("#CurrencyCodeSelect").off("change").on("change", function () {
    getExchangeRates();
});

function getExchangeRates() {
    if (exchangeRateLocalized) {
        $("label[for='DebitExchangeRateInputText']").html(window.stringFormat(exchangeRateLocalized,
            $("#CurrencyCodeSelect").val(), homeCurrency));
        $("label[for='CreditExchangeRateInputText']").html(window.stringFormat(exchangeRateLocalized, homeCurrency,
            $("#CurrencyInputText").val()));
    };

    updateExchangeRate($("#DebitExchangeRateInputText"), $("#CurrencyCodeSelect").val(), homeCurrency);
    updateExchangeRate($("#CreditExchangeRateInputText"), homeCurrency, $("#CurrencyInputText").val());
}

function updateExchangeRate(associatedControl, sourceCurrencyCode, destinationCurrencyCode) {
    function request() {
        var url = "/dashboard/sales/tasks/receipt/exchange-rate/{sourceCurrencyCode}/{destinationCurrencyCode}";
        url = url.replace("{sourceCurrencyCode}", sourceCurrencyCode);
        url = url.replace("{destinationCurrencyCode}", destinationCurrencyCode);

        return window.getAjaxRequest(url);
    };

    if (!sourceCurrencyCode || !destinationCurrencyCode) {
        return;
    };

    const ajax = request();

    ajax.success(function (response) {
        associatedControl.val(response).trigger("change");
    });
};

$("#AmountInputText").keyup(function () {
    updateTotal();
});

$("#DebitExchangeRateInputText").keyup(function () {
    updateTotal();
});

$("#CreditExchangeRateInputText").keyup(function () {
    updateTotal();
});


$("#BankAccountIdSelect").change(function () {
    loadPaymentCards();
});

$("#PaymentCardIdSelect").change(function () {
    const merchantAccountId = window.parseInt($("#BankAccountIdSelect").val() || 0);
    const paymentCardId = window.parseInt($("#PaymentCardIdSelect").val() || 0);

    $("#CustomerPaysFeeRadio").removeProp("checked");
    $("#MerchantFeeInputText").val("");

    if (!(merchantAccountId && paymentCardId)) {
        return;
    };


    const ajaxMerchantFeeSetup = getMerchantFeeSetup(merchantAccountId, paymentCardId);

    ajaxMerchantFeeSetup.success(function (msg) {

        const rate = msg.Rate;
        const customerPaysFee = msg.CustomerPaysFee;
        $("#MerchantFeeInputText").val(rate);

        if (customerPaysFee) {
            $("#CustomerPaysFeeRadio").prop("checked", "checked");
        };
    });

    ajaxMerchantFeeSetup.fail(function (xhr) {
        window.logAjaxErrorMessage(xhr);
    });

});

function updateTotal() {
    if ($("#CurrencyCodeSelect").val() === homeCurrency) {
        $("#DebitExchangeRateInputText").val("1");
    };

    if ($("#CurrencyInputText").val() === homeCurrency) {
        $("#CreditExchangeRateInputText").val("1");
    };

    const due = window.parseFloat2($("#DueAmountInputText").val() || 0);
    const amount = window.parseFloat2($("#AmountInputText").val() || 0);
    const er = window.parseFloat2($("#CreditExchangeRateInputText").val()) || 0;
    const er2 = window.parseFloat2($("#DebitExchangeRateInputText").val() || 0);

    const toHomeCurrency = window.round(amount * er, 4);

    $("#AmountInHomeCurrencyInputText").val(toHomeCurrency);

    const toBase = window.round(toHomeCurrency * er2, 4);
    const remainingDue = window.round(due - toBase, 4);

    $("#BaseAmountInputText").val(toBase);

    $("#FinalDueAmountInputText").val(remainingDue);

    $("#FinalDueAmountInputText").removeClass("alert-danger");

    if (remainingDue < 0) {
        $("#FinalDueAmountInputText").addClass("alert-danger");
    };
};

var toggleTransactionType = function (e) {
    if (e.attr("id") === "BankButton") {
        if (!$("#BankFormGroup").is(":visible")) {
            $("#BankFormGroup").show(500);
            $("#CashFormGroup").hide();
            $("#CashButton").removeClass("active");
            $("#BankButton").addClass("active");
            loadCashRepositories();
            return;
        };
    };

    if (e.attr("id") === "CashButton") {
        if (!$("#CashFormGroup").is(":visible")) {
            $("#CashFormGroup").show(500);
            $("#BankFormGroup").hide();
            loadBankAccounts();
            loadCostCenters();
            $("#PostedDateTextBox").val("");
            $("#BankInstrumentCodeInputText").val("");
            $("#BankTransactionCodeInputText").val("");
            $("#CashButton").addClass("active");
            $("#BankButton").removeClass("active");
            return;
        };
    };
};

function loadCostCenters() {
    window.displayFieldBinder($("#CostCenterIdSelect"), "/api/forms/finance/cost-centers/display-fields", true);
};

function loadCurrencies() {
    window.displayFieldBinder($("#CurrencyCodeSelect"), "/api/forms/core/currencies/lookup-fields", true);
};

function loadCustomers() {
    window.displayFieldBinder($("#CustomerIdSelect"), "/api/forms/inventory/customers/display-fields", false);
};

function loadCashRepositories() {
    window.displayFieldBinder($("#CashRepositoryIdSelect"), "/api/forms/finance/cash-repositories/display-fields", false);
};

function loadCashAccounts() {
    window.displayFieldBinder($("#CashAccountIdSelect"), "/api/views/finance/cash-account-selector-view/display-fields", false);
};

function loadBankAccounts() {
    window.displayFieldBinder($("#BankAccountIdSelect"), "/api/forms/finance/bank-accounts/display-fields", false);
};


function loadPaymentCards() {
    if (!$("#PaymentCardIdSelect option").length) {
        window.displayFieldBinder($("#PaymentCardIdSelect"), "/api/forms/finance/payment-cards/display-fields", false);
    };
};

//Ajax Requests


function getMerchantFeeSetup(merchantAccountId, paymentCardId) {
    var url = "/dashboard/sales/tasks/receipt/merchant-fee-setup/{merchantAccountId}/{paymentCardId}";
    url = url.replace("{merchantAccountId}", merchantAccountId);
    url = url.replace("{paymentCardId}", paymentCardId);

    return window.getAjaxRequest(url);
};