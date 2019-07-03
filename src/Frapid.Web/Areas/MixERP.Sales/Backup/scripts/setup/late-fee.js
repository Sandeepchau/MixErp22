var scrudFactory = new Object();

scrudFactory.title = window.translate("LateFee");

scrudFactory.viewAPI = "/api/forms/sales/late-fee";
scrudFactory.viewTableName = "sales.late_fee";

scrudFactory.formAPI = "/api/forms/sales/late-fee";
scrudFactory.formTableName = "sales.late_fee";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "LateFeeName";

scrudFactory.card = {
    header: "LateFeeName",
    meta: "LateFeeCode",
    description: "Rate",
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
        property: "AccountId",
        url: '/api/forms/finance/accounts/display-fields',
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