using System.Collections.Generic;
using System.Globalization;
using Frapid.Configuration;
using Frapid.i18n;

namespace MixERP.Inventory
{
	public sealed class Localize : ILocalize
	{
		public Dictionary<string, string> GetResources(CultureInfo culture)
		{
			string resourceDirectory = I18N.ResourceDirectory;
			return I18NResource.GetResources(resourceDirectory, culture);
		}
	}

	public static class I18N
	{
		public static string ResourceDirectory { get; }

		static I18N()
		{
			ResourceDirectory = PathMapper.MapPath("/Areas/MixERP.Inventory/i18n");
		}

		/// <summary>
		///Inventory
		/// </summary>
		public static string Inventory => I18NResource.GetString(ResourceDirectory, "Inventory");

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Address Line 1
		/// </summary>
		public static string AddressLine1 => I18NResource.GetString(ResourceDirectory, "AddressLine1");

		/// <summary>
		///Address Line 2
		/// </summary>
		public static string AddressLine2 => I18NResource.GetString(ResourceDirectory, "AddressLine2");

		/// <summary>
		///Allow Multiple Opening Inventory
		/// </summary>
		public static string AllowMultipleOpeningInventory => I18NResource.GetString(ResourceDirectory, "AllowMultipleOpeningInventory");

		/// <summary>
		///Allow Purchase
		/// </summary>
		public static string AllowPurchase => I18NResource.GetString(ResourceDirectory, "AllowPurchase");

		/// <summary>
		///Allow Sales
		/// </summary>
		public static string AllowSales => I18NResource.GetString(ResourceDirectory, "AllowSales");

		/// <summary>
		///Amount
		/// </summary>
		public static string Amount => I18NResource.GetString(ResourceDirectory, "Amount");

		/// <summary>
		///Attribute Code
		/// </summary>
		public static string AttributeCode => I18NResource.GetString(ResourceDirectory, "AttributeCode");

		/// <summary>
		///Attribute Id
		/// </summary>
		public static string AttributeId => I18NResource.GetString(ResourceDirectory, "AttributeId");

		/// <summary>
		///Attribute Name
		/// </summary>
		public static string AttributeName => I18NResource.GetString(ResourceDirectory, "AttributeName");

		/// <summary>
		///Attribute Value
		/// </summary>
		public static string AttributeValue => I18NResource.GetString(ResourceDirectory, "AttributeValue");

		/// <summary>
		///Audit Ts
		/// </summary>
		public static string AuditTs => I18NResource.GetString(ResourceDirectory, "AuditTs");

		/// <summary>
		///Audit User Id
		/// </summary>
		public static string AuditUserId => I18NResource.GetString(ResourceDirectory, "AuditUserId");

		/// <summary>
		///Authorization Reason
		/// </summary>
		public static string AuthorizationReason => I18NResource.GetString(ResourceDirectory, "AuthorizationReason");

		/// <summary>
		///Authorized
		/// </summary>
		public static string Authorized => I18NResource.GetString(ResourceDirectory, "Authorized");

		/// <summary>
		///Authorized By User Id
		/// </summary>
		public static string AuthorizedByUserId => I18NResource.GetString(ResourceDirectory, "AuthorizedByUserId");

		/// <summary>
		///Authorized On
		/// </summary>
		public static string AuthorizedOn => I18NResource.GetString(ResourceDirectory, "AuthorizedOn");

		/// <summary>
		///Barcode
		/// </summary>
		public static string Barcode => I18NResource.GetString(ResourceDirectory, "Barcode");

		/// <summary>
		///Base Quantity
		/// </summary>
		public static string BaseQuantity => I18NResource.GetString(ResourceDirectory, "BaseQuantity");

		/// <summary>
		///Base Unit Code
		/// </summary>
		public static string BaseUnitCode => I18NResource.GetString(ResourceDirectory, "BaseUnitCode");

		/// <summary>
		///Base Unit Id
		/// </summary>
		public static string BaseUnitId => I18NResource.GetString(ResourceDirectory, "BaseUnitId");

		/// <summary>
		///Base Unit Name
		/// </summary>
		public static string BaseUnitName => I18NResource.GetString(ResourceDirectory, "BaseUnitName");

		/// <summary>
		///Batch Number
		/// </summary>
		public static string BatchNumber => I18NResource.GetString(ResourceDirectory, "BatchNumber");

		/// <summary>
		///Book
		/// </summary>
		public static string Book => I18NResource.GetString(ResourceDirectory, "Book");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Brand Code
		/// </summary>
		public static string BrandCode => I18NResource.GetString(ResourceDirectory, "BrandCode");

		/// <summary>
		///Brand Id
		/// </summary>
		public static string BrandId => I18NResource.GetString(ResourceDirectory, "BrandId");

		/// <summary>
		///Brand Name
		/// </summary>
		public static string BrandName => I18NResource.GetString(ResourceDirectory, "BrandName");

		/// <summary>
		///Cancellation Reason
		/// </summary>
		public static string CancellationReason => I18NResource.GetString(ResourceDirectory, "CancellationReason");

		/// <summary>
		///Cancelled
		/// </summary>
		public static string Cancelled => I18NResource.GetString(ResourceDirectory, "Cancelled");

		/// <summary>
		///Cell
		/// </summary>
		public static string Cell => I18NResource.GetString(ResourceDirectory, "Cell");

		/// <summary>
		///Checkout Detail Id
		/// </summary>
		public static string CheckoutDetailId => I18NResource.GetString(ResourceDirectory, "CheckoutDetailId");

		/// <summary>
		///Checkout Id
		/// </summary>
		public static string CheckoutId => I18NResource.GetString(ResourceDirectory, "CheckoutId");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Cogs Calculation Method
		/// </summary>
		public static string CogsCalculationMethod => I18NResource.GetString(ResourceDirectory, "CogsCalculationMethod");

		/// <summary>
		///Company Address Line 1
		/// </summary>
		public static string CompanyAddressLine1 => I18NResource.GetString(ResourceDirectory, "CompanyAddressLine1");

		/// <summary>
		///Company Address Line 2
		/// </summary>
		public static string CompanyAddressLine2 => I18NResource.GetString(ResourceDirectory, "CompanyAddressLine2");

		/// <summary>
		///Company City
		/// </summary>
		public static string CompanyCity => I18NResource.GetString(ResourceDirectory, "CompanyCity");

		/// <summary>
		///Company Country
		/// </summary>
		public static string CompanyCountry => I18NResource.GetString(ResourceDirectory, "CompanyCountry");

		/// <summary>
		///Company Fax
		/// </summary>
		public static string CompanyFax => I18NResource.GetString(ResourceDirectory, "CompanyFax");

