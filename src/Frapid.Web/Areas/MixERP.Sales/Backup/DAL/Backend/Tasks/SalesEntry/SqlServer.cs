using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks.SalesEntry
{
    public sealed class SqlServer : ISalesEntry
    {
        public async Task<long> PostAsync(string tenant, ViewModels.Sales model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            const string sql = @"EXECUTE sales.post_sales
                                @OfficeId, @UserId, @LoginId, @CounterId, @ValueDate, @BookDate, 
                                @CostCenterId, @ReferenceNumber, @StatementReference, 
                                @Tender, @Change, @PaymentTermId, 
                                @CheckAmount, @CheckBankName, @CheckNumber, @CheckDate,
                                @GiftCardNumber, 
                                @CustomerId, @PriceTypeId, @ShipperId, @StoreId,
                                @CouponCode, @IsFlatDiscount, @Discount,
                                @Details,
                                @SalesQuotationId, @SalesOrderId, @SerialNumberIds, @TransactionMasterId OUTPUT;";


            using (var connection = new SqlConnection(connectionString))
            {
                using (var command = new SqlCommand(sql, connection))
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

                    using (var details = this.GetDetails(model.Details))
                    {
                        command.Parameters.AddWithNullableValue("@Details", details, "sales.sales_detail_type");
                    }

                    command.Parameters.Add("@TransactionMasterId", SqlDbType.BigInt).Direction = ParameterDirection.Output;
                    connection.Open();
                    await command.ExecuteNonQueryAsync().ConfigureAwait(false);
                    return command.Parameters["@TransactionMasterId"].Value.To<long>();
                }
            }
        }

        public DataTable GetDetails(IEnumerable<SalesDetailType> details)
        {
            var table = new DataTable();
            table.Columns.Add("StoreId", typeof(int));
            table.Columns.Add("TransactionType", typeof(string));
            table.Columns.Add("ItemId", typeof(int));
            table.Columns.Add("Quantity", typeof(decimal));
            table.Columns.Add("UnitId", typeof(int));
            table.Columns.Add("Price", typeof(decimal));
            table.Columns.Add("DiscountRate", typeof(decimal));
            table.Columns.Add("Discount", typeof(decimal));
            table.Columns.Add("ShippingCharge", typeof(decimal));
            table.Columns.Add("IsTaxed", typeof(bool));

            foreach (var detail in details)
            {
                var row = table.NewRow();
                row["StoreId"] = detail.StoreId;
                row["TransactionType"] = "Cr"; //Inventory reduced.
                row["ItemId"] = detail.ItemId;
                row["Quantity"] = detail.Quantity;
                row["UnitId"] = detail.UnitId;
                row["Price"] = detail.Price;
                row["DiscountRate"] = detail.DiscountRate;
                row["Discount"] = detail.Discount;
                row["ShippingCharge"] = detail.ShippingCharge;
                row["IsTaxed"] = detail.IsTaxed;

                table.Rows.Add(row);
            }

            return table;
        }
    }
}