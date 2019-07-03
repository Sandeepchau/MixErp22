using System;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class OpeningCashTransactions
    {
        public static async Task<OpeningCash> GetAsync(string tenant, int userId, DateTime transactionDate)
        {
            string sql = "SELECT * FROM sales.opening_cash WHERE user_id=@0 AND transaction_date=@1 AND deleted=@2;";
            var result = await Factory.GetAsync<OpeningCash>(tenant, sql, userId, transactionDate, false).ConfigureAwait(false);
            return result.FirstOrDefault();
        }

        public static async Task AddAsync(string tenant, OpeningCash model)
        {
            string sql = FrapidDbServer.GetProcedureCommand(tenant, "sales.add_opening_cash", new[] { "@0", "@1", "@2", "@3", "@4" });
            await Factory.NonQueryAsync(tenant, sql, model.UserId, model.TransactionDate.Date, model.Amount, model.ProvidedBy, model.Memo.Or("")).ConfigureAwait(false);
        }
    }
}