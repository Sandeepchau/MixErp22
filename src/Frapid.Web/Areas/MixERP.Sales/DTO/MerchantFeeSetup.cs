using System;
using Frapid.DataAccess;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [PrimaryKey("merchant_fee_setup_id", AutoIncrement = true, IsIdentity = true)]
    [TableName("core.merchant_fee_setup")]
    public sealed class MerchantFeeSetup : IPoco
    {
        public int MerchantFeeSetupId { get; set; }
        public long MerchantAccountId { get; set; }
        public int PaymentCardId { get; set; }
        public decimal Rate { get; set; }
        public bool CustomerPaysFee { get; set; }
        public long AccountId { get; set; }
        public string StatementReference { get; set; }
        public int? AuditUserId { get; set; }
        public DateTimeOffset? AuditTs { get; set; }
    }
}