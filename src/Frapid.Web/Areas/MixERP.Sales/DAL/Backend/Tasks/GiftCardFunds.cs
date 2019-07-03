using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper.Database;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class GiftCardFunds
    {
        public static async Task<decimal> GetBalanceAsync(string tenant, string giftCardNumber, int officeId)
        {
            const string sql = "SELECT sales.get_gift_card_balance(sales.get_gift_card_id_by_gift_card_number(@0), finance.get_value_date(@1));";
            return await Factory.ScalarAsync<decimal>(tenant, sql, giftCardNumber, officeId).ConfigureAwait(false);
        }

        public static async Task<long> AddAsync(string tenant, GiftCardFund model)
        {
            string sql = @"SELECT * FROM sales.add_gift_card_fund(@0::integer, @1::integer, @2::bigint, sales.get_gift_card_id_by_gift_card_number(@3), @4::date, @5::date, @6::integer, @7::public.money_strict, @8::integer, @9, @10);";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = FrapidDbServer.GetProcedureCommand(tenant, "sales.add_gift_card_fund", new[] { "@0", "@1", "@2", "@3", "@4", "@5", "@6", "@7", "@8", "@9", "@10" });
            }

            return await Factory.ScalarAsync<long>(tenant, sql, model.UserId, model.OfficeId, model.LoginId, model.GiftCardNumber, model.ValueDate, model.BookDate, model.AccountId, model.Amount,
                        model.CostCenterId, model.ReferenceNumber, model.StatementReference).ConfigureAwait(false);
        }
    }
}