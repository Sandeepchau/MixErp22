function updateTotal() {
    const candidates = $(".denomination .ui.input.field:not(.total) input");

    var total = 0;

    $.each(candidates, function () {
        const el = $(this);
        const value = window.parseInt(el.attr("data-value")) || 0;
        const number = window.parseFloat2(el.val()) || 0;

        const result = value * number;

        total += result;
    });

    $("#SubmittedCashInputText").val(total).addClass("selected");
    $(".submitted.Amount").html(window.getFormattedNumber(total));
};

(function () {
    const candidates = $("[data-allow-edit]");

    $.each(candidates, function () {
        const el = $(this);

        const allowEdit = el.attr("data-allow-edit").toLowerCase() === "true";
        el.prop("disabled", !allowEdit);
    });

    updateTotal();
})();

$(document).ready(function () {
    window.validator.initialize($(".ui.form"));
    window.setRegionalFormat();
});

$("#SaveButton").off("click").on("click", function () {
    function request(model) {
        const url = "/dashboard/sales/tasks/eod";
        const data = JSON.stringify(model);
        return window.getAjaxRequest(url, "POST", data);
    };

    const confirmed = confirm(window.translate("AreYouSure"));

    if (!confirmed) {
        return;
    };

    const model = window.serializeForm($(".eod.cash"));
    const total = parseFloat2($("#TotalInputText").val()) || 0;//because the field is readonyl

    if (window.parseFloat(model.SubmittedCash) !== total) {
        window.displayMessage(window.translate("SubmittedAmountMustEqualTotalAmount"));
        return;
    };

    $("#SaveButton").addClass("loading").prop("disabled", true);
    const ajax = request(model);

    ajax.success(function () {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.displaySuccess();
        document.location = document.location;
    });

    ajax.fail(function (xhr) {
        $("#SaveButton").removeClass("loading").prop("disabled", false);
        window.logAjaxErrorMessage(xhr);
    });
});


$(".denomination .ui.input.field:not(.total) input").keyup(function () {
    const el = $(this);
    const value = window.parseInt(el.attr("data-value")) || 0;
    const number = window.parseFloat2(el.val()) || 0;
    const result = value * number;

    const target = el.parent().parent().find(".ui.input.total.field input");
    target.val(result);

    updateTotal();
});

$(".download.button").click(function () {
});

function getTableInText() {
    const headerCells = $("table:first thead tr th");
    const rows = $("table:first tbody tr");

    var contents = "";

    var members = [];

    $.each(headerCells, function () {
        const cell = $(this);
        members.push(cell.html());
    });

    contents += members.join(",");
    members = [];
    contents += "\n";

    $.each(rows, function () {
        const row = $(this);
        const cells = row.find("td");

        $.each(cells, function () {
            const cell = $(this);

            members.push(cell.html());
        });

        contents += members.join(",");
        contents += "\n";
        members = [];
    });

    return contents;
};


$(document).ready(function () {
    const text = getTableInText();
    const href = `data:text/plain;charset=utf-8,${encodeURIComponent(text)}`;
    $(".download.button").attr("href", href);
});