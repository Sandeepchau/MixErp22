using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public sealed class OrderMergeViewModel
    {
        public OrderInfo Order { get; set; }
        public IEnumerable<OrderDetail> Details { get; set; }
    }
}