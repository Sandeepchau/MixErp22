using System;
using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.closing_cash")]
    [PrimaryKey("closing_cash_id", AutoIncrement = true)]
    public sealed class ClosingCash
    {
        public long ClosingCashId { get; set; }
        public int UserId { get; set; }
        public DateTime TransactionDate { get; set; }
        public decimal OpeningCash { get; set; }
        public decimal TotalCashSales { get; set; }
        public int? Deno1000 { get; set; }
        public int? Deno500 { get; set; }
        public int? Deno250 { get; set; }
        public int? Deno200 { get; set; }
        public int? Deno100 { get; set; }
        public int? Deno50 { get; set; }
        public int? Deno25 { get; set; }
        public int? Deno20 { get; set; }
        public int? Deno10 { get; set; }
        public int? Deno5 { get; set; }
        public int? Deno2 { get; set; }
        public int? Deno1 { get; set; }
        public decimal? Coins { get; set; }
        public decimal SubmittedCash { get; set; }
        public string SubmittedTo { get; set; }
        public string Memo { get; set; }
        public int? ApprovedBy { get; set; }
        public string ApprovalMemo { get; set; }
        public int? AuditUserId { get; set; }
        public DateTimeOffset AuditTs { get; set; }
        public bool Deleted { get; set; }
    }
}