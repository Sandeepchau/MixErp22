var scrudFactory = new Object();

scrudFactory.title = window.translate("Cashiers");

scrudFactory.viewAPI = "/api/views/sales/cashier-scrud-view";
scrudFactory.viewTableName = "sales.cashier_scrud_view";

scrudFactory.formAPI = "/api/forms/sales/cashiers";
scrudFactory.formTableName = "sales.cashiers";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "CashierCode";

scrudFactory.card = {
    header: "AssociatedUser",
    meta: "CashierCode",
    description: "Counter"
};

//scrudFactory.layout = [
//    {
//        tab: "",
//        fields: [
//            ["", ""],
//            ["", ""],
//        ]
//    }
//];

scrudFactory.keys = [
    {
        property: "CounterId",
        url: '/api/forms/inventory/counters/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "AssociatedUserId",
        url: '/api/views/account/user-selector-view/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    }
];



$.get('/ScrudFactory/View.html', function (view) {
    $.get('/ScrudFactory/Form.html', function (form) {
        $("#ScrudFactoryView").html(view);
        $("#ScrudFactoryForm").html(form);
        $.cachedScript("/assets/js/scrudfactory-view.js");
        $.cachedScript("/assets/js/scrudfactory-form.js");
    });
});