		/// <summary>
		///Company Name
		/// </summary>
		public static string CompanyName => I18NResource.GetString(ResourceDirectory, "CompanyName");

		/// <summary>
		///Company Phone Numbers
		/// </summary>
		public static string CompanyPhoneNumbers => I18NResource.GetString(ResourceDirectory, "CompanyPhoneNumbers");

		/// <summary>
		///Company Po Box
		/// </summary>
		public static string CompanyPoBox => I18NResource.GetString(ResourceDirectory, "CompanyPoBox");

		/// <summary>
		///Company State
		/// </summary>
		public static string CompanyState => I18NResource.GetString(ResourceDirectory, "CompanyState");

		/// <summary>
		///Company Street
		/// </summary>
		public static string CompanyStreet => I18NResource.GetString(ResourceDirectory, "CompanyStreet");

		/// <summary>
		///Company Zip Code
		/// </summary>
		public static string CompanyZipCode => I18NResource.GetString(ResourceDirectory, "CompanyZipCode");

		/// <summary>
		///Compare Unit Id
		/// </summary>
		public static string CompareUnitId => I18NResource.GetString(ResourceDirectory, "CompareUnitId");

		/// <summary>
		///Compare Unit Name
		/// </summary>
		public static string CompareUnitName => I18NResource.GetString(ResourceDirectory, "CompareUnitName");

		/// <summary>
		///Compound Unit Id
		/// </summary>
		public static string CompoundUnitId => I18NResource.GetString(ResourceDirectory, "CompoundUnitId");

		/// <summary>
		///Contact Address Line 1
		/// </summary>
		public static string ContactAddressLine1 => I18NResource.GetString(ResourceDirectory, "ContactAddressLine1");

		/// <summary>
		///Contact Address Line 2
		/// </summary>
		public static string ContactAddressLine2 => I18NResource.GetString(ResourceDirectory, "ContactAddressLine2");

		/// <summary>
		///Contact Cell
		/// </summary>
		public static string ContactCell => I18NResource.GetString(ResourceDirectory, "ContactCell");

		/// <summary>
		///Contact City
		/// </summary>
		public static string ContactCity => I18NResource.GetString(ResourceDirectory, "ContactCity");

		/// <summary>
		///Contact Country
		/// </summary>
		public static string ContactCountry => I18NResource.GetString(ResourceDirectory, "ContactCountry");

		/// <summary>
		///Contact Email
		/// </summary>
		public static string ContactEmail => I18NResource.GetString(ResourceDirectory, "ContactEmail");

		/// <summary>
		///Contact Fax
		/// </summary>
		public static string ContactFax => I18NResource.GetString(ResourceDirectory, "ContactFax");

		/// <summary>
		///Contact First Name
		/// </summary>
		public static string ContactFirstName => I18NResource.GetString(ResourceDirectory, "ContactFirstName");

		/// <summary>
		///Contact Last Name
		/// </summary>
		public static string ContactLastName => I18NResource.GetString(ResourceDirectory, "ContactLastName");

		/// <summary>
		///Contact Middle Name
		/// </summary>
		public static string ContactMiddleName => I18NResource.GetString(ResourceDirectory, "ContactMiddleName");

		/// <summary>
		///Contact Person
		/// </summary>
		public static string ContactPerson => I18NResource.GetString(ResourceDirectory, "ContactPerson");

		/// <summary>
		///Contact Phone
		/// </summary>
		public static string ContactPhone => I18NResource.GetString(ResourceDirectory, "ContactPhone");

		/// <summary>
		///Contact Phone Numbers
		/// </summary>
		public static string ContactPhoneNumbers => I18NResource.GetString(ResourceDirectory, "ContactPhoneNumbers");

		/// <summary>
		///Contact Po Box
		/// </summary>
		public static string ContactPoBox => I18NResource.GetString(ResourceDirectory, "ContactPoBox");

		/// <summary>
		///Contact State
		/// </summary>
		public static string ContactState => I18NResource.GetString(ResourceDirectory, "ContactState");

		/// <summary>
		///Contact Street
		/// </summary>
		public static string ContactStreet => I18NResource.GetString(ResourceDirectory, "ContactStreet");

		/// <summary>
		///Contact Zip Code
		/// </summary>
		public static string ContactZipCode => I18NResource.GetString(ResourceDirectory, "ContactZipCode");

		/// <summary>
		///Cost Center Id
		/// </summary>
		public static string CostCenterId => I18NResource.GetString(ResourceDirectory, "CostCenterId");

		/// <summary>
		///Cost Of Goods Sold
		/// </summary>
		public static string CostOfGoodsSold => I18NResource.GetString(ResourceDirectory, "CostOfGoodsSold");

		/// <summary>
		///Cost Of Goods Sold Account Id
		/// </summary>
		public static string CostOfGoodsSoldAccountId => I18NResource.GetString(ResourceDirectory, "CostOfGoodsSoldAccountId");

		/// <summary>
		///Cost Price
		/// </summary>
		public static string CostPrice => I18NResource.GetString(ResourceDirectory, "CostPrice");

		/// <summary>
		///Cost Price Includes Tax
		/// </summary>
		public static string CostPriceIncludesTax => I18NResource.GetString(ResourceDirectory, "CostPriceIncludesTax");

		/// <summary>
		///Counter Code
		/// </summary>
		public static string CounterCode => I18NResource.GetString(ResourceDirectory, "CounterCode");

		/// <summary>
		///Counter Id
		/// </summary>
		public static string CounterId => I18NResource.GetString(ResourceDirectory, "CounterId");

		/// <summary>
		///Counter Name
		/// </summary>
		public static string CounterName => I18NResource.GetString(ResourceDirectory, "CounterName");

		/// <summary>
		///Country
		/// </summary>
		public static string Country => I18NResource.GetString(ResourceDirectory, "Country");

		/// <summary>
		///Cst Number
		/// </summary>
		public static string CstNumber => I18NResource.GetString(ResourceDirectory, "CstNumber");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

		/// <summary>
		///Customer
		/// </summary>
		public static string Customer => I18NResource.GetString(ResourceDirectory, "Customer");

		/// <summary>
		///Customer Code
		/// </summary>
		public static string CustomerCode => I18NResource.GetString(ResourceDirectory, "CustomerCode");

		/// <summary>
		///Customer Id
		/// </summary>
		public static string CustomerId => I18NResource.GetString(ResourceDirectory, "CustomerId");

		/// <summary>
		///Customer Name
		/// </summary>
		public static string CustomerName => I18NResource.GetString(ResourceDirectory, "CustomerName");

