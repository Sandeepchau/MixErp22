using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("inventory.checkout_detail_view")]
    public sealed class CheckoutDetailView
    {
        public long TransactionMasterId { get; set; }
        public long CheckoutId { get; set; }
        public long CheckoutDetailId { get; set; }
        public string TransactionType { get; set; }
        public int StoreId { get; set; }
        public string StoreCode { get; set; }
        public string StoreName { get; set; }
        public int ItemId { get; set; }
        public bool IsTaxableItem { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public decimal Quantity { get; set; }
        public int UnitId { get; set; }
        public string UnitCode { get; set; }
        public string UnitName { get; set; }
        public decimal BaseQuantity { get; set; }
        public int BaseUnitId { get; set; }
        public string BaseUnitCode { get; set; }
        public string BaseUnitName { get; set; }
        public decimal Price { get; set; }
        public decimal Discount { get; set; }
        public decimal ShippingCharge { get; set; }
        public decimal Amount { get; set; }
        public decimal Total { get; set; }
    }
}