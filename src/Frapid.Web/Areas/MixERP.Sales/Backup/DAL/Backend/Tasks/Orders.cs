using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Framework.Extensions;
using Frapid.Mapper;
using Frapid.Mapper.Database;
using Frapid.Mapper.Helpers;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.NonQuery;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.DTO;
using MixERP.Sales.QueryModels;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class Orders
    {
        public static async Task<IEnumerable<dynamic>> GetSearchViewAsync(string tenant, int officeId, OrderSearch search)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("SELECT * FROM sales.order_search_view");
                sql.Where("value_date BETWEEN @0 AND @1", search.From, search.To);
                sql.And("expected_date BETWEEN @0 AND @1", search.ExpectedFrom, search.ExpectedTo);
                sql.And("CAST(order_id AS national character varying(100)) LIKE @0", search.Id.ToSqlLikeExpression());
                sql.And("LOWER(reference_number) LIKE @0", search.ReferenceNumber.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(customer) LIKE @0", search.Customer.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(terms) LIKE @0", search.Terms.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(memo) LIKE @0", search.Memo.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(posted_by) LIKE @0", search.PostedBy.ToSqlLikeExpression().ToLower());
                sql.And("LOWER(office) LIKE @0", search.Office.ToSqlLikeExpression().ToLower());

                if (search.Amount > 0)
                {
                    sql.And("total_amount = @0", search.Amount);
                }

                sql.And("office_id IN(SELECT * FROM core.get_office_ids(@0))", officeId);

                return await db.SelectAsync<dynamic>(sql).ConfigureAwait(false);
            }
        }

        public static async Task CancelAsync(string tenant, long id, LoginView meta)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                var sql = new Sql("UPDATE sales.orders");
                sql.Append("SET");
                sql.Append("cancelled = @0, ", true);
                sql.Append("audit_user_id = @0, ", meta.UserId);
                sql.Append("audit_ts = @0", DateTimeOffset.UtcNow);
                sql.Where("order_id = @0", id);

                await db.NonQueryAsync(sql).ConfigureAwait(false);
            }
        }

        public static async Task<long> PostAsync(string tenant, Order model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                try
                {
                    await db.BeginTransactionAsync().ConfigureAwait(false);

                    var awaiter = await db.InsertAsync("sales.orders", "order_id", true, model).ConfigureAwait(false);
                    long orderId = awaiter.To<long>();

                    foreach (var detail in model.Details)
                    {
                        detail.OrderId = orderId;
                        await db.InsertAsync("sales.order_details", "order_detail_id", true, detail).ConfigureAwait(false);
                    }

                    db.CommitTransaction();
                    return orderId;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public static async Task<OrderMergeViewModel> GetMergeModelAsync(string tenant, long orderId)
        {
            string sql = "SELECT *, inventory.get_customer_code_by_customer_id(customer_id) AS customer_name FROM sales.orders WHERE order_id=@0;";
            var quotation = await Factory.GetAsync<OrderInfo>(tenant, sql, orderId).ConfigureAwait(false);

            sql = "SELECT * FROM sales.order_details WHERE order_id=@0;";
            var details = await Factory.GetAsync<OrderDetail>(tenant, sql, orderId).ConfigureAwait(false);

            return new OrderMergeViewModel
            {
                Order = quotation.FirstOrDefault(),
                Details = details
            };
        }

        public static async Task<List<OrderResultview>> GetOrderResultViewAsync(string tenant, OrderQueryModel query)
        {
            string sql = "SELECT * FROM sales.get_order_view(@0::integer,@1::integer,@2, @3::date,@4::date,@5::date,@6::date,@7::bigint,@8,@9,@10,@11,@12);";

            if (DbProvider.GetDbType(DbProvider.GetProviderName(tenant)) == DatabaseType.SqlServer)
            {
                sql = "SELECT * FROM sales.get_order_view(@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12);";
            }

            var awaiter = await
                Factory.GetAsync<OrderResultview>(tenant, sql, query.UserId, query.OfficeId, query.Customer.Or(""), query.From, query.To,
                    query.ExpectedFrom, query.ExpectedTo, query.Id, query.ReferenceNumber.Or(""),
                    query.InternalMemo.Or(""), query.Terms.Or(""), query.PostedBy.Or(""), query.Office.Or("")).ConfigureAwait(false);

            return awaiter.OrderBy(x => x.ValueDate).ThenBy(x => x.Supplier).ToList();
        }
    }
}
