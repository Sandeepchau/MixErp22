using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Inventory.DTO
{
    [TableName("inventory.items")]
    [PrimaryKey("item_id")]
    public sealed class Item
    {
        public int ItemId { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public string Barcode { get; set; }
        public int ItemGroupId { get; set; }
        public int ItemTypeId { get; set; }
        public int BrandId { get; set; }
        public int PreferredSupplierId { get; set; }
        public int LeadTimeInDays { get; set; }
        public int UnitId { get; set; }
        public bool HotItem { get; set; }
        public decimal CostPrice { get; set; }
        public decimal SellingPrice { get; set; }
        public decimal ReorderLevel { get; set; }
        public decimal ReorderQuantity { get; set; }
        public int ReorderUnitId { get; set; }
        public bool MaintainInventory { get; set; }
        public string Photo { get; set; }
        public bool AllowSales { get; set; }
        public bool AllowPurchase { get; set; }
        public int IsVariantOf { get; set; }
        public int AuditUserId { get; set; }
        public DateTimeOffset AuditTs { get; set; }
        public bool Deleted { get; set; }
    }
}