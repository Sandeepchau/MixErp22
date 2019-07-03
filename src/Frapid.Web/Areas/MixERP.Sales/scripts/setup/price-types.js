var scrudFactory = new Object();

scrudFactory.title = window.translate("PriceTypes");

scrudFactory.viewAPI = "/api/forms/sales/price-types";
scrudFactory.viewTableName = "sales.price_types";

scrudFactory.formAPI = "/api/forms/sales/price-types";
scrudFactory.formTableName = "sales.price_types";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "PriceTypeName";

scrudFactory.card = {
    header: "PriceTypeName",
    description: "PriceTypeCode"
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

//scrudFactory.keys = [
//    {
//        property: "",
//        url: '/api/views/sales//display-fields',
//        data: null,
//        valueField: "Key",
//        textField: "Value"
//    }
//];



$.get('/ScrudFactory/View.html', function (view) {
    $.get('/ScrudFactory/Form.html', function (form) {
        $("#ScrudFactoryView").html(view);
        $("#ScrudFactoryForm").html(form);
        $.cachedScript("/assets/js/scrudfactory-view.js");
        $.cachedScript("/assets/js/scrudfactory-form.js");
    });
});