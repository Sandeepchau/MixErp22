namespace MixERP.Finance.ViewModels
{
    public class TrialBalanceTreeViewModel
    {
        public int AccountId { get; set; }
        public string AccountNumber{ get; set; }
        public string Title { get; set; }
        public decimal PreviousDebit { get; set; }
        public int PreviousCredit { get; set; }
        public int Debit { get; set; }
        public decimal Credit { get; set; }
        public decimal ClosingDebit { get; set; }
        public decimal ClosingCredit { get; set; }
        public int ParentAccountId { get; set; }
    }
}