		/// <summary>
		///Customer Type
		/// </summary>
		public static string CustomerType => I18NResource.GetString(ResourceDirectory, "CustomerType");

		/// <summary>
		///Customer Type Code
		/// </summary>
		public static string CustomerTypeCode => I18NResource.GetString(ResourceDirectory, "CustomerTypeCode");

		/// <summary>
		///Customer Type Id
		/// </summary>
		public static string CustomerTypeId => I18NResource.GetString(ResourceDirectory, "CustomerTypeId");

		/// <summary>
		///Customer Type Name
		/// </summary>
		public static string CustomerTypeName => I18NResource.GetString(ResourceDirectory, "CustomerTypeName");

		/// <summary>
		///Default Account Id For Checks
		/// </summary>
		public static string DefaultAccountIdForChecks => I18NResource.GetString(ResourceDirectory, "DefaultAccountIdForChecks");

		/// <summary>
		///Default Cash Account Id
		/// </summary>
		public static string DefaultCashAccountId => I18NResource.GetString(ResourceDirectory, "DefaultCashAccountId");

		/// <summary>
		///Default Cash Repository Id
		/// </summary>
		public static string DefaultCashRepositoryId => I18NResource.GetString(ResourceDirectory, "DefaultCashRepositoryId");

		/// <summary>
		///Default Discount Account Id
		/// </summary>
		public static string DefaultDiscountAccountId => I18NResource.GetString(ResourceDirectory, "DefaultDiscountAccountId");

		/// <summary>
		///Deleted
		/// </summary>
		public static string Deleted => I18NResource.GetString(ResourceDirectory, "Deleted");

		/// <summary>
		///Delivered
		/// </summary>
		public static string Delivered => I18NResource.GetString(ResourceDirectory, "Delivered");

		/// <summary>
		///Delivered By User Id
		/// </summary>
		public static string DeliveredByUserId => I18NResource.GetString(ResourceDirectory, "DeliveredByUserId");

		/// <summary>
		///Delivered On
		/// </summary>
		public static string DeliveredOn => I18NResource.GetString(ResourceDirectory, "DeliveredOn");

		/// <summary>
		///Delivery Date
		/// </summary>
		public static string DeliveryDate => I18NResource.GetString(ResourceDirectory, "DeliveryDate");

		/// <summary>
		///Delivery Memo
		/// </summary>
		public static string DeliveryMemo => I18NResource.GetString(ResourceDirectory, "DeliveryMemo");

		/// <summary>
		///Destination Store Id
		/// </summary>
		public static string DestinationStoreId => I18NResource.GetString(ResourceDirectory, "DestinationStoreId");

		/// <summary>
		///Discount
		/// </summary>
		public static string Discount => I18NResource.GetString(ResourceDirectory, "Discount");

		/// <summary>
		///Discount Rate
		/// </summary>
		public static string DiscountRate => I18NResource.GetString(ResourceDirectory, "DiscountRate");

		/// <summary>
		///Email
		/// </summary>
		public static string Email => I18NResource.GetString(ResourceDirectory, "Email");

		/// <summary>
		///Exclude From Purchase
		/// </summary>
		public static string ExcludeFromPurchase => I18NResource.GetString(ResourceDirectory, "ExcludeFromPurchase");

		/// <summary>
		///Exclude From Sales
		/// </summary>
		public static string ExcludeFromSales => I18NResource.GetString(ResourceDirectory, "ExcludeFromSales");

		/// <summary>
		///Expiry Date
		/// </summary>
		public static string ExpiryDate => I18NResource.GetString(ResourceDirectory, "ExpiryDate");

		/// <summary>
		///Factory Address
		/// </summary>
		public static string FactoryAddress => I18NResource.GetString(ResourceDirectory, "FactoryAddress");

		/// <summary>
		///Fax
		/// </summary>
		public static string Fax => I18NResource.GetString(ResourceDirectory, "Fax");

		/// <summary>
		///Hot Item
		/// </summary>
		public static string HotItem => I18NResource.GetString(ResourceDirectory, "HotItem");

		/// <summary>
		///Inventory Account Id
		/// </summary>
		public static string InventoryAccountId => I18NResource.GetString(ResourceDirectory, "InventoryAccountId");

		/// <summary>
		///Inventory System
		/// </summary>
		public static string InventorySystem => I18NResource.GetString(ResourceDirectory, "InventorySystem");

		/// <summary>
		///Inventory Transfer Delivery Detail Id
		/// </summary>
		public static string InventoryTransferDeliveryDetailId => I18NResource.GetString(ResourceDirectory, "InventoryTransferDeliveryDetailId");

		/// <summary>
		///Inventory Transfer Delivery Id
		/// </summary>
		public static string InventoryTransferDeliveryId => I18NResource.GetString(ResourceDirectory, "InventoryTransferDeliveryId");

		/// <summary>
		///Inventory Transfer Request Detail Id
		/// </summary>
		public static string InventoryTransferRequestDetailId => I18NResource.GetString(ResourceDirectory, "InventoryTransferRequestDetailId");

		/// <summary>
		///Inventory Transfer Request Id
		/// </summary>
		public static string InventoryTransferRequestId => I18NResource.GetString(ResourceDirectory, "InventoryTransferRequestId");

		/// <summary>
		///Is Component
		/// </summary>
		public static string IsComponent => I18NResource.GetString(ResourceDirectory, "IsComponent");

		/// <summary>
		///Is Taxable Item
		/// </summary>
		public static string IsTaxableItem => I18NResource.GetString(ResourceDirectory, "IsTaxableItem");

		/// <summary>
		///Is Taxed
		/// </summary>
		public static string IsTaxed => I18NResource.GetString(ResourceDirectory, "IsTaxed");

		/// <summary>
		///Is Variant Of
		/// </summary>
		public static string IsVariantOf => I18NResource.GetString(ResourceDirectory, "IsVariantOf");

		/// <summary>
		///Item Code
		/// </summary>
		public static string ItemCode => I18NResource.GetString(ResourceDirectory, "ItemCode");

		/// <summary>
		///Item Group Code
		/// </summary>
		public static string ItemGroupCode => I18NResource.GetString(ResourceDirectory, "ItemGroupCode");

		/// <summary>
		///Item Group Id
		/// </summary>
		public static string ItemGroupId => I18NResource.GetString(ResourceDirectory, "ItemGroupId");

		/// <summary>
		///Item Group Name
		/// </summary>
		public static string ItemGroupName => I18NResource.GetString(ResourceDirectory, "ItemGroupName");

		/// <summary>
		///Item Id
		/// </summary>
		public static string ItemId => I18NResource.GetString(ResourceDirectory, "ItemId");

