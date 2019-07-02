var model = {
    Title: window.translate("InventoryTransfers"),
    JournalAdviceExpression: function (data) {
        return null;
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

        return "/dashboard/inventory/tasks/transfers/checklist/" + tranId;
    },
    ExtraButtons: [
        {
            Title: window.translate("ViewTransfer"),
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
    AddNewUrl: "/dashboard/inventory/tasks/inventory-transfers/new",
    ReturnButtonText: "Return",
    SearchApi: "/dashboard/inventory/tasks/inventory-transfers/search",
    FormatExpression: function (cell, columnName, originalValue) {
        var value = originalValue;
        columnName = columnName.trim();

        if (!value) {
            return;
        };

        switch (columnName.trim()) {
            case "VerifiedOn":
                var date = new Date(value);
                value = window.moment(date).format("LLL");
                break;
            case "ValueDate":
            case "BookDate":
                var date = new Date(value);
                value = window.moment(date).format("LL");
                break;
            case "Amount":
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
                return new Date(x.ValueDate);
            }).ThenByDescending(function (x) {
                return new Date(x.PostedOn);
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
        }
    ]
};

function showJournalAdvice(tranId) {
    $(".modal iframe").attr("src",
        `/dashboard/reports/source/Areas/MixERP.Finance/Reports/JournalEntry.xml?transaction_master_id=${tranId}`);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};

function showDocumentModal(el) {
    el = $(el).closest("a");
    const documents = el.attr("data-documents");
    const container = $(".documents.modal");
    window.showDocuments(container, documents);

    container.modal("show");
};

function showTransfer(tranId) {
    $(".advice.modal iframe").attr("src", "/dashboard/reports/source/Areas/MixERP.Inventory/Reports/Transfer.xml?transaction_master_id=" + tranId);

    setTimeout(function () {
        $(".advice.modal")
            .modal('setting', 'transition', 'horizontal flip')
            .modal("show");

    }, 300);
};
