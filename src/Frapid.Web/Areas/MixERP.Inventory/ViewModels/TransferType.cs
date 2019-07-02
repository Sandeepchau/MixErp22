namespace MixERP.Inventory.ViewModels
{
    public sealed class TransferType
    {
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public decimal Quantity { get; set; }
        public string StoreName { get; set; }
        public TransferTypeEnum TransferTypeEnum { get; set; }
        public string UnitName { get; set; }
    }
}