using System.Collections.Generic;
using System.Globalization;
using Frapid.Configuration;
using Frapid.i18n;

namespace MixERP.Sales
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
			ResourceDirectory = PathMapper.MapPath("/Areas/MixERP.Sales/i18n");
		}

		/// <summary>
		///Account
		/// </summary>
		public static string Account => I18NResource.GetString(ResourceDirectory, "Account");

		/// <summary>
		///Accountant Report
		/// </summary>
		public static string AccountantSummary => I18NResource.GetString(ResourceDirectory, "AccountantSummary");

		/// <summary>
		///Account Id
		/// </summary>
		public static string AccountId => I18NResource.GetString(ResourceDirectory, "AccountId");

		/// <summary>
		///Account Receivable By Customer Report
		/// </summary>
		public static string AccountReceivableByCustomer => I18NResource.GetString(ResourceDirectory, "AccountReceivableByCustomer");

		/// <summary>
		///Account Receivables
		/// </summary>
		public static string AccountReceivables => I18NResource.GetString(ResourceDirectory, "AccountReceivables");

		/// <summary>
		///Actions
		/// </summary>
		public static string Actions => I18NResource.GetString(ResourceDirectory, "Actions");

		/// <summary>
		///Add Fund to Gift Cards
		/// </summary>
		public static string AddFundGiftCards => I18NResource.GetString(ResourceDirectory, "AddFundGiftCards");

		/// <summary>
		///Add Funds to Gift Card
		/// </summary>
		public static string AddFundsGiftCard => I18NResource.GetString(ResourceDirectory, "AddFundsGiftCard");

		/// <summary>
		///Add Gift Card Fund
		/// </summary>
		public static string AddGiftCardFund => I18NResource.GetString(ResourceDirectory, "AddGiftCardFund");

		/// <summary>
		///Add New
		/// </summary>
		public static string AddNew => I18NResource.GetString(ResourceDirectory, "AddNew");

		/// <summary>
		///Add New Receipt Entry
		/// </summary>
		public static string AddNewReceiptEntry => I18NResource.GetString(ResourceDirectory, "AddNewReceiptEntry");

		/// <summary>
		///Add New Sales Entry
		/// </summary>
		public static string AddNewSalesEntry => I18NResource.GetString(ResourceDirectory, "AddNewSalesEntry");

		/// <summary>
		///Add New Sales Order
		/// </summary>
		public static string AddNewSalesOrder => I18NResource.GetString(ResourceDirectory, "AddNewSalesOrder");

		/// <summary>
		///Add New Sales Quotation
		/// </summary>
		public static string AddNewSalesQuotation => I18NResource.GetString(ResourceDirectory, "AddNewSalesQuotation");

		/// <summary>
		///Address
		/// </summary>
		public static string Address => I18NResource.GetString(ResourceDirectory, "Address");

		/// <summary>
		///Address Line 1
		/// </summary>
		public static string AddressLine1 => I18NResource.GetString(ResourceDirectory, "AddressLine1");

		/// <summary>
		///Address Line 2
		/// </summary>
		public static string AddressLine2 => I18NResource.GetString(ResourceDirectory, "AddressLine2");

		/// <summary>
		///Add Tax
		/// </summary>
		public static string AddTax => I18NResource.GetString(ResourceDirectory, "AddTax");

		/// <summary>
		///All Gift Cards
		/// </summary>
		public static string AllGiftCards => I18NResource.GetString(ResourceDirectory, "AllGiftCards");

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
		///Approval Memo
		/// </summary>
		public static string ApprovalMemo => I18NResource.GetString(ResourceDirectory, "ApprovalMemo");

		/// <summary>
		///Approve
		/// </summary>
		public static string Approve => I18NResource.GetString(ResourceDirectory, "Approve");

		/// <summary>
		///Approved By
		/// </summary>
		public static string ApprovedBy => I18NResource.GetString(ResourceDirectory, "ApprovedBy");

		/// <summary>
		///Approve Transaction
		/// </summary>
		public static string ApproveTransaction => I18NResource.GetString(ResourceDirectory, "ApproveTransaction");

		/// <summary>
		///Are you sure?
		/// </summary>
		public static string AreYouSure => I18NResource.GetString(ResourceDirectory, "AreYouSure");

		/// <summary>
		///Are you sure you want to delete this tab?
		/// </summary>
		public static string AreYouSureYouWantDeleteTab => I18NResource.GetString(ResourceDirectory, "AreYouSureYouWantDeleteTab");

		/// <summary>
		///Associated Price Type Code
		/// </summary>
		public static string AssociatedPriceTypeCode => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeCode");

		/// <summary>
		///Associated Price Type Id
		/// </summary>
		public static string AssociatedPriceTypeId => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeId");

		/// <summary>
		///Associated Price Type Name
		/// </summary>
		public static string AssociatedPriceTypeName => I18NResource.GetString(ResourceDirectory, "AssociatedPriceTypeName");

		/// <summary>
		///Associated User
		/// </summary>
		public static string AssociatedUser => I18NResource.GetString(ResourceDirectory, "AssociatedUser");

		/// <summary>
		///Associated User Id
		/// </summary>
		public static string AssociatedUserId => I18NResource.GetString(ResourceDirectory, "AssociatedUserId");

		/// <summary>
		///Attempted By
		/// </summary>
		public static string AttemptedBy => I18NResource.GetString(ResourceDirectory, "AttemptedBy");

		/// <summary>
		///Audit Ts
		/// </summary>
		public static string AuditTs => I18NResource.GetString(ResourceDirectory, "AuditTs");

		/// <summary>
		///Audit User Id
		/// </summary>
		public static string AuditUserId => I18NResource.GetString(ResourceDirectory, "AuditUserId");

		/// <summary>
		///Back
		/// </summary>
		public static string Back => I18NResource.GetString(ResourceDirectory, "Back");

		/// <summary>
		///Bad Request.
		/// </summary>
		public static string BadRequest => I18NResource.GetString(ResourceDirectory, "BadRequest");

		/// <summary>
		///Bank
		/// </summary>
		public static string Bank => I18NResource.GetString(ResourceDirectory, "Bank");

		/// <summary>
		///BankName
		/// </summary>
		public static string BankName => I18NResource.GetString(ResourceDirectory, "BankName");

		/// <summary>
		///Bank Transaction Code
		/// </summary>
		public static string BankTransactionCode => I18NResource.GetString(ResourceDirectory, "BankTransactionCode");

		/// <summary>
		///Barcode
		/// </summary>
		public static string Barcode => I18NResource.GetString(ResourceDirectory, "Barcode");

		/// <summary>
		///Base Currency
		/// </summary>
		public static string BaseCurrency => I18NResource.GetString(ResourceDirectory, "BaseCurrency");

		/// <summary>
		///Begins From
		/// </summary>
		public static string BeginsFrom => I18NResource.GetString(ResourceDirectory, "BeginsFrom");

		/// <summary>
		///BOD Cash
		/// </summary>
		public static string BODCash => I18NResource.GetString(ResourceDirectory, "BODCash");

		/// <summary>
		///Bom Code
		/// </summary>
		public static string BomCode => I18NResource.GetString(ResourceDirectory, "BomCode");

		/// <summary>
		///Bom Component Id
		/// </summary>
		public static string BomComponentId => I18NResource.GetString(ResourceDirectory, "BomComponentId");

		/// <summary>
		///Bom Finish Good Id
		/// </summary>
		public static string BomFinishGoodId => I18NResource.GetString(ResourceDirectory, "BomFinishGoodId");

		/// <summary>
		///Bom Id
		/// </summary>
		public static string BomId => I18NResource.GetString(ResourceDirectory, "BomId");

		/// <summary>
		///Bom Name
		/// </summary>
		public static string BomName => I18NResource.GetString(ResourceDirectory, "BomName");

		/// <summary>
		///Bom Type
		/// </summary>
		public static string BomType => I18NResource.GetString(ResourceDirectory, "BomType");

		/// <summary>
		///Bom Type Code
		/// </summary>
		public static string BomTypeCode => I18NResource.GetString(ResourceDirectory, "BomTypeCode");

		/// <summary>
		///Bom Type Id
		/// </summary>
		public static string BomTypeId => I18NResource.GetString(ResourceDirectory, "BomTypeId");

		/// <summary>
		///Bom Type Name
		/// </summary>
		public static string BomTypeName => I18NResource.GetString(ResourceDirectory, "BomTypeName");

		/// <summary>
		///Book Date
		/// </summary>
		public static string BookDate => I18NResource.GetString(ResourceDirectory, "BookDate");

		/// <summary>
		///Brand Id
		/// </summary>
		public static string BrandId => I18NResource.GetString(ResourceDirectory, "BrandId");

		/// <summary>
		///Brand Name
		/// </summary>
		public static string BrandName => I18NResource.GetString(ResourceDirectory, "BrandName");

		/// <summary>
		///Browser
		/// </summary>
		public static string Browser => I18NResource.GetString(ResourceDirectory, "Browser");

		/// <summary>
		///By Cash
		/// </summary>
		public static string ByCash => I18NResource.GetString(ResourceDirectory, "ByCash");

		/// <summary>
		///Cancel
		/// </summary>
		public static string Cancel => I18NResource.GetString(ResourceDirectory, "Cancel");

		/// <summary>
		///Cancellation Reason
		/// </summary>
		public static string CancellationReason => I18NResource.GetString(ResourceDirectory, "CancellationReason");

		/// <summary>
		///Cancelled
		/// </summary>
		public static string Cancelled => I18NResource.GetString(ResourceDirectory, "Cancelled");

		/// <summary>
		///Cannot add item because the price is zero.
		/// </summary>
		public static string CannotAddItemBecausePriceIsZero => I18NResource.GetString(ResourceDirectory, "CannotAddItemBecausePriceIsZero");

		/// <summary>
		///Capacity Per Cycle
		/// </summary>
		public static string CapacityPerCycle => I18NResource.GetString(ResourceDirectory, "CapacityPerCycle");

		/// <summary>
		///Capacity Unit Id
		/// </summary>
		public static string CapacityUnitId => I18NResource.GetString(ResourceDirectory, "CapacityUnitId");

		/// <summary>
		///Cash
		/// </summary>
		public static string Cash => I18NResource.GetString(ResourceDirectory, "Cash");

		/// <summary>
		///Cash Account Id
		/// </summary>
		public static string CashAccountId => I18NResource.GetString(ResourceDirectory, "CashAccountId");

		/// <summary>
		///Cash Change
		/// </summary>
		public static string CashChange => I18NResource.GetString(ResourceDirectory, "CashChange");

		/// <summary>
		///Cashier Code
		/// </summary>
		public static string CashierCode => I18NResource.GetString(ResourceDirectory, "CashierCode");

		/// <summary>
		///Cashier Id
		/// </summary>
		public static string CashierId => I18NResource.GetString(ResourceDirectory, "CashierId");

		/// <summary>
		///Cashier Login Info Id
		/// </summary>
		public static string CashierLoginInfoId => I18NResource.GetString(ResourceDirectory, "CashierLoginInfoId");

		/// <summary>
		///Cashiers
		/// </summary>
		public static string Cashiers => I18NResource.GetString(ResourceDirectory, "Cashiers");

		/// <summary>
		///Cash Repository
		/// </summary>
		public static string CashRepository => I18NResource.GetString(ResourceDirectory, "CashRepository");

		/// <summary>
		///Cash Repository Code
		/// </summary>
		public static string CashRepositoryCode => I18NResource.GetString(ResourceDirectory, "CashRepositoryCode");

		/// <summary>
		///Cash Repository Id
		/// </summary>
		public static string CashRepositoryId => I18NResource.GetString(ResourceDirectory, "CashRepositoryId");

		/// <summary>
		///Cash Repository Name
		/// </summary>
		public static string CashRepositoryName => I18NResource.GetString(ResourceDirectory, "CashRepositoryName");

		/// <summary>
		///Cash Tender
		/// </summary>
		public static string CashTender => I18NResource.GetString(ResourceDirectory, "CashTender");

		/// <summary>
		///A cash transaction cannot contain bank transaction details.
		/// </summary>
		public static string CashTransactionCannotContainBankTransactionDetails => I18NResource.GetString(ResourceDirectory, "CashTransactionCannotContainBankTransactionDetails");

		/// <summary>
		///Change
		/// </summary>
		public static string Change => I18NResource.GetString(ResourceDirectory, "Change");

		/// <summary>
		///Check
		/// </summary>
		public static string Check => I18NResource.GetString(ResourceDirectory, "Check");

		/// <summary>
		///Check Amount
		/// </summary>
		public static string CheckAmount => I18NResource.GetString(ResourceDirectory, "CheckAmount");

		/// <summary>
		///Check Bank Name
		/// </summary>
		public static string CheckBankName => I18NResource.GetString(ResourceDirectory, "CheckBankName");

		/// <summary>
		///Check Clear Date
		/// </summary>
		public static string CheckClearDate => I18NResource.GetString(ResourceDirectory, "CheckClearDate");

		/// <summary>
		///Check Cleared
		/// </summary>
		public static string CheckCleared => I18NResource.GetString(ResourceDirectory, "CheckCleared");

		/// <summary>
		///Check Clearing
		/// </summary>
		public static string CheckClearing => I18NResource.GetString(ResourceDirectory, "CheckClearing");

		/// <summary>
		///Check Clearing Memo
		/// </summary>
		public static string CheckClearingMemo => I18NResource.GetString(ResourceDirectory, "CheckClearingMemo");

		/// <summary>
		///Check Clearing Transaction Master Id
		/// </summary>
		public static string CheckClearingTransactionMasterId => I18NResource.GetString(ResourceDirectory, "CheckClearingTransactionMasterId");

		/// <summary>
		///Check Date
		/// </summary>
		public static string CheckDate => I18NResource.GetString(ResourceDirectory, "CheckDate");

		/// <summary>
		///Checklist
		/// </summary>
		public static string Checklist => I18NResource.GetString(ResourceDirectory, "Checklist");

		/// <summary>
		///Checklist Window
		/// </summary>
		public static string ChecklistWindow => I18NResource.GetString(ResourceDirectory, "ChecklistWindow");

		/// <summary>
		///Check Number
		/// </summary>
		public static string CheckNumber => I18NResource.GetString(ResourceDirectory, "CheckNumber");

		/// <summary>
		///Checkout
		/// </summary>
		public static string Checkout => I18NResource.GetString(ResourceDirectory, "Checkout");

		/// <summary>
		///Checkout Id
		/// </summary>
		public static string CheckoutId => I18NResource.GetString(ResourceDirectory, "CheckoutId");

		/// <summary>
		///Check
		/// </summary>
		public static string Cheque => I18NResource.GetString(ResourceDirectory, "Cheque");

		/// <summary>
		///City
		/// </summary>
		public static string City => I18NResource.GetString(ResourceDirectory, "City");

		/// <summary>
		///Clear
		/// </summary>
		public static string Clear => I18NResource.GetString(ResourceDirectory, "Clear");

		/// <summary>
		///Clear Screen
		/// </summary>
		public static string ClearScreen => I18NResource.GetString(ResourceDirectory, "ClearScreen");

		/// <summary>
		///Close
		/// </summary>
		public static string Close => I18NResource.GetString(ResourceDirectory, "Close");

		/// <summary>
		///Closed
		/// </summary>
		public static string Closed => I18NResource.GetString(ResourceDirectory, "Closed");

		/// <summary>
		///Closed Out Report
		/// </summary>
		public static string ClosedOut => I18NResource.GetString(ResourceDirectory, "ClosedOut");

		/// <summary>
		///Closing Cash Id
		/// </summary>
		public static string ClosingCashId => I18NResource.GetString(ResourceDirectory, "ClosingCashId");

		/// <summary>
		///Closing Summary
		/// </summary>
		public static string ClosingSummary => I18NResource.GetString(ResourceDirectory, "ClosingSummary");

		/// <summary>
		///CLS
		/// </summary>
		public static string Cls => I18NResource.GetString(ResourceDirectory, "Cls");

		/// <summary>
		///Coins
		/// </summary>
		public static string Coins => I18NResource.GetString(ResourceDirectory, "Coins");

		/// <summary>
		///Collected Bank Instrument Code
		/// </summary>
		public static string CollectedBankInstrumentCode => I18NResource.GetString(ResourceDirectory, "CollectedBankInstrumentCode");

		/// <summary>
		///Collected Bank Transaction Code
		/// </summary>
		public static string CollectedBankTransactionCode => I18NResource.GetString(ResourceDirectory, "CollectedBankTransactionCode");

		/// <summary>
		///Collected On Bank Id
		/// </summary>
		public static string CollectedOnBankId => I18NResource.GetString(ResourceDirectory, "CollectedOnBankId");

		/// <summary>
		///Completed Date Time
		/// </summary>
		public static string CompletedDateTime => I18NResource.GetString(ResourceDirectory, "CompletedDateTime");

		/// <summary>
		///Completed On
		/// </summary>
		public static string CompletedOn => I18NResource.GetString(ResourceDirectory, "CompletedOn");

		/// <summary>
		///Completes On
		/// </summary>
		public static string CompletesOn => I18NResource.GetString(ResourceDirectory, "CompletesOn");

		/// <summary>
		///Component Bom Id
		/// </summary>
		public static string ComponentBomId => I18NResource.GetString(ResourceDirectory, "ComponentBomId");

		/// <summary>
		///Component Id
		/// </summary>
		public static string ComponentId => I18NResource.GetString(ResourceDirectory, "ComponentId");

		/// <summary>
		///Component Item Id
		/// </summary>
		public static string ComponentItemId => I18NResource.GetString(ResourceDirectory, "ComponentItemId");

		/// <summary>
		///Converted to Base Currency
		/// </summary>
		public static string ConvertedToBaseCurrency => I18NResource.GetString(ResourceDirectory, "ConvertedToBaseCurrency");

		/// <summary>
		///Converted to Home Currency
		/// </summary>
		public static string ConvertedToHomeCurrency => I18NResource.GetString(ResourceDirectory, "ConvertedToHomeCurrency");

		/// <summary>
		///Convert to Order
		/// </summary>
		public static string ConvertOrder => I18NResource.GetString(ResourceDirectory, "ConvertOrder");

		/// <summary>
		///Convert to Sales
		/// </summary>
		public static string ConvertSales => I18NResource.GetString(ResourceDirectory, "ConvertSales");

		/// <summary>
		///Cool Down Time In Minutes
		/// </summary>
		public static string CoolDownTimeInMinutes => I18NResource.GetString(ResourceDirectory, "CoolDownTimeInMinutes");

		/// <summary>
		///Cost Center
		/// </summary>
		public static string CostCenter => I18NResource.GetString(ResourceDirectory, "CostCenter");

		/// <summary>
		///Cost Center Code
		/// </summary>
		public static string CostCenterCode => I18NResource.GetString(ResourceDirectory, "CostCenterCode");

		/// <summary>
		///Cost Center Id
		/// </summary>
		public static string CostCenterId => I18NResource.GetString(ResourceDirectory, "CostCenterId");

		/// <summary>
		///Cost Center Name
		/// </summary>
		public static string CostCenterName => I18NResource.GetString(ResourceDirectory, "CostCenterName");

		/// <summary>
		///Cost Factor
		/// </summary>
		public static string CostFactor => I18NResource.GetString(ResourceDirectory, "CostFactor");

		/// <summary>
		///Cost Price
		/// </summary>
		public static string CostPrice => I18NResource.GetString(ResourceDirectory, "CostPrice");

		/// <summary>
		///Cost Price Includes Tax
		/// </summary>
		public static string CostPriceIncludesTax => I18NResource.GetString(ResourceDirectory, "CostPriceIncludesTax");

		/// <summary>
		///Count
		/// </summary>
		public static string Count => I18NResource.GetString(ResourceDirectory, "Count");

		/// <summary>
		///Counter
		/// </summary>
		public static string Counter => I18NResource.GetString(ResourceDirectory, "Counter");

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
		///Coupon Code
		/// </summary>
		public static string CouponCode => I18NResource.GetString(ResourceDirectory, "CouponCode");

		/// <summary>
		///Coupon Id
		/// </summary>
		public static string CouponId => I18NResource.GetString(ResourceDirectory, "CouponId");

		/// <summary>
		///Coupon Name
		/// </summary>
		public static string CouponName => I18NResource.GetString(ResourceDirectory, "CouponName");

		/// <summary>
		///Cr Account
		/// </summary>
		public static string CrAccount => I18NResource.GetString(ResourceDirectory, "CrAccount");

		/// <summary>
		///Cr Account Id
		/// </summary>
		public static string CrAccountId => I18NResource.GetString(ResourceDirectory, "CrAccountId");

		/// <summary>
		///Credit
		/// </summary>
		public static string Credit => I18NResource.GetString(ResourceDirectory, "Credit");

		/// <summary>
		///Credit Exchange Rate
		/// </summary>
		public static string CreditExchangeRate => I18NResource.GetString(ResourceDirectory, "CreditExchangeRate");

		/// <summary>
		///Credit Settled
		/// </summary>
		public static string CreditSettled => I18NResource.GetString(ResourceDirectory, "CreditSettled");

		/// <summary>
		///CTRL + RETURN
		/// </summary>
		public static string CtrlReturn => I18NResource.GetString(ResourceDirectory, "CtrlReturn");

		/// <summary>
		///Currency Code
		/// </summary>
		public static string CurrencyCode => I18NResource.GetString(ResourceDirectory, "CurrencyCode");

		/// <summary>
		///Current Area
		/// </summary>
		public static string CurrentArea => I18NResource.GetString(ResourceDirectory, "CurrentArea");

		/// <summary>
		///Current Branch Office
		/// </summary>
		public static string CurrentBranchOffice => I18NResource.GetString(ResourceDirectory, "CurrentBranchOffice");

		/// <summary>
		///Customer
		/// </summary>
		public static string Customer => I18NResource.GetString(ResourceDirectory, "Customer");

		/// <summary>
		///Customer Account Statement
		/// </summary>
		public static string CustomerAccountStatement => I18NResource.GetString(ResourceDirectory, "CustomerAccountStatement");

		/// <summary>
		///Customer Code
		/// </summary>
		public static string CustomerCode => I18NResource.GetString(ResourceDirectory, "CustomerCode");

		/// <summary>
		///Customer Id
		/// </summary>
		public static string CustomerId => I18NResource.GetString(ResourceDirectory, "CustomerId");

		/// <summary>
		///Customer Loyalty
		/// </summary>
		public static string CustomerLoyalty => I18NResource.GetString(ResourceDirectory, "CustomerLoyalty");

		/// <summary>
		///Customer Name
		/// </summary>
		public static string CustomerName => I18NResource.GetString(ResourceDirectory, "CustomerName");

		/// <summary>
		///Customer Pays Fees
		/// </summary>
		public static string CustomerPaysFees => I18NResource.GetString(ResourceDirectory, "CustomerPaysFees");

		/// <summary>
		///Customer Receipts
		/// </summary>
		public static string CustomerReceipts => I18NResource.GetString(ResourceDirectory, "CustomerReceipts");

		/// <summary>
		///Customers
		/// </summary>
		public static string Customers => I18NResource.GetString(ResourceDirectory, "Customers");

		/// <summary>
		///Customer Type
		/// </summary>
		public static string CustomerType => I18NResource.GetString(ResourceDirectory, "CustomerType");

		/// <summary>
		///Customer Type Id
		/// </summary>
		public static string CustomerTypeId => I18NResource.GetString(ResourceDirectory, "CustomerTypeId");

		/// <summary>
		///Customer Types
		/// </summary>
		public static string CustomerTypes => I18NResource.GetString(ResourceDirectory, "CustomerTypes");

		/// <summary>
		///Customerwise Selling Prices
		/// </summary>
		public static string CustomerwiseSellingPrices => I18NResource.GetString(ResourceDirectory, "CustomerwiseSellingPrices");

		/// <summary>
		///Cycle Duration In Hour
		/// </summary>
		public static string CycleDurationInHour => I18NResource.GetString(ResourceDirectory, "CycleDurationInHour");

		/// <summary>
		///Debit
		/// </summary>
		public static string Debit => I18NResource.GetString(ResourceDirectory, "Debit");

		/// <summary>
		///Debit Exchange Rate
		/// </summary>
		public static string DebitExchangeRate => I18NResource.GetString(ResourceDirectory, "DebitExchangeRate");

		/// <summary>
		///Delay In Minutes
		/// </summary>
		public static string DelayInMinutes => I18NResource.GetString(ResourceDirectory, "DelayInMinutes");

		/// <summary>
		///Delete
		/// </summary>
		public static string Delete => I18NResource.GetString(ResourceDirectory, "Delete");

		/// <summary>
		///Deleted
		/// </summary>
		public static string Deleted => I18NResource.GetString(ResourceDirectory, "Deleted");

		/// <summary>
		///Deno 1
		/// </summary>
		public static string Deno1 => I18NResource.GetString(ResourceDirectory, "Deno1");

		/// <summary>
		///Deno 10
		/// </summary>
		public static string Deno10 => I18NResource.GetString(ResourceDirectory, "Deno10");

		/// <summary>
		///Deno 100
		/// </summary>
		public static string Deno100 => I18NResource.GetString(ResourceDirectory, "Deno100");

		/// <summary>
		///Deno 1000
		/// </summary>
		public static string Deno1000 => I18NResource.GetString(ResourceDirectory, "Deno1000");

		/// <summary>
		///Deno 2
		/// </summary>
		public static string Deno2 => I18NResource.GetString(ResourceDirectory, "Deno2");

		/// <summary>
		///Deno 20
		/// </summary>
		public static string Deno20 => I18NResource.GetString(ResourceDirectory, "Deno20");

		/// <summary>
		///Deno 200
		/// </summary>
		public static string Deno200 => I18NResource.GetString(ResourceDirectory, "Deno200");

		/// <summary>
		///Deno 25
		/// </summary>
		public static string Deno25 => I18NResource.GetString(ResourceDirectory, "Deno25");

		/// <summary>
		///Deno 250
		/// </summary>
		public static string Deno250 => I18NResource.GetString(ResourceDirectory, "Deno250");

		/// <summary>
		///Deno 5
		/// </summary>
		public static string Deno5 => I18NResource.GetString(ResourceDirectory, "Deno5");

		/// <summary>
		///Deno 50
		/// </summary>
		public static string Deno50 => I18NResource.GetString(ResourceDirectory, "Deno50");

		/// <summary>
		///Deno 500
		/// </summary>
		public static string Deno500 => I18NResource.GetString(ResourceDirectory, "Deno500");

		/// <summary>
		///Denominations
		/// </summary>
		public static string Denominations => I18NResource.GetString(ResourceDirectory, "Denominations");

		/// <summary>
		///Department
		/// </summary>
		public static string Department => I18NResource.GetString(ResourceDirectory, "Department");

		/// <summary>
		///Description
		/// </summary>
		public static string Description => I18NResource.GetString(ResourceDirectory, "Description");

		/// <summary>
		///Detailed Payment Report
		/// </summary>
		public static string DetailedPaymentReport => I18NResource.GetString(ResourceDirectory, "DetailedPaymentReport");

		/// <summary>
		///Disassembly Detail Id
		/// </summary>
		public static string DisassemblyDetailId => I18NResource.GetString(ResourceDirectory, "DisassemblyDetailId");

		/// <summary>
		///Disassembly Expenses Id
		/// </summary>
		public static string DisassemblyExpensesId => I18NResource.GetString(ResourceDirectory, "DisassemblyExpensesId");

		/// <summary>
		///Disassembly Id
		/// </summary>
		public static string DisassemblyId => I18NResource.GetString(ResourceDirectory, "DisassemblyId");

		/// <summary>
		///Discount
		/// </summary>
		public static string Discount => I18NResource.GetString(ResourceDirectory, "Discount");

		/// <summary>
		///Discount Coupons
		/// </summary>
		public static string DiscountCoupons => I18NResource.GetString(ResourceDirectory, "DiscountCoupons");

		/// <summary>
		///Discount Rate
		/// </summary>
		public static string DiscountRate => I18NResource.GetString(ResourceDirectory, "DiscountRate");

		/// <summary>
		///Discount Type
		/// </summary>
		public static string DiscountType => I18NResource.GetString(ResourceDirectory, "DiscountType");

		/// <summary>
		///Dr Account
		/// </summary>
		public static string DrAccount => I18NResource.GetString(ResourceDirectory, "DrAccount");

		/// <summary>
		///Dr Account Id
		/// </summary>
		public static string DrAccountId => I18NResource.GetString(ResourceDirectory, "DrAccountId");

		/// <summary>
		///Due Date
		/// </summary>
		public static string DueDate => I18NResource.GetString(ResourceDirectory, "DueDate");

		/// <summary>
		///Due Days
		/// </summary>
		public static string DueDays => I18NResource.GetString(ResourceDirectory, "DueDays");

		/// <summary>
		///Due Fequency
		/// </summary>
		public static string DueFequency => I18NResource.GetString(ResourceDirectory, "DueFequency");

		/// <summary>
		///Due Frequency Id
		/// </summary>
		public static string DueFrequencyId => I18NResource.GetString(ResourceDirectory, "DueFrequencyId");

		/// <summary>
		///Due On Date
		/// </summary>
		public static string DueOnDate => I18NResource.GetString(ResourceDirectory, "DueOnDate");

		/// <summary>
		///Edit Price
		/// </summary>
		public static string EditPrice => I18NResource.GetString(ResourceDirectory, "EditPrice");

		/// <summary>
		///Effective From
		/// </summary>
		public static string EffectiveFrom => I18NResource.GetString(ResourceDirectory, "EffectiveFrom");

		/// <summary>
		///Email
		/// </summary>
		public static string Email => I18NResource.GetString(ResourceDirectory, "Email");

		/// <summary>
		///Enable Ticket Printing
		/// </summary>
		public static string EnableTicketPrinting => I18NResource.GetString(ResourceDirectory, "EnableTicketPrinting");

		/// <summary>
		///Ends On
		/// </summary>
		public static string EndsOn => I18NResource.GetString(ResourceDirectory, "EndsOn");

		/// <summary>
		///Enter Amount
		/// </summary>
		public static string EnterAmount => I18NResource.GetString(ResourceDirectory, "EnterAmount");

		/// <summary>
		///Entered By
		/// </summary>
		public static string EnteredBy => I18NResource.GetString(ResourceDirectory, "EnteredBy");

		/// <summary>
		///Enter a Gift Card Number
		/// </summary>
		public static string EnterGiftCardNumber => I18NResource.GetString(ResourceDirectory, "EnterGiftCardNumber");

		/// <summary>
		///Enter Quantity
		/// </summary>
		public static string EnterQuantity => I18NResource.GetString(ResourceDirectory, "EnterQuantity");

		/// <summary>
		///Enter Rate of Discount
		/// </summary>
		public static string EnterRateDiscount => I18NResource.GetString(ResourceDirectory, "EnterRateDiscount");

		/// <summary>
		///Enter Transaction Id
		/// </summary>
		public static string EnterTransactionId => I18NResource.GetString(ResourceDirectory, "EnterTransactionId");

		/// <summary>
		///EOD
		/// </summary>
		public static string EOD => I18NResource.GetString(ResourceDirectory, "EOD");

		/// <summary>
		///EOD Cash
		/// </summary>
		public static string EODCash => I18NResource.GetString(ResourceDirectory, "EODCash");

		/// <summary>
		///Er Credit
		/// </summary>
		public static string ErCredit => I18NResource.GetString(ResourceDirectory, "ErCredit");

		/// <summary>
		///Er Debit
		/// </summary>
		public static string ErDebit => I18NResource.GetString(ResourceDirectory, "ErDebit");

		/// <summary>
		///Event Date
		/// </summary>
		public static string EventDate => I18NResource.GetString(ResourceDirectory, "EventDate");

		/// <summary>
		///Event User Id
		/// </summary>
		public static string EventUserId => I18NResource.GetString(ResourceDirectory, "EventUserId");

		/// <summary>
		///Exchange Rate ({0} - {1})
		/// </summary>
		public static string ExchangeRateWithValue => I18NResource.GetString(ResourceDirectory, "ExchangeRateWithValue");

		/// <summary>
		///Expected Date
		/// </summary>
		public static string ExpectedDate => I18NResource.GetString(ResourceDirectory, "ExpectedDate");

		/// <summary>
		///Expected Delivery Date
		/// </summary>
		public static string ExpectedDeliveryDate => I18NResource.GetString(ResourceDirectory, "ExpectedDeliveryDate");

		/// <summary>
		///Expected From
		/// </summary>
		public static string ExpectedFrom => I18NResource.GetString(ResourceDirectory, "ExpectedFrom");

		/// <summary>
		///Expected To
		/// </summary>
		public static string ExpectedTo => I18NResource.GetString(ResourceDirectory, "ExpectedTo");

		/// <summary>
		///Expenses In Progress Id
		/// </summary>
		public static string ExpensesInProgressId => I18NResource.GetString(ResourceDirectory, "ExpensesInProgressId");

		/// <summary>
		///Expenses Title
		/// </summary>
		public static string ExpensesTitle => I18NResource.GetString(ResourceDirectory, "ExpensesTitle");

		/// <summary>
		///Expires On
		/// </summary>
		public static string ExpiresOn => I18NResource.GetString(ResourceDirectory, "ExpiresOn");

		/// <summary>
		///Export
		/// </summary>
		public static string Export => I18NResource.GetString(ResourceDirectory, "Export");

		/// <summary>
		///Export This Document
		/// </summary>
		public static string ExportThisDocument => I18NResource.GetString(ResourceDirectory, "ExportThisDocument");

		/// <summary>
		///Export to Doc
		/// </summary>
		public static string ExportToDoc => I18NResource.GetString(ResourceDirectory, "ExportToDoc");

		/// <summary>
		///Export to Excel
		/// </summary>
		public static string ExportToExcel => I18NResource.GetString(ResourceDirectory, "ExportToExcel");

		/// <summary>
		///Export to PDF
		/// </summary>
		public static string ExportToPDF => I18NResource.GetString(ResourceDirectory, "ExportToPDF");

		/// <summary>
		///Fax
		/// </summary>
		public static string Fax => I18NResource.GetString(ResourceDirectory, "Fax");

		/// <summary>
		///50
		/// </summary>
		public static string Fifty => I18NResource.GetString(ResourceDirectory, "Fifty");

		/// <summary>
		///Final Due Amount in Base Currency
		/// </summary>
		public static string FinalDueAmountInBaseCurrency => I18NResource.GetString(ResourceDirectory, "FinalDueAmountInBaseCurrency");

		/// <summary>
		///Finished Good Store
		/// </summary>
		public static string FinishedGoodStore => I18NResource.GetString(ResourceDirectory, "FinishedGoodStore");

		/// <summary>
		///Finished Good Store Id
		/// </summary>
		public static string FinishedGoodStoreId => I18NResource.GetString(ResourceDirectory, "FinishedGoodStoreId");

		/// <summary>
		///First Name
		/// </summary>
		public static string FirstName => I18NResource.GetString(ResourceDirectory, "FirstName");

		/// <summary>
		///Fiscal Year Code
		/// </summary>
		public static string FiscalYearCode => I18NResource.GetString(ResourceDirectory, "FiscalYearCode");

		/// <summary>
		///5
		/// </summary>
		public static string Five => I18NResource.GetString(ResourceDirectory, "Five");

		/// <summary>
		///500
		/// </summary>
		public static string FiveHundred => I18NResource.GetString(ResourceDirectory, "FiveHundred");

		/// <summary>
		///For Ticket Having Maximum Amount
		/// </summary>
		public static string ForTicketHavingMaximumAmount => I18NResource.GetString(ResourceDirectory, "ForTicketHavingMaximumAmount");

		/// <summary>
		///For Ticket Having Minimum Amount
		/// </summary>
		public static string ForTicketHavingMinimumAmount => I18NResource.GetString(ResourceDirectory, "ForTicketHavingMinimumAmount");

		/// <summary>
		///For Ticket Of Price Type Code
		/// </summary>
		public static string ForTicketOfPriceTypeCode => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeCode");

		/// <summary>
		///For Ticket Of Price Type Id
		/// </summary>
		public static string ForTicketOfPriceTypeId => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeId");

		/// <summary>
		///For Ticket Of Price Type Name
		/// </summary>
		public static string ForTicketOfPriceTypeName => I18NResource.GetString(ResourceDirectory, "ForTicketOfPriceTypeName");

		/// <summary>
		///For Ticket Of Unknown Customers Only
		/// </summary>
		public static string ForTicketOfUnknownCustomersOnly => I18NResource.GetString(ResourceDirectory, "ForTicketOfUnknownCustomersOnly");

		/// <summary>
		///From
		/// </summary>
		public static string From => I18NResource.GetString(ResourceDirectory, "From");

		/// <summary>
		///Gift Card
		/// </summary>
		public static string GiftCard => I18NResource.GetString(ResourceDirectory, "GiftCard");

		/// <summary>
		///Gift Card Balance
		/// </summary>
		public static string GiftCardBalance => I18NResource.GetString(ResourceDirectory, "GiftCardBalance");

		/// <summary>
		///Gift Card Funds
		/// </summary>
		public static string GiftCardFunds => I18NResource.GetString(ResourceDirectory, "GiftCardFunds");

		/// <summary>
		///Gift Card Fund Sales
		/// </summary>
		public static string GiftCardFundSales => I18NResource.GetString(ResourceDirectory, "GiftCardFundSales");

		/// <summary>
		///Gift Card Funds Verification
		/// </summary>
		public static string GiftCardFundsVerification => I18NResource.GetString(ResourceDirectory, "GiftCardFundsVerification");

		/// <summary>
		///Gift Card Fund Verification
		/// </summary>
		public static string GiftCardFundVerification => I18NResource.GetString(ResourceDirectory, "GiftCardFundVerification");

		/// <summary>
		///Gift Card Id
		/// </summary>
		public static string GiftCardId => I18NResource.GetString(ResourceDirectory, "GiftCardId");

		/// <summary>
		///Gift Card Name
		/// </summary>
		public static string GiftCardName => I18NResource.GetString(ResourceDirectory, "GiftCardName");

		/// <summary>
		///Gift Card Number
		/// </summary>
		public static string GiftCardNumber => I18NResource.GetString(ResourceDirectory, "GiftCardNumber");

		/// <summary>
		///Gift Card Owner
		/// </summary>
		public static string GiftCardOwner => I18NResource.GetString(ResourceDirectory, "GiftCardOwner");

		/// <summary>
		///Gift Cards
		/// </summary>
		public static string GiftCards => I18NResource.GetString(ResourceDirectory, "GiftCards");

		/// <summary>
		///Gift Card Summary
		/// </summary>
		public static string GiftCardSummary => I18NResource.GetString(ResourceDirectory, "GiftCardSummary");

		/// <summary>
		///Gift Card Usage Statement
		/// </summary>
		public static string GiftCardUsageStatement => I18NResource.GetString(ResourceDirectory, "GiftCardUsageStatement");

		/// <summary>
		///Go
		/// </summary>
		public static string Go => I18NResource.GetString(ResourceDirectory, "Go");

		/// <summary>
		///Grace Period
		/// </summary>
		public static string GracePeriod => I18NResource.GetString(ResourceDirectory, "GracePeriod");

		/// <summary>
		///Grand Total
		/// </summary>
		public static string GrandTotal => I18NResource.GetString(ResourceDirectory, "GrandTotal");

		/// <summary>
		///Hide
		/// </summary>
		public static string Hide => I18NResource.GetString(ResourceDirectory, "Hide");

		/// <summary>
		///Hot Item
		/// </summary>
		public static string HotItem => I18NResource.GetString(ResourceDirectory, "HotItem");

		/// <summary>
		///Hourly Cost
		/// </summary>
		public static string HourlyCost => I18NResource.GetString(ResourceDirectory, "HourlyCost");

		/// <summary>
		///100
		/// </summary>
		public static string Hundred => I18NResource.GetString(ResourceDirectory, "Hundred");

		/// <summary>
		///Id
		/// </summary>
		public static string Id => I18NResource.GetString(ResourceDirectory, "Id");

		/// <summary>
		///Includes Tax
		/// </summary>
		public static string IncludesTax => I18NResource.GetString(ResourceDirectory, "IncludesTax");

		/// <summary>
		///Installation Date
		/// </summary>
		public static string InstallationDate => I18NResource.GetString(ResourceDirectory, "InstallationDate");

		/// <summary>
		///Instrument Code
		/// </summary>
		public static string InstrumentCode => I18NResource.GetString(ResourceDirectory, "InstrumentCode");

		/// <summary>
		///Internal Memo
		/// </summary>
		public static string InternalMemo => I18NResource.GetString(ResourceDirectory, "InternalMemo");

		/// <summary>
		///Invalid receipt mode.
		/// </summary>
		public static string InvalidReceiptMode => I18NResource.GetString(ResourceDirectory, "InvalidReceiptMode");

		/// <summary>
		///Invoice Number
		/// </summary>
		public static string InvoiceNumber => I18NResource.GetString(ResourceDirectory, "InvoiceNumber");

		/// <summary>
		///Inv#
		/// </summary>
		public static string InvoiceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "InvoiceNumberAbbreviated");

		/// <summary>
		///Ip Address
		/// </summary>
		public static string IpAddress => I18NResource.GetString(ResourceDirectory, "IpAddress");

		/// <summary>
		///Is Cancelled
		/// </summary>
		public static string IsCancelled => I18NResource.GetString(ResourceDirectory, "IsCancelled");

		/// <summary>
		///Is Complete
		/// </summary>
		public static string IsComplete => I18NResource.GetString(ResourceDirectory, "IsComplete");

		/// <summary>
		///Is Completed
		/// </summary>
		public static string IsCompleted => I18NResource.GetString(ResourceDirectory, "IsCompleted");

		/// <summary>
		///Is Credit
		/// </summary>
		public static string IsCredit => I18NResource.GetString(ResourceDirectory, "IsCredit");

		/// <summary>
		///Is Flat Amount
		/// </summary>
		public static string IsFlatAmount => I18NResource.GetString(ResourceDirectory, "IsFlatAmount");

		/// <summary>
		///Is Flat Discount
		/// </summary>
		public static string IsFlatDiscount => I18NResource.GetString(ResourceDirectory, "IsFlatDiscount");

		/// <summary>
		///Is Inventory Transaction
		/// </summary>
		public static string IsInventoryTransaction => I18NResource.GetString(ResourceDirectory, "IsInventoryTransaction");

		/// <summary>
		///Is Machine
		/// </summary>
		public static string IsMachine => I18NResource.GetString(ResourceDirectory, "IsMachine");

		/// <summary>
		///Is Percentage
		/// </summary>
		public static string IsPercentage => I18NResource.GetString(ResourceDirectory, "IsPercentage");

		/// <summary>
		///Is Phantom
		/// </summary>
		public static string IsPhantom => I18NResource.GetString(ResourceDirectory, "IsPhantom");

		/// <summary>
		///Is Raw Material
		/// </summary>
		public static string IsRawMaterial => I18NResource.GetString(ResourceDirectory, "IsRawMaterial");

		/// <summary>
		///Issue Method Code
		/// </summary>
		public static string IssueMethodCode => I18NResource.GetString(ResourceDirectory, "IssueMethodCode");

		/// <summary>
		///Issue Method Id
		/// </summary>
		public static string IssueMethodId => I18NResource.GetString(ResourceDirectory, "IssueMethodId");

		/// <summary>
		///Issue Method Name
		/// </summary>
		public static string IssueMethodName => I18NResource.GetString(ResourceDirectory, "IssueMethodName");

		/// <summary>
		///Is Taxable Item
		/// </summary>
		public static string IsTaxableItem => I18NResource.GetString(ResourceDirectory, "IsTaxableItem");

		/// <summary>
		///Is Taxed
		/// </summary>
		public static string IsTaxed => I18NResource.GetString(ResourceDirectory, "IsTaxed");

		/// <summary>
		///Is Template
		/// </summary>
		public static string IsTemplate => I18NResource.GetString(ResourceDirectory, "IsTemplate");

		/// <summary>
		///Is Variant Of
		/// </summary>
		public static string IsVariantOf => I18NResource.GetString(ResourceDirectory, "IsVariantOf");

		/// <summary>
		///Item
		/// </summary>
		public static string Item => I18NResource.GetString(ResourceDirectory, "Item");

		/// <summary>
		///Item Code
		/// </summary>
		public static string ItemCode => I18NResource.GetString(ResourceDirectory, "ItemCode");

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
		///Item Selling Price Id
		/// </summary>
		public static string ItemSellingPriceId => I18NResource.GetString(ResourceDirectory, "ItemSellingPriceId");

		/// <summary>
		///Item Type Id
		/// </summary>
		public static string ItemTypeId => I18NResource.GetString(ResourceDirectory, "ItemTypeId");

		/// <summary>
		///Item Type Name
		/// </summary>
		public static string ItemTypeName => I18NResource.GetString(ResourceDirectory, "ItemTypeName");

		/// <summary>
		///Kanban Code
		/// </summary>
		public static string KanbanCode => I18NResource.GetString(ResourceDirectory, "KanbanCode");

		/// <summary>
		///Kanban Id
		/// </summary>
		public static string KanbanId => I18NResource.GetString(ResourceDirectory, "KanbanId");

		/// <summary>
		///Kanban Name
		/// </summary>
		public static string KanbanName => I18NResource.GetString(ResourceDirectory, "KanbanName");

		/// <summary>
		///Last Kanban Id
		/// </summary>
		public static string LastKanbanId => I18NResource.GetString(ResourceDirectory, "LastKanbanId");

		/// <summary>
		///Last Name
		/// </summary>
		public static string LastName => I18NResource.GetString(ResourceDirectory, "LastName");

		/// <summary>
		///Last Verified On
		/// </summary>
		public static string LastVerifiedOn => I18NResource.GetString(ResourceDirectory, "LastVerifiedOn");

		/// <summary>
		///Late Fee
		/// </summary>
		public static string LateFee => I18NResource.GetString(ResourceDirectory, "LateFee");

		/// <summary>
		///Late Fee Code
		/// </summary>
		public static string LateFeeCode => I18NResource.GetString(ResourceDirectory, "LateFeeCode");

		/// <summary>
		///Late Fee Frequency
		/// </summary>
		public static string LateFeeFrequency => I18NResource.GetString(ResourceDirectory, "LateFeeFrequency");

		/// <summary>
		///Late Fee Id
		/// </summary>
		public static string LateFeeId => I18NResource.GetString(ResourceDirectory, "LateFeeId");

		/// <summary>
		///Late Fee Name
		/// </summary>
		public static string LateFeeName => I18NResource.GetString(ResourceDirectory, "LateFeeName");

		/// <summary>
		///Late Fee Posting Frequency Id
		/// </summary>
		public static string LateFeePostingFrequencyId => I18NResource.GetString(ResourceDirectory, "LateFeePostingFrequencyId");

		/// <summary>
		///Late Fee Tran Id
		/// </summary>
		public static string LateFeeTranId => I18NResource.GetString(ResourceDirectory, "LateFeeTranId");

		/// <summary>
		///Lead Time In Days
		/// </summary>
		public static string LeadTimeInDays => I18NResource.GetString(ResourceDirectory, "LeadTimeInDays");

		/// <summary>
		///Less
		/// </summary>
		public static string Less => I18NResource.GetString(ResourceDirectory, "Less");

		/// <summary>
		///Lifetime Capacity
		/// </summary>
		public static string LifetimeCapacity => I18NResource.GetString(ResourceDirectory, "LifetimeCapacity");

		/// <summary>
		///Loading items...
		/// </summary>
		public static string LoadingItems => I18NResource.GetString(ResourceDirectory, "LoadingItems");

		/// <summary>
		///Login Date
		/// </summary>
		public static string LoginDate => I18NResource.GetString(ResourceDirectory, "LoginDate");

		/// <summary>
		///Loyalty Point Manager
		/// </summary>
		public static string LoyaltyPointManager => I18NResource.GetString(ResourceDirectory, "LoyaltyPointManager");

		/// <summary>
		///Machine Cost
		/// </summary>
		public static string MachineCost => I18NResource.GetString(ResourceDirectory, "MachineCost");

		/// <summary>
		///Machine Name
		/// </summary>
		public static string MachineName => I18NResource.GetString(ResourceDirectory, "MachineName");

		/// <summary>
		///Maintain Inventory
		/// </summary>
		public static string MaintainInventory => I18NResource.GetString(ResourceDirectory, "MaintainInventory");

		/// <summary>
		///Managed By
		/// </summary>
		public static string ManagedBy => I18NResource.GetString(ResourceDirectory, "ManagedBy");

		/// <summary>
		///Manufacturer
		/// </summary>
		public static string Manufacturer => I18NResource.GetString(ResourceDirectory, "Manufacturer");

		/// <summary>
		///Manufacturing Id
		/// </summary>
		public static string ManufacturingId => I18NResource.GetString(ResourceDirectory, "ManufacturingId");

		/// <summary>
		///Manufacturing Summary Id
		/// </summary>
		public static string ManufacturingSummaryId => I18NResource.GetString(ResourceDirectory, "ManufacturingSummaryId");

		/// <summary>
		///Material Store
		/// </summary>
		public static string MaterialStore => I18NResource.GetString(ResourceDirectory, "MaterialStore");

		/// <summary>
		///Maximum Daily Work Hours
		/// </summary>
		public static string MaximumDailyWorkHours => I18NResource.GetString(ResourceDirectory, "MaximumDailyWorkHours");

		/// <summary>
		///Maximum Discount Amount
		/// </summary>
		public static string MaximumDiscountAmount => I18NResource.GetString(ResourceDirectory, "MaximumDiscountAmount");

		/// <summary>
		///Maximum Purchase Amount
		/// </summary>
		public static string MaximumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MaximumPurchaseAmount");

		/// <summary>
		///Maximum Usage
		/// </summary>
		public static string MaximumUsage => I18NResource.GetString(ResourceDirectory, "MaximumUsage");

		/// <summary>
		///Memo
		/// </summary>
		public static string Memo => I18NResource.GetString(ResourceDirectory, "Memo");

		/// <summary>
		///Merchant Fee
		/// </summary>
		public static string MerchantFee => I18NResource.GetString(ResourceDirectory, "MerchantFee");

		/// <summary>
		///Message
		/// </summary>
		public static string Message => I18NResource.GetString(ResourceDirectory, "Message");

		/// <summary>
		///Middle Name
		/// </summary>
		public static string MiddleName => I18NResource.GetString(ResourceDirectory, "MiddleName");

		/// <summary>
		///Minimum Purchase Amount
		/// </summary>
		public static string MinimumPurchaseAmount => I18NResource.GetString(ResourceDirectory, "MinimumPurchaseAmount");

		/// <summary>
		///Model Number
		/// </summary>
		public static string ModelNumber => I18NResource.GetString(ResourceDirectory, "ModelNumber");

		/// <summary>
		///Name
		/// </summary>
		public static string Name => I18NResource.GetString(ResourceDirectory, "Name");

		/// <summary>
		///Next
		/// </summary>
		public static string Next => I18NResource.GetString(ResourceDirectory, "Next");

		/// <summary>
		///Non Taxable Sales
		/// </summary>
		public static string NonTaxableSales => I18NResource.GetString(ResourceDirectory, "NonTaxableSales");

		/// <summary>
		///Nontaxable Total
		/// </summary>
		public static string NontaxableTotal => I18NResource.GetString(ResourceDirectory, "NontaxableTotal");

		/// <summary>
		///Of All Time
		/// </summary>
		public static string OfAllTime => I18NResource.GetString(ResourceDirectory, "OfAllTime");

		/// <summary>
		///Office
		/// </summary>
		public static string Office => I18NResource.GetString(ResourceDirectory, "Office");

		/// <summary>
		///Office Id
		/// </summary>
		public static string OfficeId => I18NResource.GetString(ResourceDirectory, "OfficeId");

		/// <summary>
		///Office Name
		/// </summary>
		public static string OfficeName => I18NResource.GetString(ResourceDirectory, "OfficeName");

		/// <summary>
		///On Credit
		/// </summary>
		public static string OnCredit => I18NResource.GetString(ResourceDirectory, "OnCredit");

		/// <summary>
		///One
		/// </summary>
		public static string One => I18NResource.GetString(ResourceDirectory, "One");

		/// <summary>
		///Opening Cash
		/// </summary>
		public static string OpeningCash => I18NResource.GetString(ResourceDirectory, "OpeningCash");

		/// <summary>
		///Opening Cash Id
		/// </summary>
		public static string OpeningCashId => I18NResource.GetString(ResourceDirectory, "OpeningCashId");

		/// <summary>
		///Order Action Code
		/// </summary>
		public static string OrderActionCode => I18NResource.GetString(ResourceDirectory, "OrderActionCode");

		/// <summary>
		///Order Action Id
		/// </summary>
		public static string OrderActionId => I18NResource.GetString(ResourceDirectory, "OrderActionId");

		/// <summary>
		///Order Action Name
		/// </summary>
		public static string OrderActionName => I18NResource.GetString(ResourceDirectory, "OrderActionName");

		/// <summary>
		///Order Date
		/// </summary>
		public static string OrderDate => I18NResource.GetString(ResourceDirectory, "OrderDate");

		/// <summary>
		///Order Detail Id
		/// </summary>
		public static string OrderDetailId => I18NResource.GetString(ResourceDirectory, "OrderDetailId");

		/// <summary>
		///Order Event Id
		/// </summary>
		public static string OrderEventId => I18NResource.GetString(ResourceDirectory, "OrderEventId");

		/// <summary>
		///Order Id
		/// </summary>
		public static string OrderId => I18NResource.GetString(ResourceDirectory, "OrderId");

		/// <summary>
		///Order Kanban Detail Id
		/// </summary>
		public static string OrderKanbanDetailId => I18NResource.GetString(ResourceDirectory, "OrderKanbanDetailId");

		/// <summary>
		///Order Progress Id
		/// </summary>
		public static string OrderProgressId => I18NResource.GetString(ResourceDirectory, "OrderProgressId");

		/// <summary>
		///Order Status
		/// </summary>
		public static string OrderStatus => I18NResource.GetString(ResourceDirectory, "OrderStatus");

		/// <summary>
		///Order Status Code
		/// </summary>
		public static string OrderStatusCode => I18NResource.GetString(ResourceDirectory, "OrderStatusCode");

		/// <summary>
		///Order Status Id
		/// </summary>
		public static string OrderStatusId => I18NResource.GetString(ResourceDirectory, "OrderStatusId");

		/// <summary>
		///Order Status Name
		/// </summary>
		public static string OrderStatusName => I18NResource.GetString(ResourceDirectory, "OrderStatusName");

		/// <summary>
		///Order Type Code
		/// </summary>
		public static string OrderTypeCode => I18NResource.GetString(ResourceDirectory, "OrderTypeCode");

		/// <summary>
		///Order Type Id
		/// </summary>
		public static string OrderTypeId => I18NResource.GetString(ResourceDirectory, "OrderTypeId");

		/// <summary>
		///Order Type Name
		/// </summary>
		public static string OrderTypeName => I18NResource.GetString(ResourceDirectory, "OrderTypeName");

		/// <summary>
		///Parent
		/// </summary>
		public static string Parent => I18NResource.GetString(ResourceDirectory, "Parent");

		/// <summary>
		///Parent Department
		/// </summary>
		public static string ParentDepartment => I18NResource.GetString(ResourceDirectory, "ParentDepartment");

		/// <summary>
		///Parent Plant Id
		/// </summary>
		public static string ParentPlantId => I18NResource.GetString(ResourceDirectory, "ParentPlantId");

		/// <summary>
		///Parent Work Center
		/// </summary>
		public static string ParentWorkCenter => I18NResource.GetString(ResourceDirectory, "ParentWorkCenter");

		/// <summary>
		///Parent Work Center Department Id
		/// </summary>
		public static string ParentWorkCenterDepartmentId => I18NResource.GetString(ResourceDirectory, "ParentWorkCenterDepartmentId");

		/// <summary>
		///Parent Work Center Id
		/// </summary>
		public static string ParentWorkCenterId => I18NResource.GetString(ResourceDirectory, "ParentWorkCenterId");

		/// <summary>
		///Payable Account Id
		/// </summary>
		public static string PayableAccountId => I18NResource.GetString(ResourceDirectory, "PayableAccountId");

		/// <summary>
		///Pay by Check
		/// </summary>
		public static string PayByCheck => I18NResource.GetString(ResourceDirectory, "PayByCheck");

		/// <summary>
		///Pay by Gift Card
		/// </summary>
		public static string PayByGiftCard => I18NResource.GetString(ResourceDirectory, "PayByGiftCard");

		/// <summary>
		///Pay by Check
		/// </summary>
		public static string PayCheck => I18NResource.GetString(ResourceDirectory, "PayCheck");

		/// <summary>
		///Pay by Gift Card
		/// </summary>
		public static string PayGiftCard => I18NResource.GetString(ResourceDirectory, "PayGiftCard");

		/// <summary>
		///Payment Card
		/// </summary>
		public static string PaymentCard => I18NResource.GetString(ResourceDirectory, "PaymentCard");

		/// <summary>
		///Payment Term
		/// </summary>
		public static string PaymentTerm => I18NResource.GetString(ResourceDirectory, "PaymentTerm");

		/// <summary>
		///Payment Term Code
		/// </summary>
		public static string PaymentTermCode => I18NResource.GetString(ResourceDirectory, "PaymentTermCode");

		/// <summary>
		///Payment Term Id
		/// </summary>
		public static string PaymentTermId => I18NResource.GetString(ResourceDirectory, "PaymentTermId");

		/// <summary>
		///Payment Term Name
		/// </summary>
		public static string PaymentTermName => I18NResource.GetString(ResourceDirectory, "PaymentTermName");

		/// <summary>
		///Payment Terms
		/// </summary>
		public static string PaymentTerms => I18NResource.GetString(ResourceDirectory, "PaymentTerms");

		/// <summary>
		///Payment Type
		/// </summary>
		public static string PaymentType => I18NResource.GetString(ResourceDirectory, "PaymentType");

		/// <summary>
		///Phone
		/// </summary>
		public static string Phone => I18NResource.GetString(ResourceDirectory, "Phone");

		/// <summary>
		///Phone Numbers
		/// </summary>
		public static string PhoneNumbers => I18NResource.GetString(ResourceDirectory, "PhoneNumbers");

		/// <summary>
		///Photo
		/// </summary>
		public static string Photo => I18NResource.GetString(ResourceDirectory, "Photo");

		/// <summary>
		///Pin Code
		/// </summary>
		public static string PinCode => I18NResource.GetString(ResourceDirectory, "PinCode");

		/// <summary>
		///Plant
		/// </summary>
		public static string Plant => I18NResource.GetString(ResourceDirectory, "Plant");

		/// <summary>
		///Plant Code
		/// </summary>
		public static string PlantCode => I18NResource.GetString(ResourceDirectory, "PlantCode");

		/// <summary>
		///Plant Id
		/// </summary>
		public static string PlantId => I18NResource.GetString(ResourceDirectory, "PlantId");

		/// <summary>
		///Plant Name
		/// </summary>
		public static string PlantName => I18NResource.GetString(ResourceDirectory, "PlantName");

		/// <summary>
		///Please enter the bank name.
		/// </summary>
		public static string PleaseEnterBankName => I18NResource.GetString(ResourceDirectory, "PleaseEnterBankName");

		/// <summary>
		///Please enter the check date.
		/// </summary>
		public static string PleaseEnterCheckDate => I18NResource.GetString(ResourceDirectory, "PleaseEnterCheckDate");

		/// <summary>
		///Please enter the check number.
		/// </summary>
		public static string PleaseEnterCheckNumber => I18NResource.GetString(ResourceDirectory, "PleaseEnterCheckNumber");

		/// <summary>
		///Please enter the gift card number.
		/// </summary>
		public static string PleaseEnterGiftCardNumber => I18NResource.GetString(ResourceDirectory, "PleaseEnterGiftCardNumber");

		/// <summary>
		///Please select a customer.
		/// </summary>
		public static string PleaseSelectCustomer => I18NResource.GetString(ResourceDirectory, "PleaseSelectCustomer");

		/// <summary>
		///Please select an item.
		/// </summary>
		public static string PleaseSelectItem => I18NResource.GetString(ResourceDirectory, "PleaseSelectItem");

		/// <summary>
		///Please select an item from the grid.
		/// </summary>
		public static string PleaseSelectItemFromGrid => I18NResource.GetString(ResourceDirectory, "PleaseSelectItemFromGrid");

		/// <summary>
		///Please select a payment term.
		/// </summary>
		public static string PleaseSelectPaymentTerm => I18NResource.GetString(ResourceDirectory, "PleaseSelectPaymentTerm");

		/// <summary>
		///Please select a tab.
		/// </summary>
		public static string PleaseSelectTab => I18NResource.GetString(ResourceDirectory, "PleaseSelectTab");

		/// <summary>
		///Po Box
		/// </summary>
		public static string PoBox => I18NResource.GetString(ResourceDirectory, "PoBox");

		/// <summary>
		///Posted By
		/// </summary>
		public static string PostedBy => I18NResource.GetString(ResourceDirectory, "PostedBy");

		/// <summary>
		///Posted By Name
		/// </summary>
		public static string PostedByName => I18NResource.GetString(ResourceDirectory, "PostedByName");

		/// <summary>
		///Posted Date
		/// </summary>
		public static string PostedDate => I18NResource.GetString(ResourceDirectory, "PostedDate");

		/// <summary>
		///Posted On
		/// </summary>
		public static string PostedOn => I18NResource.GetString(ResourceDirectory, "PostedOn");

		/// <summary>
		///Preferred Supplier Id
		/// </summary>
		public static string PreferredSupplierId => I18NResource.GetString(ResourceDirectory, "PreferredSupplierId");

		/// <summary>
		///Price
		/// </summary>
		public static string Price => I18NResource.GetString(ResourceDirectory, "Price");

		/// <summary>
		///Price Type
		/// </summary>
		public static string PriceType => I18NResource.GetString(ResourceDirectory, "PriceType");

		/// <summary>
		///Price Type Code
		/// </summary>
		public static string PriceTypeCode => I18NResource.GetString(ResourceDirectory, "PriceTypeCode");

		/// <summary>
		///Price Type Id
		/// </summary>
		public static string PriceTypeId => I18NResource.GetString(ResourceDirectory, "PriceTypeId");

		/// <summary>
		///Price Type Name
		/// </summary>
		public static string PriceTypeName => I18NResource.GetString(ResourceDirectory, "PriceTypeName");

		/// <summary>
		///Price Types
		/// </summary>
		public static string PriceTypes => I18NResource.GetString(ResourceDirectory, "PriceTypes");

		/// <summary>
		///Print
		/// </summary>
		public static string Print => I18NResource.GetString(ResourceDirectory, "Print");

		/// <summary>
		///Priority Code
		/// </summary>
		public static string PriorityCode => I18NResource.GetString(ResourceDirectory, "PriorityCode");

		/// <summary>
		///Priority Id
		/// </summary>
		public static string PriorityId => I18NResource.GetString(ResourceDirectory, "PriorityId");

		/// <summary>
		///Priority Name
		/// </summary>
		public static string PriorityName => I18NResource.GetString(ResourceDirectory, "PriorityName");

		/// <summary>
		///Produced Item Id
		/// </summary>
		public static string ProducedItemId => I18NResource.GetString(ResourceDirectory, "ProducedItemId");

		/// <summary>
		///Produced Quantity
		/// </summary>
		public static string ProducedQuantity => I18NResource.GetString(ResourceDirectory, "ProducedQuantity");

		/// <summary>
		///Provided By
		/// </summary>
		public static string ProvidedBy => I18NResource.GetString(ResourceDirectory, "ProvidedBy");

		/// <summary>
		///Purchase Date
		/// </summary>
		public static string PurchaseDate => I18NResource.GetString(ResourceDirectory, "PurchaseDate");

		/// <summary>
		///Quantity
		/// </summary>
		public static string Quantity => I18NResource.GetString(ResourceDirectory, "Quantity");

		/// <summary>
		///Quotation Detail Id
		/// </summary>
		public static string QuotationDetailId => I18NResource.GetString(ResourceDirectory, "QuotationDetailId");

		/// <summary>
		///Quotation Id
		/// </summary>
		public static string QuotationId => I18NResource.GetString(ResourceDirectory, "QuotationId");

		/// <summary>
		///Quotation Status
		/// </summary>
		public static string QuotationStatus => I18NResource.GetString(ResourceDirectory, "QuotationStatus");

		/// <summary>
		///Rate
		/// </summary>
		public static string Rate => I18NResource.GetString(ResourceDirectory, "Rate");

		/// <summary>
		///Raw Material Store Id
		/// </summary>
		public static string RawMaterialStoreId => I18NResource.GetString(ResourceDirectory, "RawMaterialStoreId");

		/// <summary>
		///Reason
		/// </summary>
		public static string Reason => I18NResource.GetString(ResourceDirectory, "Reason");

		/// <summary>
		///Receipt
		/// </summary>
		public static string Receipt => I18NResource.GetString(ResourceDirectory, "Receipt");

		/// <summary>
		///Receipt Checklist #
		/// </summary>
		public static string ReceiptChecklist => I18NResource.GetString(ResourceDirectory, "ReceiptChecklist");

		/// <summary>
		///Receipt Date
		/// </summary>
		public static string ReceiptDate => I18NResource.GetString(ResourceDirectory, "ReceiptDate");

		/// <summary>
		///Receipt from Customer
		/// </summary>
		public static string ReceiptFromCustomer => I18NResource.GetString(ResourceDirectory, "ReceiptFromCustomer");

		/// <summary>
		///Receipt Id
		/// </summary>
		public static string ReceiptId => I18NResource.GetString(ResourceDirectory, "ReceiptId");

		/// <summary>
		///Receipt Journal Summary Report
		/// </summary>
		public static string ReceiptJournalSummary => I18NResource.GetString(ResourceDirectory, "ReceiptJournalSummary");

		/// <summary>
		///Receipts
		/// </summary>
		public static string Receipts => I18NResource.GetString(ResourceDirectory, "Receipts");

		/// <summary>
		///Receipt Transaction Master Id
		/// </summary>
		public static string ReceiptTransactionMasterId => I18NResource.GetString(ResourceDirectory, "ReceiptTransactionMasterId");

		/// <summary>
		///Receipt Type
		/// </summary>
		public static string ReceiptType => I18NResource.GetString(ResourceDirectory, "ReceiptType");

		/// <summary>
		///Receipt Verification
		/// </summary>
		public static string ReceiptVerification => I18NResource.GetString(ResourceDirectory, "ReceiptVerification");

		/// <summary>
		///Received Amount in Above Currency
		/// </summary>
		public static string ReceivedAmountInAboveCurrency => I18NResource.GetString(ResourceDirectory, "ReceivedAmountInAboveCurrency");

		/// <summary>
		///Received Currency
		/// </summary>
		public static string ReceivedCurrency => I18NResource.GetString(ResourceDirectory, "ReceivedCurrency");

		/// <summary>
		///Reference Number
		/// </summary>
		public static string ReferenceNumber => I18NResource.GetString(ResourceDirectory, "ReferenceNumber");

		/// <summary>
		///Ref#
		/// </summary>
		public static string ReferenceNumberAbbreviated => I18NResource.GetString(ResourceDirectory, "ReferenceNumberAbbreviated");

		/// <summary>
		///Reject
		/// </summary>
		public static string Reject => I18NResource.GetString(ResourceDirectory, "Reject");

		/// <summary>
		///Reject Transaction
		/// </summary>
		public static string RejectTransaction => I18NResource.GetString(ResourceDirectory, "RejectTransaction");

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
		///Reports
		/// </summary>
		public static string Reports => I18NResource.GetString(ResourceDirectory, "Reports");

		/// <summary>
		///Reprint
		/// </summary>
		public static string Reprint => I18NResource.GetString(ResourceDirectory, "Reprint");

		/// <summary>
		///Reprint Ticket
		/// </summary>
		public static string ReprintTicket => I18NResource.GetString(ResourceDirectory, "ReprintTicket");

		/// <summary>
		///Return Id
		/// </summary>
		public static string ReturnId => I18NResource.GetString(ResourceDirectory, "ReturnId");

		/// <summary>
		///Return Transaction Master Id
		/// </summary>
		public static string ReturnTransactionMasterId => I18NResource.GetString(ResourceDirectory, "ReturnTransactionMasterId");

		/// <summary>
		///Revision Code
		/// </summary>
		public static string RevisionCode => I18NResource.GetString(ResourceDirectory, "RevisionCode");

		/// <summary>
		///Revision Number
		/// </summary>
		public static string RevisionNumber => I18NResource.GetString(ResourceDirectory, "RevisionNumber");

		/// <summary>
		///Reward Points
		/// </summary>
		public static string RewardPoints => I18NResource.GetString(ResourceDirectory, "RewardPoints");

		/// <summary>
		///Routing
		/// </summary>
		public static string Routing => I18NResource.GetString(ResourceDirectory, "Routing");

		/// <summary>
		///Routing Code
		/// </summary>
		public static string RoutingCode => I18NResource.GetString(ResourceDirectory, "RoutingCode");

		/// <summary>
		///Routing Id
		/// </summary>
		public static string RoutingId => I18NResource.GetString(ResourceDirectory, "RoutingId");

		/// <summary>
		///Routing Name
		/// </summary>
		public static string RoutingName => I18NResource.GetString(ResourceDirectory, "RoutingName");

		/// <summary>
		///Routing Sequence Code
		/// </summary>
		public static string RoutingSequenceCode => I18NResource.GetString(ResourceDirectory, "RoutingSequenceCode");

		/// <summary>
		///Routing Sequence Id
		/// </summary>
		public static string RoutingSequenceId => I18NResource.GetString(ResourceDirectory, "RoutingSequenceId");

		/// <summary>
		///Routing Sequence Name
		/// </summary>
		public static string RoutingSequenceName => I18NResource.GetString(ResourceDirectory, "RoutingSequenceName");

		/// <summary>
		///Routing Type Code
		/// </summary>
		public static string RoutingTypeCode => I18NResource.GetString(ResourceDirectory, "RoutingTypeCode");

		/// <summary>
		///Routing Type Id
		/// </summary>
		public static string RoutingTypeId => I18NResource.GetString(ResourceDirectory, "RoutingTypeId");

		/// <summary>
		///Routing Type Name
		/// </summary>
		public static string RoutingTypeName => I18NResource.GetString(ResourceDirectory, "RoutingTypeName");

		/// <summary>
		///Sales
		/// </summary>
		public static string Sales => I18NResource.GetString(ResourceDirectory, "Sales");

		/// <summary>
		///Sales by Office
		/// </summary>
		public static string SalesByOffice => I18NResource.GetString(ResourceDirectory, "SalesByOffice");

		/// <summary>
		///Sales Checklist #
		/// </summary>
		public static string SalesChecklist => I18NResource.GetString(ResourceDirectory, "SalesChecklist");

		/// <summary>
		///Sales Coupons
		/// </summary>
		public static string SalesCoupons => I18NResource.GetString(ResourceDirectory, "SalesCoupons");

		/// <summary>
		///Sales Discount Status
		/// </summary>
		public static string SalesDiscountStatus => I18NResource.GetString(ResourceDirectory, "SalesDiscountStatus");

		/// <summary>
		///Sales Entries
		/// </summary>
		public static string SalesEntries => I18NResource.GetString(ResourceDirectory, "SalesEntries");

		/// <summary>
		///Sales Entry
		/// </summary>
		public static string SalesEntry => I18NResource.GetString(ResourceDirectory, "SalesEntry");

		/// <summary>
		///Sales Entry Verification
		/// </summary>
		public static string SalesEntryVerification => I18NResource.GetString(ResourceDirectory, "SalesEntryVerification");

		/// <summary>
		///Sales Id
		/// </summary>
		public static string SalesId => I18NResource.GetString(ResourceDirectory, "SalesId");

		/// <summary>
		///Sales Order
		/// </summary>
		public static string SalesOrder => I18NResource.GetString(ResourceDirectory, "SalesOrder");

		/// <summary>
		///Sales Order Checklist
		/// </summary>
		public static string SalesOrderChecklist => I18NResource.GetString(ResourceDirectory, "SalesOrderChecklist");

		/// <summary>
		///Sales Order Id
		/// </summary>
		public static string SalesOrderId => I18NResource.GetString(ResourceDirectory, "SalesOrderId");

		/// <summary>
		///Sales Orders
		/// </summary>
		public static string SalesOrders => I18NResource.GetString(ResourceDirectory, "SalesOrders");

		/// <summary>
		///Salesperson Id
		/// </summary>
		public static string SalespersonId => I18NResource.GetString(ResourceDirectory, "SalespersonId");

		/// <summary>
		///Salesperson Name
		/// </summary>
		public static string SalespersonName => I18NResource.GetString(ResourceDirectory, "SalespersonName");

		/// <summary>
		///Sales Quotation
		/// </summary>
		public static string SalesQuotation => I18NResource.GetString(ResourceDirectory, "SalesQuotation");

		/// <summary>
		///Sales Quotation Checklist #
		/// </summary>
		public static string SalesQuotationChecklist => I18NResource.GetString(ResourceDirectory, "SalesQuotationChecklist");

		/// <summary>
		///Sales Quotation Id
		/// </summary>
		public static string SalesQuotationId => I18NResource.GetString(ResourceDirectory, "SalesQuotationId");

		/// <summary>
		///Sales Quotations
		/// </summary>
		public static string SalesQuotations => I18NResource.GetString(ResourceDirectory, "SalesQuotations");

		/// <summary>
		///Sales Receipt
		/// </summary>
		public static string SalesReceipt => I18NResource.GetString(ResourceDirectory, "SalesReceipt");

		/// <summary>
		///Sales Receipts
		/// </summary>
		public static string SalesReceipts => I18NResource.GetString(ResourceDirectory, "SalesReceipts");

		/// <summary>
		///Sales Return #
		/// </summary>
		public static string SalesReturn => I18NResource.GetString(ResourceDirectory, "SalesReturn");

		/// <summary>
		///Sales Return Checklist #
		/// </summary>
		public static string SalesReturnChecklist => I18NResource.GetString(ResourceDirectory, "SalesReturnChecklist");

		/// <summary>
		///Sales Returns
		/// </summary>
		public static string SalesReturns => I18NResource.GetString(ResourceDirectory, "SalesReturns");

		/// <summary>
		///Sales Return Verification
		/// </summary>
		public static string SalesReturnVerification => I18NResource.GetString(ResourceDirectory, "SalesReturnVerification");

		/// <summary>
		///Sales Verification
		/// </summary>
		public static string SalesVerification => I18NResource.GetString(ResourceDirectory, "SalesVerification");

		/// <summary>
		///Save
		/// </summary>
		public static string Save => I18NResource.GetString(ResourceDirectory, "Save");

		/// <summary>
		///Scheduled On
		/// </summary>
		public static string ScheduledOn => I18NResource.GetString(ResourceDirectory, "ScheduledOn");

		/// <summary>
		///Scrap Id
		/// </summary>
		public static string ScrapId => I18NResource.GetString(ResourceDirectory, "ScrapId");

		/// <summary>
		///Search ...
		/// </summary>
		public static string Search => I18NResource.GetString(ResourceDirectory, "Search");

		/// <summary>
		///Search Customer
		/// </summary>
		public static string SearchCustomer => I18NResource.GetString(ResourceDirectory, "SearchCustomer");

		/// <summary>
		///Search Gift Card
		/// </summary>
		public static string SearchGiftCard => I18NResource.GetString(ResourceDirectory, "SearchGiftCard");

		/// <summary>
		///Select
		/// </summary>
		public static string Select => I18NResource.GetString(ResourceDirectory, "Select");

		/// <summary>
		///Select & Close
		/// </summary>
		public static string SelectAndClose => I18NResource.GetString(ResourceDirectory, "SelectAndClose");

		/// <summary>
		///Select Cost Center
		/// </summary>
		public static string SelectCostCenter => I18NResource.GetString(ResourceDirectory, "SelectCostCenter");

		/// <summary>
		///Select Customer
		/// </summary>
		public static string SelectCustomer => I18NResource.GetString(ResourceDirectory, "SelectCustomer");

		/// <summary>
		///Select Debit Account
		/// </summary>
		public static string SelectDebitAccount => I18NResource.GetString(ResourceDirectory, "SelectDebitAccount");

		/// <summary>
		///Selling Price
		/// </summary>
		public static string SellingPrice => I18NResource.GetString(ResourceDirectory, "SellingPrice");

		/// <summary>
		///Selling Price Id
		/// </summary>
		public static string SellingPriceId => I18NResource.GetString(ResourceDirectory, "SellingPriceId");

		/// <summary>
		///Selling Price Includes Tax
		/// </summary>
		public static string SellingPriceIncludesTax => I18NResource.GetString(ResourceDirectory, "SellingPriceIncludesTax");

		/// <summary>
		///Selling Prices
		/// </summary>
		public static string SellingPrices => I18NResource.GetString(ResourceDirectory, "SellingPrices");

		/// <summary>
		///Sequence Number
		/// </summary>
		public static string SequenceNumber => I18NResource.GetString(ResourceDirectory, "SequenceNumber");

		/// <summary>
		///Serial Number
		/// </summary>
		public static string SerialNumber => I18NResource.GetString(ResourceDirectory, "SerialNumber");

		/// <summary>
		///Setup
		/// </summary>
		public static string Setup => I18NResource.GetString(ResourceDirectory, "Setup");

		/// <summary>
		///Shipper
		/// </summary>
		public static string Shipper => I18NResource.GetString(ResourceDirectory, "Shipper");

		/// <summary>
		///Shipper Id
		/// </summary>
		public static string ShipperId => I18NResource.GetString(ResourceDirectory, "ShipperId");

		/// <summary>
		///Shipping Charge
		/// </summary>
		public static string ShippingCharge => I18NResource.GetString(ResourceDirectory, "ShippingCharge");

		/// <summary>
		///Show
		/// </summary>
		public static string Show => I18NResource.GetString(ResourceDirectory, "Show");

		/// <summary>
		///Show Less
		/// </summary>
		public static string ShowLess => I18NResource.GetString(ResourceDirectory, "ShowLess");

		/// <summary>
		///Show More
		/// </summary>
		public static string ShowMore => I18NResource.GetString(ResourceDirectory, "ShowMore");

		/// <summary>
		///Sort
		/// </summary>
		public static string Sort => I18NResource.GetString(ResourceDirectory, "Sort");

		/// <summary>
		///Start Date Time
		/// </summary>
		public static string StartDateTime => I18NResource.GetString(ResourceDirectory, "StartDateTime");

		/// <summary>
		///Started On
		/// </summary>
		public static string StartedOn => I18NResource.GetString(ResourceDirectory, "StartedOn");

		/// <summary>
		///Starts From
		/// </summary>
		public static string StartsFrom => I18NResource.GetString(ResourceDirectory, "StartsFrom");

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
		///Store
		/// </summary>
		public static string Store => I18NResource.GetString(ResourceDirectory, "Store");

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
		///Street
		/// </summary>
		public static string Street => I18NResource.GetString(ResourceDirectory, "Street");

		/// <summary>
		///Submitted Amount
		/// </summary>
		public static string SubmittedAmount => I18NResource.GetString(ResourceDirectory, "SubmittedAmount");

		/// <summary>
		///The submitted amount must be equal to total amount.
		/// </summary>
		public static string SubmittedAmountMustEqualTotalAmount => I18NResource.GetString(ResourceDirectory, "SubmittedAmountMustEqualTotalAmount");

		/// <summary>
		///Submitted Cash
		/// </summary>
		public static string SubmittedCash => I18NResource.GetString(ResourceDirectory, "SubmittedCash");

		/// <summary>
		///Submitted To
		/// </summary>
		public static string SubmittedTo => I18NResource.GetString(ResourceDirectory, "SubmittedTo");

		/// <summary>
		///Sub Total
		/// </summary>
		public static string SubTotal => I18NResource.GetString(ResourceDirectory, "SubTotal");

		/// <summary>
		///Success
		/// </summary>
		public static string Success => I18NResource.GetString(ResourceDirectory, "Success");

		/// <summary>
		///Supervised By
		/// </summary>
		public static string SupervisedBy => I18NResource.GetString(ResourceDirectory, "SupervisedBy");

		/// <summary>
		///Tasks
		/// </summary>
		public static string Tasks => I18NResource.GetString(ResourceDirectory, "Tasks");

		/// <summary>
		///Tax
		/// </summary>
		public static string Tax => I18NResource.GetString(ResourceDirectory, "Tax");

		/// <summary>
		///Taxable Total
		/// </summary>
		public static string TaxableTotal => I18NResource.GetString(ResourceDirectory, "TaxableTotal");

		/// <summary>
		///Tax Rate
		/// </summary>
		public static string TaxRate => I18NResource.GetString(ResourceDirectory, "TaxRate");

		/// <summary>
		///10
		/// </summary>
		public static string Ten => I18NResource.GetString(ResourceDirectory, "Ten");

		/// <summary>
		///Tender
		/// </summary>
		public static string Tender => I18NResource.GetString(ResourceDirectory, "Tender");

		/// <summary>
		///Terms
		/// </summary>
		public static string Terms => I18NResource.GetString(ResourceDirectory, "Terms");

		/// <summary>
		///Terms & Conditions
		/// </summary>
		public static string TermsAndConditions => I18NResource.GetString(ResourceDirectory, "TermsAndConditions");

		/// <summary>
		///Terms & Conditions
		/// </summary>
		public static string TermsConditions => I18NResource.GetString(ResourceDirectory, "TermsConditions");

		/// <summary>
		///The ticket {0} could not be found.
		/// </summary>
		public static string TheTicketCouldNotBeFound => I18NResource.GetString(ResourceDirectory, "TheTicketCouldNotBeFound");

		/// <summary>
		///This customer does not have a default currency.
		/// </summary>
		public static string ThisCustomerDoesNotHaveDefaultCurrency => I18NResource.GetString(ResourceDirectory, "ThisCustomerDoesNotHaveDefaultCurrency");

		/// <summary>
		///this evening
		/// </summary>
		public static string ThisEvening => I18NResource.GetString(ResourceDirectory, "ThisEvening");

		/// <summary>
		///This Month
		/// </summary>
		public static string ThisMonth => I18NResource.GetString(ResourceDirectory, "ThisMonth");

		/// <summary>
		///This Office
		/// </summary>
		public static string ThisOffice => I18NResource.GetString(ResourceDirectory, "ThisOffice");

		/// <summary>
		///1000
		/// </summary>
		public static string Thousand => I18NResource.GetString(ResourceDirectory, "Thousand");

		/// <summary>
		///Time In Minutes
		/// </summary>
		public static string TimeInMinutes => I18NResource.GetString(ResourceDirectory, "TimeInMinutes");

		/// <summary>
		///title
		/// </summary>
		public static string Title => I18NResource.GetString(ResourceDirectory, "Title");

		/// <summary>
		///To
		/// </summary>
		public static string To => I18NResource.GetString(ResourceDirectory, "To");

		/// <summary>
		///Today's Beginning Cash
		/// </summary>
		public static string TodayBeginningCash => I18NResource.GetString(ResourceDirectory, "TodayBeginningCash");

		/// <summary>
		///Toggle View
		/// </summary>
		public static string ToggleView => I18NResource.GetString(ResourceDirectory, "ToggleView");

		/// <summary>
		///Top Customers
		/// </summary>
		public static string TopCustomers => I18NResource.GetString(ResourceDirectory, "TopCustomers");

		/// <summary>
		///Top Selling Items
		/// </summary>
		public static string TopSellingItems => I18NResource.GetString(ResourceDirectory, "TopSellingItems");

		/// <summary>
		///Total
		/// </summary>
		public static string Total => I18NResource.GetString(ResourceDirectory, "Total");

		/// <summary>
		///Total Amount
		/// </summary>
		public static string TotalAmount => I18NResource.GetString(ResourceDirectory, "TotalAmount");

		/// <summary>
		///Total Cash Sales
		/// </summary>
		public static string TotalCashSales => I18NResource.GetString(ResourceDirectory, "TotalCashSales");

		/// <summary>
		///Total Cycles
		/// </summary>
		public static string TotalCycles => I18NResource.GetString(ResourceDirectory, "TotalCycles");

		/// <summary>
		///Total Discount Amount
		/// </summary>
		public static string TotalDiscountAmount => I18NResource.GetString(ResourceDirectory, "TotalDiscountAmount");

		/// <summary>
		///Total Due Amount in Base Currency
		/// </summary>
		public static string TotalDueAmountInBaseCurrency => I18NResource.GetString(ResourceDirectory, "TotalDueAmountInBaseCurrency");

		/// <summary>
		///Total Sales
		/// </summary>
		public static string TotalSales => I18NResource.GetString(ResourceDirectory, "TotalSales");

		/// <summary>
		///:Total Usage
		/// </summary>
		public static string TotalUsage => I18NResource.GetString(ResourceDirectory, "TotalUsage");

		/// <summary>
		///Tran Code
		/// </summary>
		public static string TranCode => I18NResource.GetString(ResourceDirectory, "TranCode");

		/// <summary>
		///Tran Date
		/// </summary>
		public static string TranDate => I18NResource.GetString(ResourceDirectory, "TranDate");

		/// <summary>
		///Tran Id
		/// </summary>
		public static string TranId => I18NResource.GetString(ResourceDirectory, "TranId");

		/// <summary>
		///Transaction Code
		/// </summary>
		public static string TransactionCode => I18NResource.GetString(ResourceDirectory, "TransactionCode");

		/// <summary>
		///Transaction Counter
		/// </summary>
		public static string TransactionCounter => I18NResource.GetString(ResourceDirectory, "TransactionCounter");

		/// <summary>
		///Transaction Date
		/// </summary>
		public static string TransactionDate => I18NResource.GetString(ResourceDirectory, "TransactionDate");

		/// <summary>
		///Transaction Id
		/// </summary>
		public static string TransactionId => I18NResource.GetString(ResourceDirectory, "TransactionId");

		/// <summary>
		///Transaction Master Id
		/// </summary>
		public static string TransactionMasterId => I18NResource.GetString(ResourceDirectory, "TransactionMasterId");

		/// <summary>
		///Transaction was posted successfully.
		/// </summary>
		public static string TransactionPostedSuccessfully => I18NResource.GetString(ResourceDirectory, "TransactionPostedSuccessfully");

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
		///20
		/// </summary>
		public static string Twenty => I18NResource.GetString(ResourceDirectory, "Twenty");

		/// <summary>
		///25
		/// </summary>
		public static string TwentyFive => I18NResource.GetString(ResourceDirectory, "TwentyFive");

		/// <summary>
		///2
		/// </summary>
		public static string Two => I18NResource.GetString(ResourceDirectory, "Two");

		/// <summary>
		///200
		/// </summary>
		public static string Twohundred => I18NResource.GetString(ResourceDirectory, "Twohundred");

		/// <summary>
		///250
		/// </summary>
		public static string TwohundredFifty => I18NResource.GetString(ResourceDirectory, "TwohundredFifty");

		/// <summary>
		///Unit
		/// </summary>
		public static string Unit => I18NResource.GetString(ResourceDirectory, "Unit");

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
		///Unit Price
		/// </summary>
		public static string UnitPrice => I18NResource.GetString(ResourceDirectory, "UnitPrice");

		/// <summary>
		///Unverified
		/// </summary>
		public static string Unverified => I18NResource.GetString(ResourceDirectory, "Unverified");

		/// <summary>
		///Url
		/// </summary>
		public static string Url => I18NResource.GetString(ResourceDirectory, "Url");

		/// <summary>
		///Use
		/// </summary>
		public static string Use => I18NResource.GetString(ResourceDirectory, "Use");

		/// <summary>
		///User Agent
		/// </summary>
		public static string UserAgent => I18NResource.GetString(ResourceDirectory, "UserAgent");

		/// <summary>
		///User Id
		/// </summary>
		public static string UserId => I18NResource.GetString(ResourceDirectory, "UserId");

		/// <summary>
		///Using Gift Card
		/// </summary>
		public static string UsingGiftCard => I18NResource.GetString(ResourceDirectory, "UsingGiftCard");

		/// <summary>
		///Valid From
		/// </summary>
		public static string ValidFrom => I18NResource.GetString(ResourceDirectory, "ValidFrom");

		/// <summary>
		///Valid Till
		/// </summary>
		public static string ValidTill => I18NResource.GetString(ResourceDirectory, "ValidTill");

		/// <summary>
		///Valid Units
		/// </summary>
		public static string ValidUnits => I18NResource.GetString(ResourceDirectory, "ValidUnits");

		/// <summary>
		///Value Date
		/// </summary>
		public static string ValueDate => I18NResource.GetString(ResourceDirectory, "ValueDate");

		/// <summary>
		///Value Datetime
		/// </summary>
		public static string ValueDatetime => I18NResource.GetString(ResourceDirectory, "ValueDatetime");

		/// <summary>
		///Verification Reason
		/// </summary>
		public static string VerificationReason => I18NResource.GetString(ResourceDirectory, "VerificationReason");

		/// <summary>
		///Verification Status
		/// </summary>
		public static string VerificationStatus => I18NResource.GetString(ResourceDirectory, "VerificationStatus");

		/// <summary>
		///Verification Status Id
		/// </summary>
		public static string VerificationStatusId => I18NResource.GetString(ResourceDirectory, "VerificationStatusId");

		/// <summary>
		///Verification Status Name
		/// </summary>
		public static string VerificationStatusName => I18NResource.GetString(ResourceDirectory, "VerificationStatusName");

		/// <summary>
		///Verified
		/// </summary>
		public static string Verified => I18NResource.GetString(ResourceDirectory, "Verified");

		/// <summary>
		///Verified By
		/// </summary>
		public static string VerifiedBy => I18NResource.GetString(ResourceDirectory, "VerifiedBy");

		/// <summary>
		///Verified By User Id
		/// </summary>
		public static string VerifiedByUserId => I18NResource.GetString(ResourceDirectory, "VerifiedByUserId");

		/// <summary>
		///Verified On
		/// </summary>
		public static string VerifiedOn => I18NResource.GetString(ResourceDirectory, "VerifiedOn");

		/// <summary>
		///Verify
		/// </summary>
		public static string Verify => I18NResource.GetString(ResourceDirectory, "Verify");

		/// <summary>
		///Verify Gift Card Fund
		/// </summary>
		public static string VerifyGiftCardFund => I18NResource.GetString(ResourceDirectory, "VerifyGiftCardFund");

		/// <summary>
		///Via Check
		/// </summary>
		public static string ViaCheck => I18NResource.GetString(ResourceDirectory, "ViaCheck");

		/// <summary>
		///View Journal Advice
		/// </summary>
		public static string ViewJournalAdvice => I18NResource.GetString(ResourceDirectory, "ViewJournalAdvice");

		/// <summary>
		///View Order
		/// </summary>
		public static string ViewOrder => I18NResource.GetString(ResourceDirectory, "ViewOrder");

		/// <summary>
		///View Quotation
		/// </summary>
		public static string ViewQuotation => I18NResource.GetString(ResourceDirectory, "ViewQuotation");

		/// <summary>
		///View Receipt
		/// </summary>
		public static string ViewReceipt => I18NResource.GetString(ResourceDirectory, "ViewReceipt");

		/// <summary>
		///View Receipts
		/// </summary>
		public static string ViewReceipts => I18NResource.GetString(ResourceDirectory, "ViewReceipts");

		/// <summary>
		///View Sales
		/// </summary>
		public static string ViewSales => I18NResource.GetString(ResourceDirectory, "ViewSales");

		/// <summary>
		///View Sales Invoice
		/// </summary>
		public static string ViewSalesInvoice => I18NResource.GetString(ResourceDirectory, "ViewSalesInvoice");

		/// <summary>
		///View Sales Orders
		/// </summary>
		public static string ViewSalesOrders => I18NResource.GetString(ResourceDirectory, "ViewSalesOrders");

		/// <summary>
		///View Sales Quotation
		/// </summary>
		public static string ViewSalesQuotation => I18NResource.GetString(ResourceDirectory, "ViewSalesQuotation");

		/// <summary>
		///View Sales Quotations
		/// </summary>
		public static string ViewSalesQuotations => I18NResource.GetString(ResourceDirectory, "ViewSalesQuotations");

		/// <summary>
		///View Sales Return
		/// </summary>
		public static string ViewSalesReturn => I18NResource.GetString(ResourceDirectory, "ViewSalesReturn");

		/// <summary>
		///View Sales Returns
		/// </summary>
		public static string ViewSalesReturns => I18NResource.GetString(ResourceDirectory, "ViewSalesReturns");

		/// <summary>
		///Warm Up Time In Minutes
		/// </summary>
		public static string WarmUpTimeInMinutes => I18NResource.GetString(ResourceDirectory, "WarmUpTimeInMinutes");

		/// <summary>
		///Which Bank
		/// </summary>
		public static string WhichBank => I18NResource.GetString(ResourceDirectory, "WhichBank");

		/// <summary>
		///Wip Account Id
		/// </summary>
		public static string WipAccountId => I18NResource.GetString(ResourceDirectory, "WipAccountId");

		/// <summary>
		///Work Center
		/// </summary>
		public static string WorkCenter => I18NResource.GetString(ResourceDirectory, "WorkCenter");

		/// <summary>
		///Work Center Capacity Id
		/// </summary>
		public static string WorkCenterCapacityId => I18NResource.GetString(ResourceDirectory, "WorkCenterCapacityId");

		/// <summary>
		///Work Center Code
		/// </summary>
		public static string WorkCenterCode => I18NResource.GetString(ResourceDirectory, "WorkCenterCode");

		/// <summary>
		///Work Center Cost Code
		/// </summary>
		public static string WorkCenterCostCode => I18NResource.GetString(ResourceDirectory, "WorkCenterCostCode");

		/// <summary>
		///Work Center Cost Id
		/// </summary>
		public static string WorkCenterCostId => I18NResource.GetString(ResourceDirectory, "WorkCenterCostId");

		/// <summary>
		///Work Center Cost Name
		/// </summary>
		public static string WorkCenterCostName => I18NResource.GetString(ResourceDirectory, "WorkCenterCostName");

		/// <summary>
		///Work Center Department Code
		/// </summary>
		public static string WorkCenterDepartmentCode => I18NResource.GetString(ResourceDirectory, "WorkCenterDepartmentCode");

		/// <summary>
		///Work Center Department Id
		/// </summary>
		public static string WorkCenterDepartmentId => I18NResource.GetString(ResourceDirectory, "WorkCenterDepartmentId");

		/// <summary>
		///Work Center Department Name
		/// </summary>
		public static string WorkCenterDepartmentName => I18NResource.GetString(ResourceDirectory, "WorkCenterDepartmentName");

		/// <summary>
		///Work Center Id
		/// </summary>
		public static string WorkCenterId => I18NResource.GetString(ResourceDirectory, "WorkCenterId");

		/// <summary>
		///Work Center Name
		/// </summary>
		public static string WorkCenterName => I18NResource.GetString(ResourceDirectory, "WorkCenterName");

		/// <summary>
		///Work In Progress Store Id
		/// </summary>
		public static string WorkInProgressStoreId => I18NResource.GetString(ResourceDirectory, "WorkInProgressStoreId");

		/// <summary>
		///Work Time In Minutes
		/// </summary>
		public static string WorkTimeInMinutes => I18NResource.GetString(ResourceDirectory, "WorkTimeInMinutes");

		/// <summary>
		///Yes
		/// </summary>
		public static string Yes => I18NResource.GetString(ResourceDirectory, "Yes");

		/// <summary>
		///You
		/// </summary>
		public static string You => I18NResource.GetString(ResourceDirectory, "You");

		/// <summary>
		///you may also edit the beginning cash later
		/// </summary>
		public static string YouMayAlsoEditBeginningCashLater => I18NResource.GetString(ResourceDirectory, "YouMayAlsoEditBeginningCashLater");

		/// <summary>
		///you may also edit the beginning cash later
		/// </summary>
		public static string YouMayEditBeginningCashLater => I18NResource.GetString(ResourceDirectory, "YouMayEditBeginningCashLater");

		/// <summary>
		///Your Cash Sales
		/// </summary>
		public static string YourCashSales => I18NResource.GetString(ResourceDirectory, "YourCashSales");

		/// <summary>
		///Your Sales for
		/// </summary>
		public static string YourSalesFor => I18NResource.GetString(ResourceDirectory, "YourSalesFor");

		/// <summary>
		///Zipcode
		/// </summary>
		public static string Zipcode => I18NResource.GetString(ResourceDirectory, "Zipcode");

		/// <summary>
		///Zip Code
		/// </summary>
		public static string ZipCode => I18NResource.GetString(ResourceDirectory, "ZipCode");

		/// <summary>
		///Sales Ticket
		/// </summary>
		public static string SalesTicket => I18NResource.GetString(ResourceDirectory, "SalesTicket");

	}
}
