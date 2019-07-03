var scrudFactory = new Object();

scrudFactory.title = window.translate("CustomerTypes");

scrudFactory.viewAPI = "/api/forms/inventory/customer-types";
scrudFactory.viewTableName = "inventory.customer_types";

scrudFactory.formAPI = "/api/forms/inventory/customer-types";
scrudFactory.formTableName = "inventory.customer_types";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "CustomerTypeName";

scrudFactory.card = {
    header: "CustomerTypeName",
    meta: "CustomerTypeCode",
    description: "AccountId"

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