		/// <summary>
		///Item Name
		/// </summary>
		public static string ItemName => I18NResource.GetString(ResourceDirectory, "ItemName");

		/// <summary>
		///Item Type Code
		/// </summary>
		public static string ItemTypeCode => I18NResource.GetString(ResourceDirectory, "ItemTypeCode");

		/// <summary>
		///Item Type Id
		/// </summary>
		public static string ItemTypeId => I18NResource.GetString(ResourceDirectory, "ItemTypeId");

		/// <summary>
		///Item Type Name
		/// </summary>
		public static string ItemTypeName => I18NResource.GetString(ResourceDirectory, "ItemTypeName");

		/// <summary>
		///Item Variant Id
		/// </summary>
		public static string ItemVariantId => I18NResource.GetString(ResourceDirectory, "ItemVariantId");

		/// <summary>
		///Last Verified On
		/// </summary>
		public static string LastVerifiedOn => I18NResource.GetString(ResourceDirectory, "LastVerifiedOn");

		/// <summary>
		///Lead Time In Days
		/// </summary>
		public static string LeadTimeInDays => I18NResource.GetString(ResourceDirectory, "LeadTimeInDays");

		/// <summary>
		///Login Id
		/// </summary>
		public static string LoginId => I18NResource.GetString(ResourceDirectory, "LoginId");

		/// <summary>
		///Logo
		/// </summary>
		public static string Logo => I18NResource.GetString(ResourceDirectory, "Logo");

		/// <summary>
		///Maintain Inventory
		/// </summary>
		public static string MaintainInventory => I18NResource.GetString(ResourceDirectory, "MaintainInventory");

		/// <summary>
		///Nontaxable Total
		/// </summary>
		public static string NontaxableTotal => I18NResource.GetString(ResourceDirectory, "NontaxableTotal");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Pan Number
		/// </summary>
		public static string PanNumber => I18NResource.GetString(ResourceDirectory, "PanNumber");

		/// <summary>
		///Parent Item Group Id
		/// </summary>
		public static string ParentItemGroupId => I18NResource.GetString(ResourceDirectory, "ParentItemGroupId");

		/// <summary>
		///Phone
		/// </summary>
		public static string Phone => I18NResource.GetString(ResourceDirectory, "Phone");

		/// <summary>
		///Photo
		/// </summary>
		public static string Photo => I18NResource.GetString(ResourceDirectory, "Photo");

		/// <summary>
		///Po Box
		/// </summary>
		public static string PoBox => I18NResource.GetString(ResourceDirectory, "PoBox");

		/// <summary>
		///Posted By
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Preferred Supplier Id
		/// </summary>
		public static string PreferredSupplierId => I18NResource.GetString(ResourceDirectory, "PreferredSupplierId");

		/// <summary>
		///Price
		/// </summary>
		public static string Price => I18NResource.GetString(ResourceDirectory, "Price");

		/// <summary>
		///Purchase Account Id
		/// </summary>
		public static string PurchaseAccountId => I18NResource.GetString(ResourceDirectory, "PurchaseAccountId");

		/// <summary>
		///Purchase Discount Account Id
		/// </summary>
		public static string PurchaseDiscountAccountId => I18NResource.GetString(ResourceDirectory, "PurchaseDiscountAccountId");

		/// <summary>
		///Quantity
		/// </summary>
		public static string Quantity => I18NResource.GetString(ResourceDirectory, "Quantity");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Receipt Memo
		/// </summary>
		public static string ReceiptMemo => I18NResource.GetString(ResourceDirectory, "ReceiptMemo");

		/// <summary>
		///Received
		/// </summary>
		public static string Received => I18NResource.GetString(ResourceDirectory, "Received");

		/// <summary>
		///Received By User Id
		/// </summary>
		public static string ReceivedByUserId => I18NResource.GetString(ResourceDirectory, "ReceivedByUserId");

		/// <summary>
		///Received On
		/// </summary>
		public static string ReceivedOn => I18NResource.GetString(ResourceDirectory, "ReceivedOn");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Rejected
		/// </summary>
		public static string Rejected => I18NResource.GetString(ResourceDirectory, "Rejected");

		/// <summary>
		///Rejected By User Id
		/// </summary>
		public static string RejectedByUserId => I18NResource.GetString(ResourceDirectory, "RejectedByUserId");

		/// <summary>
		///Rejected On
		/// </summary>
		public static string RejectedOn => I18NResource.GetString(ResourceDirectory, "RejectedOn");

		/// <summary>
		///Rejection Reason
		/// </summary>
		public static string RejectionReason => I18NResource.GetString(ResourceDirectory, "RejectionReason");

		/// <summary>
		///Reorder Level
		/// </summary>
		public static string ReorderLevel => I18NResource.GetString(ResourceDirectory, "ReorderLevel");

		/// <summary>
		///Reorder Quantity
		/// </summary>
		public static string ReorderQuantity => I18NResource.GetString(ResourceDirectory, "ReorderQuantity");

		/// <summary>
		///Reorder Unit Id
		/// </summary>
		public static string ReorderUnitId => I18NResource.GetString(ResourceDirectory, "ReorderUnitId");

		/// <summary>
		///Request Date
		/// </summary>
		public static string RequestDate => I18NResource.GetString(ResourceDirectory, "RequestDate");

		/// <summary>
		///Sales Account Id
		/// </summary>
		public static string SalesAccountId => I18NResource.GetString(ResourceDirectory, "SalesAccountId");

		/// <summary>
		///Sales Discount Account Id
		/// </summary>
		public static string SalesDiscountAccountId => I18NResource.GetString(ResourceDirectory, "SalesDiscountAccountId");

		/// <summary>
		///Sales Return Account Id
		/// </summary>
		public static string SalesReturnAccountId => I18NResource.GetString(ResourceDirectory, "SalesReturnAccountId");

		/// <summary>
		///Sales Transaction Id
		/// </summary>
		public static string SalesTransactionId => I18NResource.GetString(ResourceDirectory, "SalesTransactionId");

		/// <summary>
		///Selling Price
		/// </summary>
		public static string SellingPrice => I18NResource.GetString(ResourceDirectory, "SellingPrice");

		/// <summary>
		///Selling Price Includes Tax
		/// </summary>
		public static string SellingPriceIncludesTax => I18NResource.GetString(ResourceDirectory, "SellingPriceIncludesTax");

		/// <summary>
		///Serial Number
		/// </summary>
		public static string SerialNumber => I18NResource.GetString(ResourceDirectory, "SerialNumber");

		/// <summary>
		///Serial Number Id
		/// </summary>
		public static string SerialNumberId => I18NResource.GetString(ResourceDirectory, "SerialNumberId");

