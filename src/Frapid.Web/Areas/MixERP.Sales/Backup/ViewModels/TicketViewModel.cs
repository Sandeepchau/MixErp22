using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public sealed class TicketViewModel
    {
        public SalesView View { get; set; }
        public IEnumerable<CheckoutDetailView> Details { get; set; }
        public IEnumerable<CouponView> DiscountCoupons { get; set; }
    }
}