using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper;
using Frapid.Mapper.Database;
using Frapid.Mapper.Helpers;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DAL.Backend.Tasks.ReceiptEntry;
using MixERP.Sales.DTO;
using MixERP.Sales.QueryModels;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class Receipts
    {
        public static async Task<IEnumerable<dynamic>> GetSearchViewAsync(string tenant, int officeId, ReceiptSearch search)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM sales.customer_receipt_search_view");
                sql.Where("value_date BETWEEN @0 AND @1", search.From, search.To);
                sql.And("LOWER(tran_id) LIKE @0", search.TranId.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(tran_code) LIKE @0", search.TranCode.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(reference_number, '')) LIKE @0", search.ReferenceNumber.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(statement_reference, '')) LIKE @0", search.StatementReference.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(posted_by) LIKE @0", search.PostedBy.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(office) LIKE @0", search.Office.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(status, '')) LIKE @0", search.Status.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(verified_by, '')) LIKE @0", search.VerifiedBy.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(reason, '')) LIKE @0", search.Reason.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(customer, '')) LIKE @0", search.Customer.ToSqlLikeExpression().ToLower());

                if (search.Amount > 0)
                {
                    sql.And("amount = @0", search.Amount);
                }

                sql.And("office_id IN(SELECT * FROM core.get_office_ids(@0))", officeId);

                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }

        public static async Task<MerchantFeeSetup> GetMerchantFeeSetupAsync(string tenant, int merchantAccountId, int paymentCardId)
        {
            const string sql = "SELECT * FROM finance.merchant_fee_setup WHERE merchant_account_id=@0 AND payment_card_id=@1 AND deleted=@2;";
            return (await Factory.GetAsync<MerchantFeeSetup>(tenant, sql, merchantAccountId, paymentCardId, false).ConfigureAwait(false)).FirstOrDefault();
        }

        public static async Task<string> GetHomeCurrencyAsync(string tenant, int officeId)
        {
            const string sql = "SELECT core.get_currency_code_by_office_id(@0);";
            return await Factory.ScalarAsync<string>(tenant, sql, officeId).ConfigureAwait(false);
        }

        public static async Task<decimal> GetExchangeRateAsync(string tenant, int officeId, string sourceCurrencyCode, string destinationCurrencyCode)
        {
            const string sql = "SELECT finance.convert_exchange_rate(@0, @1, @2);";
            return await Factory.ScalarAsync<decimal>(tenant, sql, officeId, sourceCurrencyCode, destinationCurrencyCode).ConfigureAwait(false);
        }

        public static async Task<CustomerTransactionSummary> GetCustomerTransactionSummaryAsync(string tenant, int officeId, int customerId)
        {
            const string sql = "SELECT * FROM inventory.get_customer_transaction_summary(@0, @1);";
            return (await Factory.GetAsync<CustomerTransactionSummary>(tenant, sql, officeId, customerId).ConfigureAwait(false)).FirstOrDefault();
        }

        private static IReceiptEntry LocateService(string tenant)
        {
            string providerName = DbProvider.GetProviderName(tenant);
            var type = DbProvider.GetDbType(providerName);

            if (type == DatabaseType.PostgreSQL)
            {
                return new PostgreSQL();
            }

            if (type == DatabaseType.SqlServer)
            {
                return new SqlServer();
            }

            throw new NotImplementedException();
        }

        public static async Task<long> PostAsync(string tenant, SalesReceipt model)
        {
            var service = LocateService(tenant);
            return await service.PostAsync(tenant, model).ConfigureAwait(false);
        }
    }
}