		/// <summary>
		///Shipper Code
		/// </summary>
		public static string ShipperCode => I18NResource.GetString(ResourceDirectory, "ShipperCode");

		/// <summary>
		///Shipper Id
		/// </summary>
		public static string ShipperId => I18NResource.GetString(ResourceDirectory, "ShipperId");

		/// <summary>
		///Shipper Name
		/// </summary>
		public static string ShipperName => I18NResource.GetString(ResourceDirectory, "ShipperName");

		/// <summary>
		///Shipping Charge
		/// </summary>
		public static string ShippingCharge => I18NResource.GetString(ResourceDirectory, "ShippingCharge");

		/// <summary>
		///Shipping Expense Account Id
		/// </summary>
		public static string ShippingExpenseAccountId => I18NResource.GetString(ResourceDirectory, "ShippingExpenseAccountId");

		/// <summary>
		///Sst Number
		/// </summary>
		public static string SstNumber => I18NResource.GetString(ResourceDirectory, "SstNumber");

		/// <summary>
		///State
		/// </summary>
		public static string State => I18NResource.GetString(ResourceDirectory, "State");

		/// <summary>
		///Statement Reference
		/// </summary>
		public static string StatementReference => I18NResource.GetString(ResourceDirectory, "StatementReference");

		/// <summary>
		///Status
		/// </summary>
		public static string Status => I18NResource.GetString(ResourceDirectory, "Status");

		/// <summary>
		///Store Code
		/// </summary>
		public static string StoreCode => I18NResource.GetString(ResourceDirectory, "StoreCode");

		/// <summary>
		///Store Id
		/// </summary>
		public static string StoreId => I18NResource.GetString(ResourceDirectory, "StoreId");

		/// <summary>
		///Store Name
		/// </summary>
		public static string StoreName => I18NResource.GetString(ResourceDirectory, "StoreName");

		/// <summary>
		///Store Type Code
		/// </summary>
		public static string StoreTypeCode => I18NResource.GetString(ResourceDirectory, "StoreTypeCode");

		/// <summary>
		///Store Type Id
		/// </summary>
		public static string StoreTypeId => I18NResource.GetString(ResourceDirectory, "StoreTypeId");

		/// <summary>
		///Store Type Name
		/// </summary>
		public static string StoreTypeName => I18NResource.GetString(ResourceDirectory, "StoreTypeName");

		/// <summary>
		///Street
		/// </summary>
		public static string Street => I18NResource.GetString(ResourceDirectory, "Street");

		/// <summary>
		///Supplier Code
		/// </summary>
		public static string SupplierCode => I18NResource.GetString(ResourceDirectory, "SupplierCode");

		/// <summary>
		///Supplier Id
		/// </summary>
		public static string SupplierId => I18NResource.GetString(ResourceDirectory, "SupplierId");

		/// <summary>
		///Supplier Name
		/// </summary>
		public static string SupplierName => I18NResource.GetString(ResourceDirectory, "SupplierName");

		/// <summary>
		///Supplier Type Code
		/// </summary>
		public static string SupplierTypeCode => I18NResource.GetString(ResourceDirectory, "SupplierTypeCode");

		/// <summary>
		///Supplier Type Id
		/// </summary>
		public static string SupplierTypeId => I18NResource.GetString(ResourceDirectory, "SupplierTypeId");

		/// <summary>
		///Supplier Type Name
		/// </summary>
		public static string SupplierTypeName => I18NResource.GetString(ResourceDirectory, "SupplierTypeName");

		/// <summary>
		///Tax
		/// </summary>
		public static string Tax => I18NResource.GetString(ResourceDirectory, "Tax");

		/// <summary>
		///Tax Rate
		/// </summary>
		public static string TaxRate => I18NResource.GetString(ResourceDirectory, "TaxRate");

		/// <summary>
		///Taxable Total
		/// </summary>
		public static string TaxableTotal => I18NResource.GetString(ResourceDirectory, "TaxableTotal");

		/// <summary>
		///Total
		/// </summary>
		public static string Total => I18NResource.GetString(ResourceDirectory, "Total");

		/// <summary>
		///Tran Code
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///Tran Id
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///Transaction Book
		/// </summary>
		public static string TransactionBook => I18NResource.GetString(ResourceDirectory, "TransactionBook");

		/// <summary>
		///Transaction Code
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///Transaction Counter
		/// </summary>
		public static string TransactionCounter => I18NResource.GetString(ResourceDirectory, "TransactionCounter");

		/// <summary>
		///Transaction Master Id
		/// </summary>
		public static string TransactionMasterId => I18NResource.GetString(ResourceDirectory, "TransactionMasterId");

		/// <summary>
		///Transaction Timestamp
		/// </summary>
		public static string TransactionTimestamp => I18NResource.GetString(ResourceDirectory, "TransactionTimestamp");

		/// <summary>
		///Transaction Ts
		/// </summary>
		public static string TransactionTs => I18NResource.GetString(ResourceDirectory, "TransactionTs");

		/// <summary>
		///Transaction Type
		/// </summary>
		public static string TransactionType => I18NResource.GetString(ResourceDirectory, "TransactionType");

		/// <summary>
		///Unit Code
		/// </summary>
		public static string UnitCode => I18NResource.GetString(ResourceDirectory, "UnitCode");

		/// <summary>
		///Unit Id
		/// </summary>
		public static string UnitId => I18NResource.GetString(ResourceDirectory, "UnitId");

		/// <summary>
		///Unit Name
		/// </summary>
		public static string UnitName => I18NResource.GetString(ResourceDirectory, "UnitName");

		/// <summary>
		///Url
		/// </summary>
		public static string Url => I18NResource.GetString(ResourceDirectory, "Url");

		/// <summary>
		///Use Pos Checkout Screen
		/// </summary>
		public static string UsePosCheckoutScreen => I18NResource.GetString(ResourceDirectory, "UsePosCheckoutScreen");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Valid Units
		/// </summary>
		public static string ValidUnits => I18NResource.GetString(ResourceDirectory, "ValidUnits");

		/// <summary>
		///Value
		/// </summary>
		public static string Value => I18NResource.GetString(ResourceDirectory, "Value");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Variant Code
		/// </summary>
		public static string VariantCode => I18NResource.GetString(ResourceDirectory, "VariantCode");

		/// <summary>
		///Variant Id
		/// </summary>
		public static string VariantId => I18NResource.GetString(ResourceDirectory, "VariantId");

		/// <summary>
		///Variant Name
		/// </summary>
		public static string VariantName => I18NResource.GetString(ResourceDirectory, "VariantName");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verification Status Id
		/// </summary>
		public static string VerificationStatusId => I18NResource.GetString(ResourceDirectory, "VerificationStatusId");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified By User Id
		/// </summary>
		public static string VerifiedByUserId => I18NResource.GetString(ResourceDirectory, "VerifiedByUserId");

