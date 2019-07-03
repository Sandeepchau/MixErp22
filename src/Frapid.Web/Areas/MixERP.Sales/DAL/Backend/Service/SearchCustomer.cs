using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class Customers
    {
        public static async Task<List<CustomerSearchResult>> SearchAsync(string tenant, string query)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                query = "%" + query.ToUpper() + "%";

                var sql = new Sql(@"SELECT 
                                    customer_id, 
                                    customer_code, 
                                    customer_name,
                                    COALESCE(photo, '/Static/images/mixerp/logo.png') AS photo,
                                    contact_phone_numbers AS phone_numbers
                                FROM inventory.customers
                                WHERE UPPER(inventory.customers.customer_name) LIKE @0
                                OR UPPER(inventory.customers.customer_code) LIKE @0
                                OR UPPER(inventory.customers.contact_address_line_1) LIKE @0
                                OR UPPER(inventory.customers.contact_address_line_2) LIKE @0
                                OR UPPER(inventory.customers.contact_street) LIKE @0
                                OR UPPER(inventory.customers.contact_city) LIKE @0
                                OR UPPER(inventory.customers.contact_phone_numbers) LIKE @0", query);

                sql.Limit(db.DatabaseType, 10, 0, "customer_id");

                var result = await db.SelectAsync<CustomerSearchResult>(sql).ConfigureAwait(false);
                return result.ToList();
            }
        }
    }
}