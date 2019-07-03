﻿var model = {
    Title: window.translate("Sales"),
    JournalAdviceExpression: function (data) {
        const tranId = data.TranId;
        if (!tranId) {
            return null;
        }

        return tranId;
    },
    DocumentExpression: function (data) {
        const documents = data.Documents;
        if (!documents) {
            return null;
        };

        return documents;
    },
    ChecklistUrlExpression: function (data) {
        const tranId = data.TranId;
        if (!tranId) {
            return null;
        };

        return "/dashboard/sales/tasks/entry/checklist/" + tranId;
    },
    ExtraButtons: [
        {
            Title: window.translate("ViewSalesInvoice"),
            Icon: "zoom",
            ClickExpression: function (data) {
                const tranId = data.TranId;
                if (!tranId) {
                    return null;
                };


                return "showInvoice(" + tranId + ");";
            }
        }
    ],
    AddNewButtonText: window.translate("AddNew"),
    AddNewUrl: "/dashboard/sales/tasks/entry/new",
    ReturnButtonText: "Return",
    SearchApi: "/dashboard/sales/tasks/entry/search",
    FormatExpression: function (cell, columnName, originalValue) {
        var value = originalValue;
        columnName = columnName.trim();

        if (!value) {
            return;
        };

        switch (columnName.trim()) {
            case "PostedOn":
                var date = new Date(value);
                value = window.moment(date).format("LLL");
                break;
            case "ValueDate":
            case "BookDate":
                var date = new Date(value);
                value = window.moment(date).format("LL");
                break;
            case "TotalAmount":
                value = window.getFormattedCurrency(value);
                break;
        };

        if (originalValue !== value) {
            cell.attr("title", originalValue);
        };

        cell.text(value);
        cell.attr("data-date", value).addClass("date");
    },
    SortExpression: function (data) {
        return window.Enumerable.From(data)
            .OrderByDescending(function (x) {
                return parseInt(x.InvoiceNumber);
            }).ToArray();
    },
    Annotation: [
        {
            Text: "From",
            Id: "From",
            CssClass: "date"
        },
        {
            Text: "To",
            Id: "To",
            CssClass: "date"
        },
        {
            Text: "Tran Id",
            Id: "TranId"
        },
        {
            Text: "Transaction Code",
            Id: "TranCode"
        },
        {
            Text: "Reference Number",
            Id: "ReferenceNumber"
        },
        {
            Text: "Statement Reference",
            Id: "StatementReference"
        },
        {
            Text: "Posted By",
            Id: "PostedBy"
        },
        {
            Text: "Office",
            Id: "Office"
        },
        {
            Text: "Status",
            Id: "Status"
            //DefaultValue: "Unverified"
        },
        {
            Text: "Verified By",
            Id: "VerifiedBy"
        },
        {
            Text: "Reason",
            Id: "Reason"
        },
        {
            Text: "Amount",
            Id: "Amount",
            CssClass: "currency"
        },
        {
            Text: "Customer",
            Id: "Customer"
        }
    ]
};

function showJournalAdvice(tranId) {
    debugger;
    $(".modal iframe").attr("src",
        `/dashboard/reports/source/Areas/MixERP.Finance/Reports/JournalEntry.xml?transaction_master_id=${tranId}`);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};

function showDocumentModal(el) {
    debugger;
    el = $(el).closest("a");
    const documents = el.attr("data-documents");
    const container = $(".documents.modal");
    window.showDocuments(container, documents);

    container.modal("show");
};

function showInvoice(tranId) {
    debugger;
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Sales/Reports/Invoice.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};

$("#ReturnButton").click(function () {
    debugger;
    function getSelectedItem() {
        const selected = $("#SearchView").find("input:checked").first();

        if (selected.length) {
            const row = selected.parent().parent().parent();
            const id = row.find("td:nth-child(3)").html();
            return window.parseInt(id);
        };

        return 0;
    };

    const selected = getSelectedItem();
    if (selected) {
        const url = "/dashboard/sales/tasks/return/new?Type=Return&TransactionMasterId=" + selected;
        document.location = url;
        return;
    };

    window.displayMessage(window.translate("PleaseSelectItemFromGrid"));
});