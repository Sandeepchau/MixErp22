﻿using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.order_details")]
    [PrimaryKey("order_detail_id")]
    public class OrderDetail
    {
        public long OrderDetailId { get; set; }
        public long OrderId { get; set; }
        public DateTime ValueDate { get; set; }
        public int ItemId { get; set; }
        public decimal Price { get; set; }
        public decimal Discount { get; set; }
        public decimal DiscountRate { get; set; }
        public decimal ShippingCharge { get; set; }
        public bool IsTaxed { get; set; }
        public int UnitId { get; set; }
        public decimal Quantity { get; set; }
    }
}