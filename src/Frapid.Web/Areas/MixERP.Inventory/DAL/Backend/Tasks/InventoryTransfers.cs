using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.Mapper;
using Frapid.Mapper.Database;
using Frapid.Mapper.Helpers;
using Frapid.Mapper.Query.Select;
using MixERP.Inventory.DAL.Backend.Tasks.TransferEntry;
using MixERP.Inventory.QueryModels;
using MixERP.Inventory.ViewModels;

namespace MixERP.Inventory.DAL.Backend.Tasks
{
    public static class InventoryTransfers
    {
        public static async Task<IEnumerable<dynamic>> GetSearchViewAsync(string tenant, int officeId, TransferSearch search)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM inventory.transfer_search_view");
                sql.Where("value_date BETWEEN @0 AND @1", search.From, search.To);

                sql.And("CAST(tran_id AS varchar(100)) LIKE @0", search.TranId.ToSqlLikeExpression().ToLower());

                sql.And("LOWER(tran_code) LIKE @0", search.TranCode.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(reference_number, '')) LIKE @0", search.ReferenceNumber.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(statement_reference, '')) LIKE @0", search.StatementReference.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(posted_by) LIKE @0", search.PostedBy.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(office) LIKE @0", search.Office.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(status, '')) LIKE @0", search.Status.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(verified_by, '')) LIKE @0", search.VerifiedBy.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(COALESCE(reason, '')) LIKE @0", search.Reason.ToSqlLikeExpression().ToLower());

                if (search.Amount > 0)
                {
                    sql.And("amount = @0", search.Amount);
                }

                sql.And("office_id IN(SELECT * FROM core.get_office_ids(@0))", officeId);

                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }

        private static ITransferEntry LocateService(string tenant)
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

        public static async Task<long> PostAsync(string tenant, InventoryTransfer model)
        {
            var entry = LocateService(tenant);

            return await entry.AddAsync(tenant, model).ConfigureAwait(false);
        }
    }
}