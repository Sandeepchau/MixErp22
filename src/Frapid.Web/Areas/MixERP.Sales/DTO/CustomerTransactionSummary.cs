namespace MixERP.Sales.DTO
{
    public sealed class CustomerTransactionSummary
    {
        public string CurrencyCode { get; set; }
        public string CurrencySymbol { get; set; }
        public decimal TotalDueAmount { get; set; }
        public decimal OfficeDueAmount { get; set; }
    }
}