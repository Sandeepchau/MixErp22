namespace MixERP.Inventory.DTO
{
    public sealed class ClosingInventory
    {
        public int ItemId { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public int UnitId { get; set; }
        public string UnitName { get; set; }
        public decimal Quantity { get; set; }
    }
}