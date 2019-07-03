const numberOfItemsToDisplay = 20;

var itemTemplate =
    `<div class="item" id="pos-{ItemId}" data-selling-price="{InvariantCultureSellingPrice}" data-photo="{Photo}" data-unit-id="{UnitId}" data-valid-units="{ValidUnits}" data-brand="{BrandName}" data-item-group="{ItemGroupName}" data-item-name="{ItemName}" data-item-code="{ItemCode}" data-item-id="{ItemId}" data-price="{Price}" data-is-taxable-item="{IsTaxableItem}">
	<div class="photo block">
		<img src="{Photo}">
	</div>
	<div class="info block">
		<div class="header">{ItemName}</div>
		<div class="price info">
			<span class ="rate">{SellingPrice}</span>
			<span>&nbsp; x&nbsp; </span>
			<span class="quantity">1</span>
			<span>&nbsp; =&nbsp; </span>
			<span class="amount"></span>
		</div>
		<div class="discount info" style="display:none;">
			<span>${window.translate("Less")}&nbsp; </span>
			<span class="discount rate"></span>
			<span>&nbsp; =&nbsp; </span>
			<span class="discounted amount"></span>
		</div>
		<div>
			<select class="unit inverted" data-item-id="{ItemId}">
			</select>
		</div>
	</div>
	<div class="number block">
		<input type="text" class ="decimal price" title="${window.translate("EditPrice")}" value="{SellingPrice}">
		<input type="text" class="decimal quantity" title="${window.translate("EnterQuantity")}" value="1">
		<input type="text" class ="decimal discount" title="${window.translate("EnterRateDiscount")}" value="">
		<button class ="ui red fluid button" onclick="removeItem(this);" style="display:none;">${window.translate("Delete")}</button>
	</div>
</div>`;

var products = [];
var metaUnits = [];

