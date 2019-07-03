﻿var scrudFactory = new Object();

scrudFactory.title = window.translate("Customers");

scrudFactory.viewAPI = "/api/forms/inventory/customers";
scrudFactory.viewTableName = "inventory.customers";

scrudFactory.formAPI = "/api/forms/inventory/customers";
scrudFactory.formTableName = "inventory.customers";

scrudFactory.uploadHanlder = "/dashboard/inventory/services/attachments";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];
scrudFactory.hiddenColumns = ["AccountId"];

scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "CustomerName";

scrudFactory.card = {
    image: "Photo",
    header: "CustomerName",
    meta: "CustomerCode",
    description: "ContactPhoneNumbers"
};

scrudFactory.layout = [
    {
        tab: "",
        fields: [
            ["CustomerId", ""],
            ["Photo", ""],
            ["CustomerCode", "CustomerName"],
            ["CustomerTypeId", ""],
            ["Logo", ""]
        ]
    }
];

scrudFactory.keys = [
    {
        property: "CustomerTypeId",
        url: '/api/forms/inventory/customer-types/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "CurrencyCode",
        url: '/api/views/core/currencies/lookup-fields',
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
