function displayTable(target, model) {
    target.find("tbody").html("");

    function getCell(text, isDate, hasTime) {
        const cell = $("<td />");

        cell.text(text);

        if (isDate) {
            const date = new Date(text);

            if (hasTime) {
                if ((text || "").trim()) {
                    cell.text(window.moment(date).fromNow() || "");
                    cell.attr("title", date.toLocaleString());
                };
            } else {
                cell.text(date.toLocaleDateString());
                cell.attr("title", text);
            };
        };

        return cell;
    };

    function getActionCell(tranId) {
        const cell = $("<td />");

        const checklistAnchor = $(`<a title='${window.translate("ChecklistWindow")}'><i class='list icon'></i></a>`);
        checklistAnchor.attr("href", "/dashboard/sales/tasks/entry/checklist/" + tranId);

        const journalAdviceAnchor = $(`<a title='${window.translate("ViewJournalAdvice")}'><i class='print icon'></i></a>`);
        journalAdviceAnchor.attr("href", "javascript:void(0);");
        journalAdviceAnchor.attr("onclick", "showJournalAdvice(" + tranId + ");");

        const salesAdvice = $(`<a title='${window.translate("ViewSalesInvoice")}'><i class='zoom icon'></i></a>`);
        salesAdvice.attr("href", "javascript:void(0);");


        cell.append(checklistAnchor);
        cell.append(journalAdviceAnchor);
        cell.append(salesAdvice);
        return cell;
    };

    function getSelectionCell() {
        const cell = $("<td />");
        const checkbox = $("<div class='ui toggle checkbox'/>");
        const input = $("<input type='checkbox' />");
        const label = $("<label />");

        checkbox.append(input);
        checkbox.append(label);

        cell.append(checkbox);

        return cell;
    };

    const sorted = window.Enumerable.From(model)
        .OrderByDescending(function (x) {
            return new Date(x.ValueDate);
        }).ThenByDescending(function (x) {
            return new Date(x.LastVerifiedOn);
        }).ToArray();

    $.each(sorted, function () {
        const item = this;

        const row = $("<tr />");

        row.append(getActionCell(item.TransactionMasterId));
        row.append(getSelectionCell(item.AccountMasterId));
        row.append(getCell(item.AccountMasterId));
        row.append(getCell(item.TransactionCode));
        row.append(getCell(item.ValueDate, true, false));
        row.append(getCell(item.BookDate, true, false));
        row.append(getCell(item.CustomerName));
        row.append(getCell(item.Amount));
        row.append(getCell(item.ReferenceNumber));
        row.append(getCell(item.StatementReference));
        row.append(getCell(item.PostedBy));
        row.append(getCell(item.OfficeName));
        row.append(getCell(item.Status));
        row.append(getCell(item.VerifiedBy));
        row.append(getCell(item.LastVerifiedOn, true, true));
        row.append(getCell(item.VerificationReason));

        target.find("tbody").append(row);
    });
};
function processQuery() {
    function getModel() {
        const model = window.serializeForm($("#Annotation"));

        const filters = [];

        filters.push(window.getAjaxColumnFilter("WHERE", "OfficeId", "int", window.FilterConditions.IsEqualTo, window.metaView.OfficeId));
        filters.push(window.getAjaxColumnFilter("WHERE", "ValueDate", "System.DateTime", window.FilterConditions.IsGreaterThanEqualTo, model.From));
        filters.push(window.getAjaxColumnFilter("WHERE", "ValueDate", "System.DateTime", window.FilterConditions.IsLessThanEqualTo, model.To));
        filters.push(window.getAjaxColumnFilter("WHERE", "TransactionCode", "string", window.FilterConditions.IsLike, model.TranCode));
        filters.push(window.getAjaxColumnFilter("WHERE", "CustomerName", "string", window.FilterConditions.IsLike, model.CustomerName));
        filters.push(window.getAjaxColumnFilter("WHERE", "ReferenceNumber", "string", window.FilterConditions.IsLike, model.ReferenceNumber));
        filters.push(window.getAjaxColumnFilter("WHERE", "StatementReference", "string", window.FilterConditions.IsLike, model.StatementReference));
        filters.push(window.getAjaxColumnFilter("WHERE", "PostedBy", "string", window.FilterConditions.IsLike, model.PostedBy));
        filters.push(window.getAjaxColumnFilter("WHERE", "OfficeName", "string", window.FilterConditions.IsLike, model.Office));
        filters.push(window.getAjaxColumnFilter("WHERE", "Status", "string", window.FilterConditions.IsLike, model.Status));
        filters.push(window.getAjaxColumnFilter("WHERE", "VerifiedBy", "string", window.FilterConditions.IsLike, model.VerifiedBy));
        filters.push(window.getAjaxColumnFilter("WHERE", "VerificationReason", "string", window.FilterConditions.IsLike, model.Reason));


        return filters;
    };

    function displayGrid(target) {
        function request(model) {
            const url = "/api/views/sales/gift-card-transaction-view/get-where/-1";
            const data = JSON.stringify(model);
            return window.getAjaxRequest(url, "POST", data);
        };

        const model = getModel();

        const ajax = request(model);

        ajax.success(function (response) {
            displayTable(target, response);
            target.removeClass("loading");
        });

        ajax.fail(function (xhr) {
            window.logAjaxErrorMessage(xhr);
        });
    };

    const view = $("#SalesView").addClass("loading");

    displayGrid(view);
};

$("#ShowButton").off("click").on("click", function () {
    processQuery();
});

loadDatepicker();


function showJournalAdvice(tranId) {
    $(".modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Finance/Reports/JournalEntry.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};

$("#ReturnButton").click(function () {
    function getSelectedItem() {
        const selected = $("#SalesView").find("input:checked").first();

        if (selected.length) {
            const row = selected.parent().parent().parent();
            const id = row.find("td:nth-child(3)").html();
            return window.parseInt(id);
        };

        return 0;
    };

    const selected = getSelectedItem();
    if (selected) {
        const url = "/dashboard/sales/tasks/entry/new?Type=Return&TransactionMasterId=" + selected;
        document.location = url;
        return;
    };

    window.displayMessage(window.translate("PleaseSelectItemFromGrid"));
});

setTimeout(function () {
    processQuery();
}, 1000);
