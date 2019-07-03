var scrudFactory = new Object();

scrudFactory.title = window.translate("Customers");

scrudFactory.viewAPI = "/api/views/inventory/customer-scrud-view";
scrudFactory.viewTableName = "inventory.customers";

scrudFactory.formAPI = "/api/forms/inventory/customers";
scrudFactory.formTableName = "inventory.customers";

scrudFactory.uploadHanlder = "/dashboard/inventory/services/attachments";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];
scrudFactory.hiddenColumns = ["AccountId"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "CustomerName";


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


var selectButton = $("<button class='ui basic button' id='SelectButton'>Select & Close</button>");
var useButton = $("<button class='ui blue button' id='UseButton'>Use</button>");
var scrudSaveButtonCallback = undefined;

$.get('/ScrudFactory/View.html', function (view) {
    $.get('/ScrudFactory/Form.html', function (form) {
        $("#ScrudFactoryView").html(view);
        $("#ScrudFactoryForm").html(form);

        $(".filter.column").hide();
        $(".scrud-grid.column").removeClass("thirteen wide").addClass("sixteen wide");


        $("#AddNewButton").after(selectButton);
        $("#SaveButton").before(useButton);

        $.cachedScript("/assets/js/scrudfactory-view.js");
        $.cachedScript("/assets/js/scrudfactory-form.js");
    });
});

selectButton.click(function () {
    const customerId = window.getSelected();
    const tr = $("table#ScrudView input:checkbox:checked").first().closest("tr");
    const customerCode = tr.find("td:eq(3)").html();

    parent.onCustomerSearchSelect(customerId, customerCode);
});

useButton.click(function () {
    scrudSaveButtonCallback = function (customerId) {
        const parent = window.parent;
        parent.onCustomerSearchSelect(customerId);
    };

    $("#SaveButton").trigger("click");
});
