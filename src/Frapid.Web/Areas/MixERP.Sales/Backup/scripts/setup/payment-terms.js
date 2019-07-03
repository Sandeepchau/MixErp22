var scrudFactory = new Object();

scrudFactory.title = window.translate("PaymentTerms");

scrudFactory.viewAPI = "/api/views/sales/payment-term-scrud-view";
scrudFactory.viewTableName = "sales.payment_term_scrud_view";

scrudFactory.formAPI = "/api/forms/sales/payment-terms";
scrudFactory.formTableName = "sales.payment_terms";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "PaymentTermName";

scrudFactory.card = {
    header: "PaymentTermName",
    meta: "PaymentTermCode",
    description: "DueDays"
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
        property: "DueFrequencyId",
        url: '/api/views/finance/frequencies/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "LateFeeId",
        url: '/api/views/sales/late-fee/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "LateFeePostingFrequencyId",
        url: '/api/views/finance/frequencies/display-fields',
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
