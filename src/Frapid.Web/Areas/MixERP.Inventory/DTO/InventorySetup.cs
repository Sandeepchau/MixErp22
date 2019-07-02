using System.ComponentModel.DataAnnotations;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.Inventory.DTO
{
    [TableName("inventory.inventory_setup")]
    [PrimaryKey("office_id", AutoIncrement = false)]
    public sealed class InventorySetup : IPoco
    {
        public int OfficeId { get; set; }
        [Required]
        public string InventorySystem { get; set; }
        [Required]
        public string CogsCalculationMethod { get; set; }
        [Required]
        public bool AllowMultipleOpeningInventory { get; set; }
        [Required]
        public int DefaultDiscountAccountId { get; set; }
        [Required]
        public bool UsePosCheckoutScreen { get; set; }
        [Required]
        public bool ValidateReturns { get; set; }
    }
}