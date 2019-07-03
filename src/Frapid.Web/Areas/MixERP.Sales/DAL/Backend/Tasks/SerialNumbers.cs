using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Frapid.ApplicationState.Models;
using Frapid.Configuration;
using Frapid.Configuration.Db;
using Frapid.DataAccess;
using Frapid.Mapper.Query.Insert;
using Frapid.Mapper.Query.NonQuery;
using Frapid.Mapper.Query.Select;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks
{
    public static class SerialNumbers
    {
        public static async Task<SerialNumber> GetSerialNumberDetails(string tenant, long transactionMasterId)
        {
            const string checkoutSql = @"SELECT item_id, item_name, unit_id, unit_name, FLOOR(quantity) AS quantity, checkout_id, store_id, store_name, transaction_type, transaction_master_id
                                FROM inventory.checkout_detail_view WHERE transaction_master_id = @0;";
            var checkouts = await Factory.GetAsync<CheckoutInfo>(tenant, checkoutSql, transactionMasterId)
                .ConfigureAwait(false);

            if (checkouts == null)
            {
                return null;
            }

            const string detailSql = @"SELECT * FROM inventory.serial_numbers_view
                                WHERE transaction_master_id = @0;";

            var details = await Factory.GetAsync<DTO.SerialNumberView>(tenant, detailSql, transactionMasterId)
                .ConfigureAwait(false);

            return new SerialNumber
            {
                CheckoutInfos = checkouts.ToList(),
                SerialNumberViews = details.ToList()
            };

        }

        public static async Task<bool> Post(string tenant, LoginView meta, PostSerial model)
        {
            using (var db = DbProvider.Get(FrapidDbServer.GetConnectionString(tenant), tenant).GetDatabase())
            {
                try
                {
                    await db.BeginTransactionAsync().ConfigureAwait(false);
                    foreach (long serialNumber in model.SerialNumbers)
                    {
                        const string sql = @"UPDATE inventory.serial_numbers SET sales_transaction_id = @0
                            WHERE serial_number_id=@1;";

                        await db.NonQueryAsync(sql, model.TransactionMasterId, serialNumber)
                            .ConfigureAwait(false);
                    }

                    db.CommitTransaction();
                }
                catch (Exception)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

            return true;
        }
    }
}