var data = {
    EmailAddress: ""
}
function subscribe(el) {
    function request(model) {
        var url = "/subscription/add";
        var datas = JSON.stringify(data);

        return window.getAjaxRequest(url, "POST", datas);
    };

    function validate(el) {
        var isValid = true;//window.validator.validate(el, null, true);

        var hp = el.find(".ui.confirm.email.input input").val();
        //  const emailadd = el.find(".ui.input input").val();
        if (hp) {
            isValid = false;
        };

        return isValid;
    };

    el = $(el);
    $("#ConfirmEmailAddressInputEmail").hide();
    var form = el.closest(".form");

    var isValid = validate(form);

    if (!isValid) {
        return;
    };

    form.addClass("loading");
    //var model = window.serializeForm(form);
    data.EmailAddress = $("#EmailAddressInputEmail").val();

    var ajax = request(data);

    ajax.success(function () {
        var thankYou = el.closest(".subscription").find(".thank.you");
        form.removeClass("loading").hide();
        thankYou.show();
    });

    ajax.fail(function (xhr) {
        form.removeClass("loading");
    });
};