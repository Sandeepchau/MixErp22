function deleteRow(el, isCard) {
    debugger;
    function request(primaryKeyValue) {
        var url = window.scrudFactory.formAPI + "/delete/" + primaryKeyValue;
        return getAjaxRequest(url, "DELETE");
    };
    debugger;
    var confirmed = confirmAction();

    if (!confirmed) {
        return;
    };

    var primaryKeyValue = getPrimaryKeyValue($(el), isCard);


    if (typeof (window.scrudFactory.deleteHandler) === "function") {
        //debugger;
        window.scrudFactory.deleteHandler(primaryKeyValue);
        return;
    };

    var ajax = request(primaryKeyValue);

    ajax.success(function () {
        loadPageCount(loadGrid);
    });
};