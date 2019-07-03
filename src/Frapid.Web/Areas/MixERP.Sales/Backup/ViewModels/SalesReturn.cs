using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Sales.ViewModels
{
    public sealed class SalesReturn
    {
        public long TransactionMasterId { get; set; }
        public int OfficeId { get; set; }
        public int UserId { get; set; }
        public long LoginId { get; set; }

        [Required]
        public DateTime ValueDate { get; set; }

        [Required]
        public DateTime BookDate { get; set; }

        [Required]
        public int StoreId { get; set; }

        [Required]
        public int CounterId { get; set; }

        public int CustomerId { get; set; }

        [Required]
        public int PriceTypeId { get; set; }

        public string ReferenceNumber { get; set; }
        public string StatementReference { get; set; }

        public int? ShipperId { get; set; }
        public decimal Discount { get; set; }

        [Required]
        public List<SalesDetailType> Details { get; set; }
    }
}