using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace MixERP.Sales.ViewModels
{
    public sealed class Sales
    {
        public int OfficeId { get; set; }
        public int UserId { get; set; }
        public long LoginId { get; set; }

        [Required]
        public int CounterId { get; set; }

        [Required]
        public DateTime ValueDate { get; set; }

        [Required]
        public DateTime BookDate { get; set; }

        [Required]
        public int PriceTypeId { get; set; }
        [Required]
        public int StoreId { get; set; }

        public int CostCenterId { get; set; }
        public string ReferenceNumber { get; set; }
        public string StatementReference { get; set; }

        public decimal Tender { get; set; }
        public decimal Change { get; set; }

        public int? PaymentTermId { get; set; }
        public decimal? CheckAmount { get; set; }
        public string CheckNumber { get; set; }
        public string CheckBankName { get; set; }
        public DateTime? CheckDate { get; set; }

        public string GiftCardNumber { get; set; }


        public int CustomerId { get; set; }


        public int ShipperId { get; set; }



        public string CouponCode { get; set; }

        public bool IsFlatDiscount { get; set; }
        public decimal Discount { get; set; }


        [Required]
        public List<SalesDetailType> Details { get; set; }

        public long? SalesQuotationId { get; set; }
        public long? SalesOrderId { get; set; }
        public string SerialNumberIds { get; set; }
    }
}