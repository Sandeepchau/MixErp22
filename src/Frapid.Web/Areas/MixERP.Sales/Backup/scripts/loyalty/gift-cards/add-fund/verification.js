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
        row.append(getSelectionCell(item.TransactionMasterId));
        row.append(getCell(item.TransactionMasterId));
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

    const view = $("#JournalView").addClass("loading");

    displayGrid(view);
};

$("#ShowButton")
    .unbind("click")
    .bind("click",
        function () {
            processQuery();
        });

setTimeout(function () {
    processQuery();
}, 1000);

var reasonTextArea = $("#ReasonTextArea");
var journalView = $("#JournalView");
var modal = $("#ActionModal");
var verifyButton = $("#VerifyButton");
var tranId;
var approve;

function getSelectedItem() {
    const selected = journalView.find("input:checked").first();

    if (selected.length) {
        const row = selected.parent().parent().parent();
        const id = row.find("td:nth-child(3)").html();
        return window.parseInt(id);
    };

    return 0;
};

function showModal() {
    const header = modal.find(".ui.massive.header");
    const subheader = modal.find(".ui.dividing.header");

    header.html(window.translate("RejectTransaction"));
    subheader.html(window.stringFormat("TranId: #{0}", tranId));
    header.removeClass("green").addClass("red");

    if (approve) {
        header.html(window.translate("ApproveTransaction"));
        header.removeClass("red").addClass("green");
    };

    modal.modal('setting', 'closable', false).modal('show');
};

$("#VerificationApproveButton").click(function () {
    tranId = getSelectedItem();

    if (tranId) {
        approve = true;
        showModal();
    };
});

$("#VerificationRejectButton").click(function () {
    tranId = getSelectedItem();

    if (tranId) {
        approve = false;
        showModal();
    };
});

function removeRow(index, callback) {
    journalView.find("tr").eq(index + 1).addClass("negative").fadeOut(500, function () {
        $(this).remove();

        if (typeof (callback) === "function") {
            callback();
        };
    });
};

function hideModal() {
    modal.modal("hide");
};

verifyButton.click(function () {
    function getModel() {
        const reason = reasonTextArea.val();

        return {
            TranId: tranId,
            Reason: reason
        };
    };

    function request(model, type) {
        const url = "/dashboard/loyalty/tasks/gift-cards/add-fund/verification/" + type;
        const data = JSON.stringify(model);

        return window.getAjaxRequest(url, "POST", data);
    }

    const model = getModel();
    const type = approve ? "approve" : "reject";

    const ajax = request(model, type);

    ajax.success(function (response) {
        var cascadingTranId = window.parseFloat(response);

        if (cascadingTranId) {
            journalView.find("tr td:nth-child(3)").each(function (i) {
                const tranId = window.parseFloat2($(this).text()) || 0;

                if (cascadingTranId === tranId) {
                    removeRow(i);
                };
            });
        };

        journalView.find("input:checked").first().parent().parent().parent().remove();
        hideModal();
    });

    ajax.fail(function (xhr) {
        window.logAjaxErrorMessage(xhr);
    });

    return false;
});

$(document).keyup(function (e) {
    if (e.ctrlKey) {
        const rowNumber = e.keyCode - 47;

        if (rowNumber < 10) {
            journalView.find("tr").eq(rowNumber).find("input").trigger('click');
        };
    };
});

shortcut.add("CTRL+K", function () {
    $("#ApproveButton").trigger("click");
});

shortcut.add("CTRL+RETURN", function () {
    if (modal.is(":visible")) {
        verifyButton.trigger("click");
    };
});

shortcut.add("CTRL+SHIFT+K", function () {
    $("#VerificationRejectButton").trigger("click");
});

function showInvoice(tranId) {
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};
function showJournalAdvice(tranId) {
    $(".modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Finance/Reports/JournalEntry.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};
