using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;

namespace MixERP.Sales.DAL.Backend.Widgets
{
    public static class AccountReceivables
    {
        public static async Task<dynamic> GetAsync(string tenant, int officeId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                db.CacheResults = true;
                db.CacheMilliseconds = 5000; //5 seconds

                var sql = new Sql("SELECT * FROM sales.get_account_receivable_widget_details(@0);", officeId);
                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }
    }
}