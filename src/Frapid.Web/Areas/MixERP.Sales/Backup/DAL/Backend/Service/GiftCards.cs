using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using Frapid.Mapper;
using MixERP.Sales.DTO;
using MixERP.Sales.QueryModels;

namespace MixERP.Sales.DAL.Backend.Service
{
    public static class GiftCards
    {
        private static string WrapSearchWildcard(string text)
        {
            return "%" + text.Or("") + "%";
        }

        public static async Task<List<GiftCardSearchView>> SearchAsync(string tenant, GiftCardSearch query)
        {
            var sql = new Sql("SELECT * FROM sales.gift_card_search_view");
            sql.Where("UPPER(COALESCE(name, '')) LIKE @0", WrapSearchWildcard(query.Name).ToUpper());
            sql.And("UPPER(COALESCE(address, '')) LIKE @0", WrapSearchWildcard(query.Address).ToUpper());
            sql.And("UPPER(COALESCE(city, '')) LIKE @0", WrapSearchWildcard(query.City).ToUpper());
            sql.And("UPPER(COALESCE(state, '')) LIKE @0", WrapSearchWildcard(query.State).ToUpper());
            sql.And("UPPER(COALESCE(country, '')) LIKE @0", WrapSearchWildcard(query.Country).ToUpper());
            sql.And("UPPER(COALESCE(po_box, '')) LIKE @0", WrapSearchWildcard(query.PoBox).ToUpper());
            sql.And("UPPER(COALESCE(zip_code, '')) LIKE @0", WrapSearchWildcard(query.ZipCode).ToUpper());
            sql.And("UPPER(COALESCE(phone_numbers, '')) LIKE @0", WrapSearchWildcard(query.Phone).ToUpper());

            var awaiter = await Factory.GetAsync<GiftCardSearchView>(tenant, sql).ConfigureAwait(false);
            return awaiter.ToList();
        }
    }
}