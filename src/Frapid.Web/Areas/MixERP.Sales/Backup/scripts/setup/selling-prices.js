var scrudFactory = new Object();

scrudFactory.title = window.translate("SellingPrices");

scrudFactory.viewAPI = "/api/views/sales/item-selling-price-scrud_view";
scrudFactory.viewTableName = "sales.item_selling_price_scrud_view";

scrudFactory.formAPI = "/api/forms/sales/item-selling-prices";
scrudFactory.formTableName = "sales.item_selling_prices";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;


scrudFactory.card = {
    header: "Item",
    meta: "Unit",
    description: "Price"
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
        property: "ItemId",
        url: '/api/forms/inventory/items/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "UnitId",
        url: '/api/forms/inventory/units/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "CustomerTypeId",
        url: '/api/forms/inventory/customer-types/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "PriceTypeId",
        url: '/api/views/sales/price-types/display-fields',
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
