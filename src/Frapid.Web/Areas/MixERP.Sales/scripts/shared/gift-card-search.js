function showSearchResult(id) {
    $("#GiftCardNumberInputText").val(id).trigger("change").trigger("blur");
    $(".ui.gift.card.modal").modal("hide");
};

$("#SearchButton").off("click").on("click", function () {
    function displayResult(model) {
        function getCell(html) {
            const cell = $("<td />");
            cell.html(html);
            return cell;
        };

        function getActionCell(id) {
            var html = `<a onclick='showSearchResult(\"{id}\");'>${window.translate("Select")}</a>`;
            html = html.replace("{id}", id);

            const cell = $("<td />");
            cell.html(html);
            return cell;
        };

        var target = $(".results.table tbody").html("");

        $.each(model, function () {
            const row = $("<tr />");
            row.append(getActionCell(this.GiftCardNumber));
            row.append(getCell(this.GiftCardNumber));
            row.append(getCell(this.Name));
            row.append(getCell(this.PhoneNumbers));
            row.append(getCell(this.Address));
            row.append(getCell(this.City));
            row.append(getCell(this.State));
            row.append(getCell(this.Country));
            row.append(getCell(this.ZipCode));
            row.append(getCell(this.PoBox));

            target.append(row);
        });
    };

    function request(model) {
        const url = "/dashboard/loyalty/tasks/gift-cards/search";
        const data = JSON.stringify(model);

        return window.getAjaxRequest(url, "POST", data);
    }

    const model = window.serializeForm($(".ui.search.form"));

    const ajax = request(model);

    ajax.success(function (response) {
        displayResult(response);
    });

    ajax.fail(function (xhr) {
        window.logAjaxErrorMessage(xhr);
    });
});