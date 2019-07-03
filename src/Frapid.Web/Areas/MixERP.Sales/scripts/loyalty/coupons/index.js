var scrudFactory = new Object();

scrudFactory.title = window.translate("DiscountCoupons");

scrudFactory.viewAPI = "/api/forms/sales/coupons";
scrudFactory.viewTableName = "sales.coupons";

scrudFactory.formAPI = "/api/forms/sales/coupons";
scrudFactory.formTableName = "sales.coupons";

scrudFactory.excludedColumns = ["AuditUserId", "AuditTs", "Deleted"];


scrudFactory.allowDelete = true;
scrudFactory.allowEdit = true;

scrudFactory.live = "CouponCode";


scrudFactory.layout = [
    {
        tab: "",
        fields: [
            ["GiftCardId", ""]
        ]
    }
];

scrudFactory.keys = [
    {
        property: "AssociatedPriceTypeId",
        url: '/api/forms/sales/price-types/display-fields',
        data: null,
        valueField: "Key",
        textField: "Value"
    },
    {
        property: "ForTicketOfPriceTypeId",
        url: '/api/forms/sales/price-types/display-fields',
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

$(document).on("formready", function () {
    $("#customer_id").change(function () {
        function request(customerId) {
            const url = '/api/forms/inventory/customers/get-where/1';

            const filters = [];
            filters.push(window.getAjaxColumnFilter("WHERE", "CustomerId", "int", window.FilterConditions.IsEqualTo, customerId));
            const data = JSON.stringify(filters);

            return window.getAjaxRequest(url, "POST", data);
        };

        function setValueByElementId(elementId, value) {
            const el = $("#" + elementId);
            const currentValue = el.val();
            if (!currentValue) {
                el.val(value);
            };
        };

        const customerId = $(this).val();

        const ajax = request(customerId);

        ajax.success(function (response) {
            if (!response || !response[0]) {
                return;
            };

            const model = response[0];

            setValueByElementId("first_name", model.contact_first_name);
            setValueByElementId("middle_name", model.contact_middle_name);
            setValueByElementId("last_name", model.contact_last_name);
            setValueByElementId("address_line_1", model.contact_address_line_1);
            setValueByElementId("address_line_2", model.contact_address_line_2);
            setValueByElementId("street", model.contact_street);
            setValueByElementId("city", model.contact_city);
            setValueByElementId("state", model.contact_state);
            setValueByElementId("country", model.contact_country);
            setValueByElementId("po_box", model.contact_po_box);
            setValueByElementId("zipcode", model.contact_zipcode);
            setValueByElementId("phone_numbers", model.contact_phone_numbers);
            setValueByElementId("fax", model.contact_fax);
        });
    });
});
