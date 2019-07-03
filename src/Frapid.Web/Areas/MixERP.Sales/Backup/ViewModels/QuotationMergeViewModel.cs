using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public sealed class QuotationMergeViewModel
    {
        public QuotationInfo Quotation { get; set; }
        public IEnumerable<QuotationDetail> Details { get; set; }
    }
}