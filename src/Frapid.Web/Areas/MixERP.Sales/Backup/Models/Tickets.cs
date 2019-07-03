using System.Threading.Tasks;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.Models
{
    public static class Tickets
    {
        public static async Task<TicketViewModel> GetTicketViewModelAsync(string tenant, long tranId)
        {
            var sales = await DAL.Backend.Tasks.Tickets.GetSalesViewAsync(tenant, tranId).ConfigureAwait(false);
            var details = await DAL.Backend.Tasks.Tickets.GetCheckoutDetailViewAsync(tenant, tranId).ConfigureAwait(false);
            var coupons = await DAL.Backend.Tasks.Tickets.GetCouponViewAsync(tenant, tranId).ConfigureAwait(false);

            return new TicketViewModel
            {
                View = sales,
                Details = details,
                DiscountCoupons = coupons
            };
        }
    }
}