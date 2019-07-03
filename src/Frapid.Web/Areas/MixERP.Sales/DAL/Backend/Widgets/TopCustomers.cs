using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;

namespace MixERP.Sales.DAL.Backend.Widgets
{
    public static class TopCustomers
    {
        public static async Task<dynamic> GetAsync(string tenant, int officeId)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                db.CacheResults = true;
                db.CacheMilliseconds = 5000; //5 seconds

                var sql = new Sql("SELECT * FROM inventory.top_customers_by_office_view WHERE office_id = @0;", officeId);
                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }
    }
}