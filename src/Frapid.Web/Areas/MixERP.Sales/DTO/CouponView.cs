using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.coupon_view")]
    public sealed class CouponView
    {
        public int CouponId { get; set; }
        public string CouponCode { get; set; }
        public string CouponName { get; set; }
        public bool IsPercentage { get; set; }
        public decimal DiscountRate { get; set; }
        public decimal? MaximumDiscountAmount { get; set; }
        public int? AssociatedPriceTypeId { get; set; }
        public string AssociatedPriceTypeCode { get; set; }
        public string AssociatedPriceTypeName { get; set; }
        public decimal? MinimumPurchaseAmount { get; set; }
        public decimal? MaximumPurchaseAmount { get; set; }
        public DateTime? BeginsFrom { get; set; }
        public DateTime? ExpiresOn { get; set; }
        public int? MaximumUsage { get; set; }
        public bool EnableTicketPrinting { get; set; }
        public int? ForTicketOfPriceTypeId { get; set; }
        public string ForTicketOfPriceTypeCode { get; set; }
        public string ForTicketOfPriceTypeName { get; set; }
        public decimal? ForTicketHavingMinimumAmount { get; set; }
        public decimal? ForTicketHavingMaximumAmount { get; set; }
        public bool? ForTicketOfUnknownCustomersOnly { get; set; }
    }
}