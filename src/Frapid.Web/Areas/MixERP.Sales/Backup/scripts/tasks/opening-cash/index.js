(function () {
    const candidates = $("[data-allow-edit]");

    $.each(candidates, function () {
        const el = $(this);

        const allowEdit = el.attr("data-allow-edit").toLowerCase() === "true";
        el.prop("disabled", !allowEdit);
    });
})();

$(document).ready(function () {
    window.validator.initialize($(".ui.form"));
    window.setRegionalFormat();
});


$("#SaveButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/sales/tasks/opening-cash";
        const data = JSON.stringify(model);
        return window.getAjaxRequest(url, "POST", data);
    };

    const confirmed = confirm(window.translate("AreYouSure"));
    if (!confirmed) {
        return;
    };

    const model = window.serializeForm($(".ui.form"));
    $("#SaveButton").addClass("loading").prop("disabled", true);
    const ajax = request(model);

    ajax.success(function () {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.displaySuccess();
    });

    ajax.fail(function (xhr) {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.logAjaxErrorMessage(xhr);
    });
});