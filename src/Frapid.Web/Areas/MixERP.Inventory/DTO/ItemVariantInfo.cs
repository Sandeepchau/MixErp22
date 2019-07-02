namespace MixERP.Inventory.DTO
{
    public sealed class ItemVariantInfo
    {
        public  int VariantOf { get; set; }
        public int ItemId { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public int[] Variants { get; set; }
        public int UserId { get; set; }
    }
}