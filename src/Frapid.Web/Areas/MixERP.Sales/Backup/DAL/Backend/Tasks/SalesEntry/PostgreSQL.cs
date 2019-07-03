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

namespace MixERP.Sales.DAL.Backend.Tasks.SalesEntry
{
    public sealed class PostgreSQL : ISalesEntry
    {
        public async Task<long> PostAsync(string tenant, ViewModels.Sales model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"SELECT * FROM sales.post_sales
                            (
                                @OfficeId::integer, @UserId::integer, @LoginId::bigint, @CounterId::integer, @ValueDate::date, @BookDate::date, 
                                @CostCenterId::integer, @ReferenceNumber::national character varying(24), @StatementReference::text, 
                                @Tender::public.money_strict2, @Change::public.money_strict2, @PaymentTermId::integer, 
                                @CheckAmount::public.money_strict2, @CheckBankName::national character varying(1000), @CheckNumber::national character varying(100), @CheckDate::date,
                                @GiftCardNumber::national character varying(100), 
                                @CustomerId::integer, @PriceTypeId::integer, @ShipperId::integer, @StoreId::integer,
                                @CouponCode::national character varying(100), @IsFlatDiscount::boolean, @Discount::public.money_strict2,
                                ARRAY[{0}],
                                @SalesQuotationId::bigint, @SalesOrderId::bigint, @SerialNumberIds::text
                            );";
            sql = string.Format(sql, this.GetParametersForDetails(model.Details));

            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@CounterId", model.CounterId);
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);
                    command.Parameters.AddWithNullableValue("@CostCenterId", model.CostCenterId);
                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber.Or(""));
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference.Or(""));
                    command.Parameters.AddWithNullableValue("@Tender", model.Tender);
                    command.Parameters.AddWithNullableValue("@Change", model.Change);
                    command.Parameters.AddWithNullableValue("@PaymentTermId", model.PaymentTermId);
                    command.Parameters.AddWithNullableValue("@CheckAmount", model.CheckAmount);
                    command.Parameters.AddWithNullableValue("@CheckBankName", model.CheckBankName.Or(""));
                    command.Parameters.AddWithNullableValue("@CheckNumber", model.CheckNumber.Or(""));
                    command.Parameters.AddWithNullableValue("@CheckDate", model.CheckDate);
                    command.Parameters.AddWithNullableValue("@GiftCardNumber", model.GiftCardNumber.Or(""));
                    command.Parameters.AddWithNullableValue("@CustomerId", model.CustomerId);
                    command.Parameters.AddWithNullableValue("@PriceTypeId", model.PriceTypeId);
                    command.Parameters.AddWithNullableValue("@ShipperId", model.ShipperId);
                    command.Parameters.AddWithNullableValue("@StoreId", model.StoreId);
                    command.Parameters.AddWithNullableValue("@CouponCode", model.CouponCode.Or(""));
                    command.Parameters.AddWithNullableValue("@IsFlatDiscount", model.IsFlatDiscount);
                    command.Parameters.AddWithNullableValue("@Discount", model.Discount);
                    command.Parameters.AddWithNullableValue("@SalesQuotationId", model.SalesQuotationId);
                    command.Parameters.AddWithNullableValue("@SalesOrderId", model.SalesOrderId);
                    command.Parameters.AddWithNullableValue("@SerialNumberIds", model.SerialNumberIds);

                    command.Parameters.AddRange(this.AddParametersForDetails(model.Details).ToArray());

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
                    parameters.Add(new NpgsqlParameter("@IsTaxed" + i, details[i].IsTaxed));

                    parameters.Add(new NpgsqlParameter("@ShippingCharge" + i, details[i].ShippingCharge));
                }
            }

            return parameters;
        }
    }
}