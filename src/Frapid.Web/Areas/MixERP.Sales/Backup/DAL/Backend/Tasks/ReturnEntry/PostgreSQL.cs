using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;
using Npgsql;

namespace MixERP.Sales.DAL.Backend.Tasks.ReturnEntry
{
    public sealed class PostgreSQL : IReturnEntry
    {
        public async Task<long> PostAsync(string tenant, SalesReturn model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"SELECT * FROM sales.post_return
                            (
                                @TransactionMasterId::bigint, @OfficeId::integer, @UserId::integer, @LoginId::bigint, 
                                @ValueDate::date, @BookDate::date, 
                                @StoreId::integer, @CounterId::integer, @CustomerId, @PriceTypeId::integer,
                                @ReferenceNumber::national character varying(24), @StatementReference::text, 
                                ARRAY[{0}], @ShipperId::integer, @Discount::numeric(30, 6)
                            );";

            sql = string.Format(sql, this.GetParametersForDetails(model.Details));

            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@TransactionMasterId", model.TransactionMasterId);
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);

                    command.Parameters.AddWithNullableValue("@StoreId", model.StoreId);
                    command.Parameters.AddWithNullableValue("@CounterId", model.CounterId);
                    command.Parameters.AddWithNullableValue("@CustomerId", model.CustomerId);
                    command.Parameters.AddWithNullableValue("@PriceTypeId", model.PriceTypeId);

                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference);


                    command.Parameters.AddRange(this.AddParametersForDetails(model.Details).ToArray());

                    command.Parameters.AddWithNullableValue("@ShipperId", model.ShipperId);
                    command.Parameters.AddWithNullableValue("@Discount", model.Discount);

                    connection.Open();
                    var awaiter = await command.ExecuteScalarAsync().ConfigureAwait(false);
                    return awaiter.To<long>();
                }
            }
        }

        public string GetParametersForDetails(List<SalesDetailType> details)
        {
            if (details == null)
            {
                return "NULL::sales.sales_detail_type";
            }

            var items = new Collection<string>();
            for (int i = 0; i < details.Count; i++)
            {
                items.Add(string.Format(CultureInfo.InvariantCulture,
                    "ROW(@StoreId{0}, @TransactionType{0}, @ItemId{0}, @Quantity{0}, @UnitId{0}, @Price{0}, @DiscountRate{0}, @Discount{0}, @ShippingCharge{0}, @IsTaxed{0})::sales.sales_detail_type",
                    i.ToString(CultureInfo.InvariantCulture)));
            }

            return string.Join(",", items);
        }

        public IEnumerable<NpgsqlParameter> AddParametersForDetails(List<SalesDetailType> details)
        {
            var parameters = new List<NpgsqlParameter>();

            if (details != null)
            {
                for (int i = 0; i < details.Count; i++)
                {
                    parameters.Add(new NpgsqlParameter("@StoreId" + i, details[i].StoreId));
                    parameters.Add(new NpgsqlParameter("@TransactionType" + i, "Cr")); //Inventory is decreased
                    parameters.Add(new NpgsqlParameter("@ItemId" + i, details[i].ItemId));
                    parameters.Add(new NpgsqlParameter("@Quantity" + i, details[i].Quantity));
                    parameters.Add(new NpgsqlParameter("@UnitId" + i, details[i].UnitId));
                    parameters.Add(new NpgsqlParameter("@Price" + i, details[i].Price));
                    parameters.Add(new NpgsqlParameter("@DiscountRate" + i, details[i].DiscountRate));
                    parameters.Add(new NpgsqlParameter("@Discount" + i, details[i].Discount));
                    parameters.Add(new NpgsqlParameter("@ShippingCharge" + i, details[i].ShippingCharge));
                    parameters.Add(new NpgsqlParameter("@IsTaxed" + i, details[i].IsTaxed));
                }
            }

            return parameters;
        }
    }
}