function defaulPOSItemClick(el, callback) {
    var targetEl = $("#SalesItems");

    $(".tender.info.items").hide();
    $(".footer.items").show();
    targetEl.show();

    var sellingPrice = window.parseFloat(el.attr("data-selling-price")) || 0;
    var photo = el.attr("data-photo") || "";

    var barCode = el.attr("data-barcode");
    var brand = el.attr("data-brand");
    var unitId = window.parseInt(el.attr("data-unit-id"));
    var validUnits = el.attr("data-valid-units");
    var itemGroup = el.attr("data-item-group");
    var itemName = el.attr("data-item-name");
    var itemCode = el.attr("data-item-code");
    var itemId = window.parseInt(el.attr("data-item-id"));
    var isTaxableItem = el.attr("data-is-taxable-item") === "true";
    var taxRate = window.parseFloat($("#SalesTaxRateHidden").val()) || 0;

    var price = sellingPrice;

    if (!price) {
        window.displayMessage(window.translate("CannotAddItemBecausePriceIsZero"));
        return;
    };



    var selector = "pos-" + itemId;
    var existingEl = $("#" + selector);

    if (existingEl.length) {
        var existingQuantitySpan = existingEl.find("span.quantity");
        var existingQuantityInput = existingEl.find("input.quantity");

        var quantity = window.parseFloat2(existingQuantitySpan.text()) || 0;
        quantity++;

        existingQuantitySpan.text(quantity);
        existingQuantityInput.val(quantity).trigger("keyup");

        window.updateTotal();
        return;
    };

    var template = itemTemplate;

    template = template.replace(/{ItemId}/g, itemId);
    template = template.replace(/{SellingPrice}/g, window.getFormattedNumber(sellingPrice));
    template = template.replace(/{InvariantCultureSellingPrice}/g, sellingPrice);
    template = template.replace(/{Photo}/g, photo);
    template = template.replace(/{BarCode}/g, barCode);
    template = template.replace(/{BrandName}/g, brand);
    template = template.replace(/{ItemGroupName}/g, itemGroup);
    template = template.replace(/{ItemName}/g, itemName);
    template = template.replace(/{ItemCode}/g, itemCode);
    template = template.replace(/{Price}/g, price);
    template = template.replace(/{UnitId}/g, unitId);
    template = template.replace(/{ValidUnits}/g, validUnits);
    template = template.replace(/{IsTaxableItem}/g, isTaxableItem.toString());

    var item = $(template);
    var quantityInput = item.find("input.quantity");
    var priceInput = item.find("input.price");
    var discountInput = item.find("input.discount");
    var unitSelect = item.find("select.unit");

    function loadUnits(el, defaultUnitId, validUnits) {
        el.html("");

        const units = window.Enumerable.From(window.metaUnits)
            .Where(function (x) {
                return validUnits.indexOf(x.UnitId.toString()) > -1;
            }).ToArray();

        $.each(units, function () {
            const unit = this;

            const option = $("<option/>");
            option.attr("value", unit.UnitId);
            option.html(unit.UnitName);

            if (defaultUnitId === unit.UnitId) {
                option.attr("selected", "");
            };

            option.appendTo(el);
        });

    };

    loadUnits(unitSelect, unitId, validUnits.split(','));

    function updateItemInfo(el) {
        window.setRegionalFormat();
        const quantityEl = el.find("input.quantity");
        const discountEl = el.find("input.discount");

        const quantity = window.parseFloat2(quantityEl.val()) || 0;
        const discountRate = window.parseFloat2(discountEl.val()) || 0;

        const price = window.parseFloat2(el.find("input.price").val()) || 0;

        const amount = window.round(price * quantity, 2);
        const discountedAmount = window.round((price * quantity) * ((100 - discountRate) / 100), 2);

        el.find("span.rate:not(.discount)").html(window.getFormattedNumber(price));
        el.find("span.quantity").html(window.getFormattedNumber(quantity));
        el.find("span.amount").html(window.getFormattedNumber(amount));
        el.find("span.discount.rate").html("");
        el.find("span.discounted.amount").html("");

        el.find("span.discount.rate").html(window.getFormattedNumber(discountEl.val().replace("%", "")) + "%");
        el.find("span.discounted.amount").html(window.getFormattedNumber(discountedAmount));

        if (discountRate) {
            el.find(".discount.info").show();
        } else {
            el.find(".discount.info").hide();
        };

        window.updateTotal();
    };

    quantityInput.on("keyup", function () {
        const el = $(this);
        const parentInfo = el.parent().parent();
        updateItemInfo(parentInfo);
    });

    discountInput.on("keyup", function () {
        const el = $(this);

        const rate = window.parseFloat2(el.val()) || 0;
        if (rate > 100) {
            el.val("100");
            return;
        };

        const parentInfo = el.parent().parent();
        updateItemInfo(parentInfo);
    });

    priceInput.on("keyup", function () {
        const el = $(this);
        const parentInfo = el.parent().parent();
        updateItemInfo(parentInfo);
    });

    discountInput.on("blur", function () {
        const el = $(this);
        const value = el.val();

        if (!value) {
            return;
        };

        if (value.substr(value.length - 1) === "%") {
            return;
        };

        el.val(el.val() + "%");
        const parentInfo = el.parent().parent();
        updateItemInfo(parentInfo);
    });

    function getPrice(el) {
        function request(itemId, customerId, priceTypeId, unitId) {
            var url = "/dashboard/sales/tasks/selling-price/{itemId}/{customerId}/{priceTypeId}/{unitId}";
            url = url.replace("{itemId}", itemId);
            url = url.replace("{customerId}", customerId);
            url = url.replace("{priceTypeId}", priceTypeId);
            url = url.replace("{unitId}", unitId);

            return window.getAjaxRequest(url);
        };

        const itemId = el.attr("data-item-id");
        const customerId = window.parseInt($("#CustomerInputText").attr("data-customer-id")) || 0;
        const priceTypeId = window.parseInt($("#PriceTypeSelect").val()) || 0;
        const unitId = el.val();

        $(".action.panel.segment").addClass("loading");
        const ajax = request(itemId, customerId, priceTypeId, unitId);

        ajax.success(function (response) {
            $(".action.panel.segment").removeClass("loading");
            const priceInput = el.parent().parent().parent().find("input.price");
            priceInput.val(response).trigger("keyup");
        });

        ajax.fail(function (xhr) {
            $(".action.panel.segment").removeClass("loading");
            console.log(window.getAjaxErrorMessage(xhr));
        });
    };

    unitSelect.on("change", function () {
        getPrice($(this));
    });

    item.on("contextmenu", function (e) {
        e.preventDefault();
        const el = $(this);
        const inputEl = el.find(".number.block input");
        const buttonEl = el.find(".number.block button");

        inputEl.toggle();
        buttonEl.toggle();
    });

    item.appendTo(targetEl);
    quantityInput.trigger("keyup");
    window.setRegionalFormat();
    window.updateTotal();

    var tabId = window.getSelectedTabId();
    var triggerName = "itemAdded";

    $(document).trigger(triggerName, [tabId, itemId, item]);

    if (typeof (callback) === "function") {
        callback(el);
    };

    if (typeof (window.itemClickCallBack) === "function") {
        window.itemClickCallBack(itemId, item);
    };
};

function initializeClickAndAction() {
    $("#POSItemList .item").off("click").on("click", function () {
        const el = $(this);

        defaulPOSItemClick(el);
    });
};

function fetchUnits() {
    function request() {
        const url = "/api/forms/inventory/units/all";
        return window.getAjaxRequest(url);
    };

    const ajax = request();

    ajax.success(function (response) {
        window.metaUnits = response;
    });
};

function fetchProducts() {
    function request() {
        const url = "/dashboard/sales/tasks/items";
        return window.getAjaxRequest(url);
    };

    const ajax = request();

    ajax.success(function (response) {
        window.products = response;
        $(document).trigger("itemFetched");
    });
};

