using System.ComponentModel.DataAnnotations;

namespace MixERP.Inventory.ViewModels
{
    public sealed class AdjustmentType
    {
        [Required]
        public string TransactionType { get; set; }
        [Required]
        public string ItemCode { get; set; }
        [Required]
        public string UnitName { get; set; }
        [Required]
        public decimal Quantity { get; set; }
    }
}