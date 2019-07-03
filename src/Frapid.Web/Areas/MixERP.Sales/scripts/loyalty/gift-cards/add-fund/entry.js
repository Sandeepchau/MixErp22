function loadAccounts() {

    const filters = [];
    filters.push(window.getAjaxColumnFilter("WHERE", "AccountMasterId", "int", window.FilterConditions.IsEqualTo, "10101"));//CASH
    filters.push(window.getAjaxColumnFilter("OR", "AccountMasterId", "int", window.FilterConditions.IsEqualTo, "10102"));//BANK
    filters.push(window.getAjaxColumnFilter("OR", "AccountMasterId", "int", window.FilterConditions.IsEqualTo, "10110"));//ACCOUNT RECEIVABLE

    window.displayFieldBinder($("#AccountIdSelect"), "/api/forms/finance/accounts/display-fields/get-where", true, filters);
};

function loadCostCenters() {
    window.displayFieldBinder($("#CostCenterIdSelect"), "/api/forms/finance/cost-centers/display-fields", true);
};

loadCostCenters();
loadAccounts();

var segment = $(".gift.card.fund.segment");

window.validator.initialize(segment);

$("#SaveButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/loyalty/tasks/gift-cards/add-fund/entry";
        const data = JSON.stringify(model);
        return window.getAjaxRequest(url, "POST", data);
    };

    function getModel() {
        const model = window.serializeForm(segment);
        return model;
    };

    const isValid = window.validator.validate($(".ui.form"));
    if (!isValid) {
        return;
    };

    const model = getModel();

    const ajax = request(model);

    ajax.success(function (response) {
        const id = response;
        const url = "/dashboard/loyalty/tasks/gift-cards/add-fund/checklist/" + id;

        window.location = url;
    });

    ajax.fail(function (xhr) {
        window.logAjaxErrorMessage(xhr);
    });
});

window.overridePath = "/dashboard/loyalty/tasks/gift-cards/add-fund";