		/// <summary>
		///Tasks
		/// </summary>
		public static string Tasks => I18NResource.GetString(ResourceDirectory, "Tasks");

		/// <summary>
		///Inventory Transfers
		/// </summary>
		public static string InventoryTransfers => I18NResource.GetString(ResourceDirectory, "InventoryTransfers");

		/// <summary>
		///Inventory Adjustments
		/// </summary>
		public static string InventoryAdjustments => I18NResource.GetString(ResourceDirectory, "InventoryAdjustments");

		/// <summary>
		///Inventory Transfer Verification
		/// </summary>
		public static string InventoryTransferVerification => I18NResource.GetString(ResourceDirectory, "InventoryTransferVerification");

		/// <summary>
		///Inventory Adjustment Verification
		/// </summary>
		public static string InventoryAdjustmentVerification => I18NResource.GetString(ResourceDirectory, "InventoryAdjustmentVerification");

		/// <summary>
		///Setup
		/// </summary>
		public static string Setup => I18NResource.GetString(ResourceDirectory, "Setup");

		/// <summary>
		///Inventory Items
		/// </summary>
		public static string InventoryItems => I18NResource.GetString(ResourceDirectory, "InventoryItems");

		/// <summary>
		///Item Groups
		/// </summary>
		public static string ItemGroups => I18NResource.GetString(ResourceDirectory, "ItemGroups");

		/// <summary>
		///Item Types
		/// </summary>
		public static string ItemTypes => I18NResource.GetString(ResourceDirectory, "ItemTypes");

		/// <summary>
		///Store Types
		/// </summary>
		public static string StoreTypes => I18NResource.GetString(ResourceDirectory, "StoreTypes");

		/// <summary>
		///Stores
		/// </summary>
		public static string Stores => I18NResource.GetString(ResourceDirectory, "Stores");

		/// <summary>
		///Counters
		/// </summary>
		public static string Counters => I18NResource.GetString(ResourceDirectory, "Counters");

		/// <summary>
		///Customer Types
		/// </summary>
		public static string CustomerTypes => I18NResource.GetString(ResourceDirectory, "CustomerTypes");

		/// <summary>
		///Supplier Types
		/// </summary>
		public static string SupplierTypes => I18NResource.GetString(ResourceDirectory, "SupplierTypes");

		/// <summary>
		///Customers
		/// </summary>
		public static string Customers => I18NResource.GetString(ResourceDirectory, "Customers");

		/// <summary>
		///Suppliers
		/// </summary>
		public static string Suppliers => I18NResource.GetString(ResourceDirectory, "Suppliers");

		/// <summary>
		///Brands
		/// </summary>
		public static string Brands => I18NResource.GetString(ResourceDirectory, "Brands");

		/// <summary>
		///Units of Measure
		/// </summary>
		public static string UnitsOfMeasure => I18NResource.GetString(ResourceDirectory, "UnitsOfMeasure");

		/// <summary>
		///Compound Units of Measure
		/// </summary>
		public static string CompoundUnitsOfMeasure => I18NResource.GetString(ResourceDirectory, "CompoundUnitsOfMeasure");

		/// <summary>
		///Shippers
		/// </summary>
		public static string Shippers => I18NResource.GetString(ResourceDirectory, "Shippers");

		/// <summary>
		///Attributes
		/// </summary>
		public static string Attributes => I18NResource.GetString(ResourceDirectory, "Attributes");

		/// <summary>
		///Variants
		/// </summary>
		public static string Variants => I18NResource.GetString(ResourceDirectory, "Variants");

		/// <summary>
		///Item Variants
		/// </summary>
		public static string ItemVariants => I18NResource.GetString(ResourceDirectory, "ItemVariants");

		/// <summary>
		///Opening Inventories
		/// </summary>
		public static string OpeningInventories => I18NResource.GetString(ResourceDirectory, "OpeningInventories");

		/// <summary>
		///Opening Inventory Verification
		/// </summary>
		public static string OpeningInventoryVerification => I18NResource.GetString(ResourceDirectory, "OpeningInventoryVerification");

		/// <summary>
		///Reports
		/// </summary>
		public static string Reports => I18NResource.GetString(ResourceDirectory, "Reports");

		/// <summary>
		///Inventory Account Statement
		/// </summary>
		public static string InventoryAccountStatement => I18NResource.GetString(ResourceDirectory, "InventoryAccountStatement");

		/// <summary>
		///Physical Count
		/// </summary>
		public static string PhysicalCount => I18NResource.GetString(ResourceDirectory, "PhysicalCount");

		/// <summary>
		///Customer Contacts
		/// </summary>
		public static string CustomerContacts => I18NResource.GetString(ResourceDirectory, "CustomerContacts");

		/// <summary>
		///Low Inventory Report
		/// </summary>
		public static string LowInventoryReport => I18NResource.GetString(ResourceDirectory, "LowInventoryReport");

		/// <summary>
		///Profit Status by Item
		/// </summary>
		public static string ProfitStatusByItem => I18NResource.GetString(ResourceDirectory, "ProfitStatusByItem");

		/// <summary>
		///Inventory Daily Report
		/// </summary>
		public static string InventoryDailyReport => I18NResource.GetString(ResourceDirectory, "InventoryDailyReport");

		/// <summary>
		///Action
		/// </summary>
		public static string Action => I18NResource.GetString(ResourceDirectory, "Action");

		/// <summary>
		///Actions
		/// </summary>
		public static string Actions => I18NResource.GetString(ResourceDirectory, "Actions");

		/// <summary>
		///Actual
		/// </summary>
		public static string Actual => I18NResource.GetString(ResourceDirectory, "Actual");

		/// <summary>
		///Add
		/// </summary>
		public static string Add => I18NResource.GetString(ResourceDirectory, "Add");

		/// <summary>
		///Add New
		/// </summary>
		public static string AddNew => I18NResource.GetString(ResourceDirectory, "AddNew");

		/// <summary>
		///Add New Adjustment
		/// </summary>
		public static string AddNewAdjustment => I18NResource.GetString(ResourceDirectory, "AddNewAdjustment");

		/// <summary>
		///Add a New Opening Inventory
		/// </summary>
		public static string AddNewOpeningInventory => I18NResource.GetString(ResourceDirectory, "AddNewOpeningInventory");

		/// <summary>
		///Add New Transfer
		/// </summary>
		public static string AddNewTransfer => I18NResource.GetString(ResourceDirectory, "AddNewTransfer");

