using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class Tickets
    {
        public static async Task<SalesView> GetSalesViewAsync(string tenant, long tranId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM sales.sales_view");
                sql.Where("transaction_master_id=@0", tranId);

                var awaiter = await db.SelectAsync<SalesView>(sql).ConfigureAwait(false);
                return awaiter.FirstOrDefault();
            }
        }

        public static async Task<IEnumerable<CheckoutDetailView>> GetCheckoutDetailViewAsync(string tenant, long tranId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM inventory.checkout_detail_view");
                sql.Where("transaction_master_id=@0", tranId);
                return await db.SelectAsync<CheckoutDetailView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<List<CouponView>> GetCouponViewAsync(string tenant, long tranId)
        {
            const string sql = "SELECT * FROM sales.coupon_view WHERE coupon_id IN (SELECT * FROM sales.get_avaiable_coupons_to_print(@0));";
            var awaiter = await Factory.GetAsync<CouponView>(tenant, sql, tranId).ConfigureAwait(false);
            return awaiter.ToList();
        }
    }
}