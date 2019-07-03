using System;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Sales.ViewModels
{
    public sealed class GiftCardFund
    {
        public int OfficeId { get; set; }
        public int UserId { get; set; }
        public long LoginId { get; set; }
        [Required]
        public string GiftCardNumber { get; set; }
        [Required]
        public DateTime ValueDate { get; set; }

        [Required]
        public DateTime BookDate { get; set; }
        [Required]
        public int AccountId { get; set; }
        [Required]
        public decimal Amount { get; set; }
        public int CostCenterId { get; set; }
        public string ReferenceNumber { get; set; }
        public string StatementReference { get; set; }
    }
}