		/// <summary>
		///Approve
		/// </summary>
		public static string Approve => I18NResource.GetString(ResourceDirectory, "Approve");

		/// <summary>
		///Approve Transaction
		/// </summary>
		public static string ApproveTransaction => I18NResource.GetString(ResourceDirectory, "ApproveTransaction");

		/// <summary>
		///Are you sure?
		/// </summary>
		public static string AreYouSure => I18NResource.GetString(ResourceDirectory, "AreYouSure");

		/// <summary>
		///Attribute
		/// </summary>
		public static string Attribute => I18NResource.GetString(ResourceDirectory, "Attribute");

		/// <summary>
		///Back
		/// </summary>
		public static string Back => I18NResource.GetString(ResourceDirectory, "Back");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///Cannot add item because the price is zero.
		/// </summary>
		public static string CannotAddItemBecausePriceZero => I18NResource.GetString(ResourceDirectory, "CannotAddItemBecausePriceZero");

		/// <summary>
		///Cannot create this item because you must specify a single variant of "{0}" attribute.
		/// </summary>
		public static string CannotCreateItemBecauseYouMustSpecifySingleVariantAttribute => I18NResource.GetString(ResourceDirectory, "CannotCreateItemBecauseYouMustSpecifySingleVariantAttribute");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///ChecklistWindow
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Checkout
		/// </summary>
		public static string Checkout => I18NResource.GetString(ResourceDirectory, "Checkout");

		/// <summary>
		///Clear
		/// </summary>
		public static string Clear => I18NResource.GetString(ResourceDirectory, "Clear");

		/// <summary>
		///Cls
		/// </summary>
		public static string Cls => I18NResource.GetString(ResourceDirectory, "Cls");

		/// <summary>
		///CTRL + RETURN
		/// </summary>
		public static string CtrlPlusReturn => I18NResource.GetString(ResourceDirectory, "CtrlPlusReturn");

		/// <summary>
		///CurrentArea
		/// </summary>
		public static string CurrentArea => I18NResource.GetString(ResourceDirectory, "CurrentArea");

		/// <summary>
		///Current Branch Office
		/// </summary>
		public static string CurrentBranchOffice => I18NResource.GetString(ResourceDirectory, "CurrentBranchOffice");

		/// <summary>
		///Delete
		/// </summary>
		public static string Delete => I18NResource.GetString(ResourceDirectory, "Delete");

		/// <summary>
		///Difference
		/// </summary>
		public static string Difference => I18NResource.GetString(ResourceDirectory, "Difference");

		/// <summary>
		///Doing something ...
		/// </summary>
		public static string DoingSomething => I18NResource.GetString(ResourceDirectory, "DoingSomething");

		/// <summary>
		///Duplicate Entry
		/// </summary>
		public static string DuplicateEntry => I18NResource.GetString(ResourceDirectory, "DuplicateEntry");

		/// <summary>
		///Edit Price
		/// </summary>
		public static string EditPrice => I18NResource.GetString(ResourceDirectory, "EditPrice");

		/// <summary>
		///Enter Quantity
		/// </summary>
		public static string EnterQuantity => I18NResource.GetString(ResourceDirectory, "EnterQuantity");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportDoc => I18NResource.GetString(ResourceDirectory, "ExportDoc");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportDocument => I18NResource.GetString(ResourceDirectory, "ExportDocument");

		/// <summary>
		///Export to Excel
		/// </summary>
		public static string ExportExcel => I18NResource.GetString(ResourceDirectory, "ExportExcel");

		/// <summary>
		///Export to PDF
		/// </summary>
		public static string ExportPdf => I18NResource.GetString(ResourceDirectory, "ExportPdf");

		/// <summary>
		///FIFO (First In/First Out)
		/// </summary>
		public static string FIFO => I18NResource.GetString(ResourceDirectory, "FIFO");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

		/// <summary>
		///Get Me out of Here
		/// </summary>
		public static string GetMeOutOfHere => I18NResource.GetString(ResourceDirectory, "GetMeOutOfHere");

		/// <summary>
		///Gridview is empty!
		/// </summary>
		public static string GridviewEmpty => I18NResource.GetString(ResourceDirectory, "GridviewEmpty");

		/// <summary>
		///In
		/// </summary>
		public static string In => I18NResource.GetString(ResourceDirectory, "In");

		/// <summary>
		///Invalid Date!
		/// </summary>
		public static string InvalidDate => I18NResource.GetString(ResourceDirectory, "InvalidDate");

		/// <summary>
		///Invalid Store!
		/// </summary>
		public static string InvalidStore => I18NResource.GetString(ResourceDirectory, "InvalidStore");

		/// <summary>
		///Inventory Adjustment
		/// </summary>
		public static string InventoryAdjustment => I18NResource.GetString(ResourceDirectory, "InventoryAdjustment");

		/// <summary>
		///Inventory Adjustment Checklist
		/// </summary>
		public static string InventoryAdjustmentChecklist => I18NResource.GetString(ResourceDirectory, "InventoryAdjustmentChecklist");

		/// <summary>
		///Inventory Setup
		/// </summary>
		public static string InventorySetup => I18NResource.GetString(ResourceDirectory, "InventorySetup");

		/// <summary>
		///Please do not change anything here before consulting with your CPA first. Please proceed with extreme caution.
		/// </summary>
		public static string InventorySetupWarning => I18NResource.GetString(ResourceDirectory, "InventorySetupWarning");

		/// <summary>
		///Inventory Transfer
		/// </summary>
		public static string InventoryTransfer => I18NResource.GetString(ResourceDirectory, "InventoryTransfer");

		/// <summary>
		///Item Varients
		/// </summary>
		public static string ItemVarients => I18NResource.GetString(ResourceDirectory, "ItemVarients");

		/// <summary>
		///I Understand the Risks
		/// </summary>
		public static string IUnderstandTheRisks => I18NResource.GetString(ResourceDirectory, "IUnderstandTheRisks");

		/// <summary>
		///LIFO (Last In/First Out)
		/// </summary>
		public static string LIFO => I18NResource.GetString(ResourceDirectory, "LIFO");

		/// <summary>
		///MAVCO (Moving Average Costing)
		/// </summary>
		public static string MAVCO => I18NResource.GetString(ResourceDirectory, "MAVCO");

		/// <summary>
		///Memo
		/// </summary>
		public static string Memo => I18NResource.GetString(ResourceDirectory, "Memo");

		/// <summary>
		///No
		/// </summary>
		public static string No => I18NResource.GetString(ResourceDirectory, "No");

		/// <summary>
		///Nothing to transfer!
		/// </summary>
		public static string NothingToTransfer => I18NResource.GetString(ResourceDirectory, "NothingToTransfer");

