using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Sales.ViewModels
{
    public sealed class OpeningCash
    {        
        public int UserId { get; set; }
        public DateTime TransactionDate { get; set; }
        [Required]
        public decimal Amount { get; set; }
        [Required]
        public string ProvidedBy { get; set; }
        public string Memo { get; set; }
        public bool Closed { get; set; }
    }
}