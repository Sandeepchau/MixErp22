function reprintTicket() {
    const id = $("#TicketTranIdInputText").val();

    if (!id) {
        return;
    };

    window.showTicket(id);
    $(".reprint.ticket.modal").modal("hide");
};

$("#TicketTranIdInputText").keydown(function (e) {
    const code = e.keyCode ? e.keyCode : E.which;

    if (code === 13) {
        reprintTicket();
    };
});

$("[reprint-ticket-button]").off("click").on("click", function () {
    reprintTicket();
});