		/// <summary>
		///OfficeName
		/// </summary>
		public static string OfficeName => I18NResource.GetString(ResourceDirectory, "OfficeName");

		/// <summary>
		///Okay
		/// </summary>
		public static string Okay => I18NResource.GetString(ResourceDirectory, "Okay");

		/// <summary>
		///Opening Inventory
		/// </summary>
		public static string OpeningInventory => I18NResource.GetString(ResourceDirectory, "OpeningInventory");

		/// <summary>
		///Opening inventory has already been entered for this office.
		/// </summary>
		public static string OpeningInventoryAlreadyEnteredOffice => I18NResource.GetString(ResourceDirectory, "OpeningInventoryAlreadyEnteredOffice");

		/// <summary>
		///Out
		/// </summary>
		public static string Out => I18NResource.GetString(ResourceDirectory, "Out");

		/// <summary>
		///Periodic
		/// </summary>
		public static string Periodic => I18NResource.GetString(ResourceDirectory, "Periodic");

		/// <summary>
		///Perpetual
		/// </summary>
		public static string Perpetual => I18NResource.GetString(ResourceDirectory, "Perpetual");

		/// <summary>
		///Please enter a code of the new item variant.
		/// </summary>
		public static string PleaseEnterCodeNewItemVariant => I18NResource.GetString(ResourceDirectory, "PleaseEnterCodeNewItemVariant");

		/// <summary>
		///Please enter a name for the new item variant.
		/// </summary>
		public static string PleaseEnterNameNewItemVariant => I18NResource.GetString(ResourceDirectory, "PleaseEnterNameNewItemVariant");

		/// <summary>
		///Please select an attribute.
		/// </summary>
		public static string PleaseSelectAttribute => I18NResource.GetString(ResourceDirectory, "PleaseSelectAttribute");

		/// <summary>
		///Please select an item.
		/// </summary>
		public static string PleaseSelectItem => I18NResource.GetString(ResourceDirectory, "PleaseSelectItem");

		/// <summary>
		///Please select a store!
		/// </summary>
		public static string PleaseSelectStore => I18NResource.GetString(ResourceDirectory, "PleaseSelectStore");

		/// <summary>
		///Print
		/// </summary>
		public static string Print => I18NResource.GetString(ResourceDirectory, "Print");

		/// <summary>
		///Ref #
		/// </summary>
		public static string ReferenceNumberAbbrebiated => I18NResource.GetString(ResourceDirectory, "ReferenceNumberAbbrebiated");

		/// <summary>
		///Reject
		/// </summary>
		public static string Reject => I18NResource.GetString(ResourceDirectory, "Reject");

		/// <summary>
		///Reject Transaction
		/// </summary>
		public static string RejectTransaction => I18NResource.GetString(ResourceDirectory, "RejectTransaction");

		/// <summary>
		///Save
		/// </summary>
		public static string Save => I18NResource.GetString(ResourceDirectory, "Save");

		/// <summary>
		///Search ...
		/// </summary>
		public static string Search => I18NResource.GetString(ResourceDirectory, "Search");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///Select Item
		/// </summary>
		public static string SelectItem => I18NResource.GetString(ResourceDirectory, "SelectItem");

		/// <summary>
		///Select Store
		/// </summary>
		public static string SelectStore => I18NResource.GetString(ResourceDirectory, "SelectStore");

		/// <summary>
		///Select Variant
		/// </summary>
		public static string SelectVariant => I18NResource.GetString(ResourceDirectory, "SelectVariant");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Show Items
		/// </summary>
		public static string ShowItems => I18NResource.GetString(ResourceDirectory, "ShowItems");

		/// <summary>
		///Store
		/// </summary>
		public static string Store => I18NResource.GetString(ResourceDirectory, "Store");

		/// <summary>
		///Stores & Warehouses
		/// </summary>
		public static string StoresAndWarehouses => I18NResource.GetString(ResourceDirectory, "StoresAndWarehouses");

		/// <summary>
		///To
		/// </summary>
		public static string To => I18NResource.GetString(ResourceDirectory, "To");

		/// <summary>
		///The transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

		/// <summary>
		///Type
		/// </summary>
		public static string Type => I18NResource.GetString(ResourceDirectory, "Type");

		/// <summary>
		///Unit
		/// </summary>
		public static string Unit => I18NResource.GetString(ResourceDirectory, "Unit");

		/// <summary>
		///Unverified
		/// </summary>
		public static string Unverified => I18NResource.GetString(ResourceDirectory, "Unverified");

		/// <summary>
		///Variant
		/// </summary>
		public static string Variant => I18NResource.GetString(ResourceDirectory, "Variant");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Verify
		/// </summary>
		public static string Verify => I18NResource.GetString(ResourceDirectory, "Verify");

		/// <summary>
		///View Adjustment
		/// </summary>
		public static string ViewAdjustment => I18NResource.GetString(ResourceDirectory, "ViewAdjustment");

		/// <summary>
		///View Adjustments
		/// </summary>
		public static string ViewAdjustments => I18NResource.GetString(ResourceDirectory, "ViewAdjustments");

		/// <summary>
		///View Opening Inventories
		/// </summary>
		public static string ViewOpeningInventories => I18NResource.GetString(ResourceDirectory, "ViewOpeningInventories");

		/// <summary>
		///View Opening Inventory Advice
		/// </summary>
		public static string ViewOpeningInventoryAdvice => I18NResource.GetString(ResourceDirectory, "ViewOpeningInventoryAdvice");

		/// <summary>
		///View Transfer
		/// </summary>
		public static string ViewTransfer => I18NResource.GetString(ResourceDirectory, "ViewTransfer");

		/// <summary>
		///View Transfers
		/// </summary>
		public static string ViewTransfers => I18NResource.GetString(ResourceDirectory, "ViewTransfers");

		/// <summary>
		///Warning
		/// </summary>
		public static string Warning => I18NResource.GetString(ResourceDirectory, "Warning");

		/// <summary>
		///We only have {0} {1} in inventory
		/// </summary>
		public static string WeOnlyHaveInInventory => I18NResource.GetString(ResourceDirectory, "WeOnlyHaveInInventory");

		/// <summary>
		///Yes
		/// </summary>
		public static string Yes => I18NResource.GetString(ResourceDirectory, "Yes");

		/// <summary>
		///You
		/// </summary>
		public static string You => I18NResource.GetString(ResourceDirectory, "You");

		/// <summary>
		///Validate Returns
		/// </summary>
		public static string ValidateReturns => I18NResource.GetString(ResourceDirectory, "ValidateReturns");

	}
}
