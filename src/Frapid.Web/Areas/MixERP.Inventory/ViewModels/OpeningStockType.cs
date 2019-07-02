using System.ComponentModel.DataAnnotations;

namespace MixERP.Inventory.ViewModels
{
    public sealed class OpeningStockType
    {
        [Required]
        public int StoreId { get; set; }
        [Required]
        public int ItemId { get; set; }
        [Required]
        public decimal Quantity { get; set; }
        [Required]
        public int UnitId { get; set; }
        [Required]
        public decimal Price { get; set; }
    }
}