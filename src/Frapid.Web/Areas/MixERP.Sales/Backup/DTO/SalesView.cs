using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.sales_view")]
    public class SalesView
    {
        public long SalesId { get; set; }
        public long TransactionMasterId { get; set; }
        public string TransactionCode { get; set; }
        public int TransactionCounter { get; set; }
        public DateTime ValueDate { get; set; }
        public DateTime BookDate { get; set; }
        public DateTimeOffset TransactionTs { get; set; }
        public short VerificationStatusId { get; set; }
        public string VerificationStatusName { get; set; }
        public int VerifiedByUserId { get; set; }
        public string VerifiedBy { get; set; }
        public long CheckoutId { get; set; }
        public decimal NontaxableTotal { get; set; }
        public decimal TaxableTotal { get; set; }
        public decimal TaxRate { get; set; }
        public decimal Tax { get; set; }
        public decimal Discount { get; set; }
        public int PostedBy { get; set; }
        public string PostedByName { get; set; }
        public int OfficeId { get; set; }
        public bool Cancelled { get; set; }
        public string CancellationReason { get; set; }
        public int CashRepositoryId { get; set; }
        public string CashRepositoryCode { get; set; }
        public string CashRepositoryName { get; set; }
        public int PriceTypeId { get; set; }
        public string PriceTypeCode { get; set; }
        public string PriceTypeName { get; set; }
        public int CounterId { get; set; }
        public string CounterCode { get; set; }
        public string CounterName { get; set; }
        public int StoreId { get; set; }
        public string StoreCode { get; set; }
        public string StoreName { get; set; }
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public int SalespersonId { get; set; }
        public string SalespersonName { get; set; }
        public int GiftCardId { get; set; }
        public string GiftCardNumber { get; set; }
        public string GiftCardOwner { get; set; }
        public int CouponId { get; set; }
        public string CouponCode { get; set; }
        public string CouponName { get; set; }
        public bool IsFlatDiscount { get; set; }
        public decimal TotalDiscountAmount { get; set; }
        public bool IsCredit { get; set; }
        public int PaymentTermId { get; set; }
        public string PaymentTermCode { get; set; }
        public string PaymentTermName { get; set; }
        public string FiscalYearCode { get; set; }
        public long InvoiceNumber { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal Tender { get; set; }
        public decimal Change { get; set; }
        public string CheckNumber { get; set; }
        public DateTime? CheckDate { get; set; }
        public string CheckBankName { get; set; }
        public decimal CheckAmount { get; set; }
        public decimal RewardPoints { get; set; }
    }
}