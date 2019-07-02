namespace MixERP.Inventory.ViewModels
{
    public sealed class OpeningInventoryViewModel
    {
        public int OfficeId { get; set; }
        public string OfficeName { get; set; }
        public string OfficeCode { get; set; }
        public bool MultipleInventoryAllowed { get; set; }
        public bool HasOpeningInventory { get; set; }
    }
}