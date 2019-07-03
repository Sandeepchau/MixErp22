﻿using System.ComponentModel.DataAnnotations;

namespace MixERP.Sales.ViewModels
{
    public sealed class SalesDetailType
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
        public decimal DiscountRate { get; set; }
        public decimal Discount { get; set; }
        public bool IsTaxed { get; set; }
        public decimal ShippingCharge { get; set; }
    }
}