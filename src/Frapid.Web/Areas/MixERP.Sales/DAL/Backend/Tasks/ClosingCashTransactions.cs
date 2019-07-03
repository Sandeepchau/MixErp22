using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.NonQuery;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class ClosingCashTransactions
    {
        public static async Task<IEnumerable<SalesView>> GetCashSalesViewAsync(string tenant, int userId, DateTime transacitonDate)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM sales.sales_view");
                sql.Where("tender > 0");
                sql.And("verification_status_id > 0");
                sql.And("value_date=@0", transacitonDate.Date);
                sql.And("posted_by=@0", userId);

                return await db.SelectAsync<SalesView>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<ClosingCash> GetAsync(string tenant, int userId, DateTime transactionDate)
        {
            string sql = "SELECT * FROM sales.closing_cash WHERE user_id=@0 AND transaction_date=@1 AND deleted=@2";
            var result = await Factory.GetAsync<ClosingCash>(tenant, sql, userId, transactionDate, false).ConfigureAwait(false);
            return result.FirstOrDefault();
        }

        public static async Task AddAsync(string tenant, ClosingCash model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                try
                {
                    await db.BeginTransactionAsync().ConfigureAwait(false);

                    await db.InsertAsync("sales.closing_cash", "closing_cash_id", true, model).ConfigureAwait(false);

                    var sql = new Sql("UPDATE sales.opening_cash SET closed=@0", true);
                    sql.Where("user_id=@0 AND transaction_date=@1", model.UserId, model.TransactionDate);

                    await db.NonQueryAsync(sql).ConfigureAwait(false);

                    db.CommitTransaction();
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
    }
}