$(".search.panel input").keyup(function () {
    const el = $(this);
    const term = el.val();

    const categoryEl = $(".category.list .selected.category");
    var category = "";

    if (categoryEl.length) {
        category = categoryEl.text();
    };

    window.displayProducts(category, term);

    initializeClickAndAction();
});

$(".search.panel input").keydown(function (e) {
    if (e.keyCode === 13) {
        const item = $(".item.list .item:first");

        if (item.length) {
            item.trigger("click");
        };
    };
});

window.fetchUnits();
window.fetchProducts();

$(document).on("itemFetched", function () {
    $("#POSDimmer").removeClass("active");
    displayProducts();
    displayCategories();
    initializeClickAndAction();
});

function displayCategories() {
    const categories = window.Enumerable.From(products).Distinct(function (x) { return x.ItemGroupName }).Select(function (x) { return x.ItemGroupName }).ToArray();
    var targetEl = $(".cat.filter");
    $(".category.list").find(".category").remove();

    targetEl.off("click").on("click", function () {
        displayProducts();
        $(".category").removeClass("selected");
        targetEl.hide();
        initializeClickAndAction();
    });

    $.each(categories, function () {
        const category = $("<div class='category' />");
        category.html(this);

        category.off("click").on("click", function () {
            $(".search.panel input").val("");
            const el = $(this);
            const name = el.text();

            if (name) {
                displayProducts(name);
                $(".category").removeClass("selected");
                el.addClass("selected");

                targetEl.show();
            } else {
                targetEl.hide();
            };

            initializeClickAndAction();
        });

        targetEl.before(category);
    });
};

function displayProducts(category, searchQuery) {
    debugger;
    var target = $("#POSItemList");
    var groupItems;

    if (!category && !searchQuery) {
        groupItems = window.Enumerable
            .From(products).Take(numberOfItemsToDisplay).ToArray();
    } else {
        if (category && searchQuery) {
            groupItems = window.Enumerable
                .From(products)
                .Where(function (x) {
                    return x.ItemGroupName.toLowerCase() === category.toString().toLowerCase()
                        &&
                        (
                            x.ItemName.toLowerCase().indexOf(searchQuery.toLowerCase()) > -1
                                ||
                                x.Barcode.toLowerCase().indexOf(searchQuery.toLowerCase()) > -1
                        );
                }).Take(numberOfItemsToDisplay).ToArray();
        } else if (!category && searchQuery) {
            groupItems = window.Enumerable
                .From(products)
                .Where(function (x) {
                    return x.ItemName.toLowerCase().indexOf(searchQuery.toLowerCase()) > -1
                        ||
                        x.Barcode.toLowerCase().indexOf(searchQuery.toLowerCase()) > -1;
                }).Take(numberOfItemsToDisplay).ToArray();
        } else {
            groupItems = window.Enumerable
                .From(products)
                .Where(function (x) {
                    return x.ItemGroupName.toLowerCase() === category.toString().toLowerCase();
                }).Take(numberOfItemsToDisplay).ToArray();
        };
    };


    target.html("").hide();

    groupItems = window.Enumerable.From(groupItems).OrderBy(function (x) { return x.ItemId; }).ToArray();


    $.each(groupItems, function () {
        const product = this;

        var sellingPrice = product.SellingPrice;

        if (product.SellingPriceIncludesTax) {
            sellingPrice = (100 * sellingPrice) / (100 + window.parseFloat(product.SalesTaxRate));
            sellingPrice = window.round(sellingPrice, 2);
        };

        const item = $("<div class='item' />");
        item.attr("data-item-id", product.ItemId);
        item.attr("data-item-code", product.ItemCode);
        item.attr("data-item-name", product.ItemName);
        item.attr("data-item-group", product.ItemGroupName);
        item.attr("data-brand", product.BrandName);
        item.attr("data-unit-id", product.UnitId);
        item.attr("data-valid-units", product.ValidUnits);
        item.attr("data-barcode", product.Barcode);
        item.attr("data-photo", product.Photo);
        item.attr("data-is-taxable-item", product.IsTaxableItem);
        item.attr("data-selling-price", sellingPrice);
        item.attr("data-selling-price-includes-tax", product.SellingPriceIncludesTax);

        if (product.HotItem) {
            item.addClass("hot");
        };

        const info = $("<div class='info' />");

        const price = $("<div class='price' />");
        price.html(window.getFormattedNumber(sellingPrice));

        price.appendTo(info);


        const photo = $("<div class='photo' />");

        if (product.Photo) {
            const img = $("<img />");
            img.attr("src", product.Photo + "?Height=200&Width=200");

            img.appendTo(photo);
        };

        photo.appendTo(info);

        const name = $("<div class='name' />");
        name.html(product.ItemName);

        name.appendTo(info);

        info.appendTo(item);
        item.appendTo(target);
    });

    if (searchQuery) {
        target.show();
        return;
    };

    target.fadeIn(500);
};
