namespace MixERP.Inventory.DTO
{
    public sealed class OpeningInventoryStatus
    {
        public int OfficeId { get; set; }
        public bool MultipleInventoryAllowed { get; set; }
        public bool HasOpeningInventory { get; set; }
    }
}