using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Sales.ViewModels;
using Npgsql;

namespace MixERP.Sales.DAL.Backend.Tasks.ReceiptEntry
{
    public sealed class PostgreSQL : IReceiptEntry
    {
        public async Task<long> PostAsync(string tenant, SalesReceipt model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            const string sql = @"SELECT * FROM sales.post_customer_receipt
                            (
                                @ValueDate::date, @BookDate::date,
                                @UserId::integer, @OfficeId::integer, @LoginId::bigint, @CustomerId::integer, 
                                @CurrencyCode::national character varying(12), @CashAccountId::integer, @Amount::public.money_strict, 
                                @ExchangeRateDebit::public.decimal_strict, @ExchangeRateCredit::public.decimal_strict, 
                                @ReferenceNumber::national character varying(24), @StatementReference::national character varying(128), 
                                @CostCenterId::integer, @CashRepositoryId::integer, 
                                @PostedDate::date, @BankAccountId::integer, @PaymentCardId::integer, @BankInstrumentCode::national character varying(128), @BankTranCode::national character varying(128)
                            );";


            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@CustomerId", model.CustomerId);
                    command.Parameters.AddWithNullableValue("@CurrencyCode", model.CurrencyCode);
                    command.Parameters.AddWithNullableValue("@CashAccountId", model.CashAccountId);
                    command.Parameters.AddWithNullableValue("@Amount", model.Amount);
                    command.Parameters.AddWithNullableValue("@ExchangeRateDebit", model.DebitExchangeRate);
                    command.Parameters.AddWithNullableValue("@ExchangeRateCredit", model.CreditExchangeRate);

                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference);


                    command.Parameters.AddWithNullableValue("@CostCenterId", model.CostCenterId);
                    command.Parameters.AddWithNullableValue("@CashRepositoryId", model.CashRepositoryId);
                    command.Parameters.AddWithNullableValue("@PostedDate", model.PostedDate);
                    command.Parameters.AddWithNullableValue("@BankAccountId", model.BankAccountId);
                    command.Parameters.AddWithNullableValue("@PaymentCardId", model.PaymentCardId);
                    command.Parameters.AddWithNullableValue("@BankInstrumentCode", model.BankInstrumentCode);
                    command.Parameters.AddWithNullableValue("@BankTranCode", model.BankTransactionCode);

                    connection.Open();
                    var awaiter = await command.ExecuteScalarAsync().ConfigureAwait(false);
                    return awaiter.To<long>();
                }
            }
        }
    }
}