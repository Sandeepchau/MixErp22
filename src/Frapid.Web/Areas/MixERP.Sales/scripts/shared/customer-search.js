$("#SearchCustomerAction").click(function () {
    $(".customer.search.modal").modal("show");
});

function onCustomerSearchSelect(customerId, customerCode) {
    if (customerId) {
        $(".customer.search.modal").modal("hide");

        $("#CustomerInputText").attr("data-customer-id", customerId).val(customerCode);
    };
};