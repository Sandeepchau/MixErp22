using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.customerwise_selling_prices")]
    [PrimaryKey("selling_price_id", AutoIncrement = true)]
    public sealed class CustomerwiseSellingPrice : IPoco
    {
        public long SellingPriceId { get; set; }
        public int CustomerId { get; set; }
        public int ItemId { get; set; }
        public int UnitId { get; set; }
        public decimal? Price { get; set; }
        public bool IsTaxable { get; set; }
        public int? AuditUserId { get; set; }
        public DateTimeOffset? AuditTs { get; set; }
        public bool? Deleted { get; set; }
    }
}