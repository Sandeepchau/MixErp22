﻿using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Frapid.Configuration;
using Frapid.DataAccess.Extensions;
using Frapid.Framework.Extensions;
using MixERP.Inventory.ViewModels;
using Npgsql;

namespace MixERP.Inventory.DAL.Backend.Tasks.AdjustmentEntry
{
    public sealed class PostgreSQL : IAdjustmentEntry
    {
        public async Task<long> AddAsync(string tenant, InventoryAdjustment model)
        {
            string connectionString = FrapidDbServer.GetConnectionString(tenant);
            string sql = @"SELECT * FROM inventory.post_adjustment
                          (
                            @OfficeId::integer, @UserId::integer, @LoginId::bigint, @StoreId::integer, @ValueDate::date, @BookDate::date, 
                            @ReferenceNumber::national character varying(24), @StatementReference::text, 
                            ARRAY[{0}]
                          );";
            sql = string.Format(sql, this.GetParametersForDetails(model.Details));

            using (var connection = new NpgsqlConnection(connectionString))
            {
                using (var command = new NpgsqlCommand(sql, connection))
                {
                    command.Parameters.AddWithNullableValue("@OfficeId", model.OfficeId);
                    command.Parameters.AddWithNullableValue("@UserId", model.UserId);
                    command.Parameters.AddWithNullableValue("@LoginId", model.LoginId);
                    command.Parameters.AddWithNullableValue("@StoreId", model.StoreId);
                    command.Parameters.AddWithNullableValue("@ValueDate", model.ValueDate);
                    command.Parameters.AddWithNullableValue("@BookDate", model.BookDate);
                    command.Parameters.AddWithNullableValue("@ReferenceNumber", model.ReferenceNumber);
                    command.Parameters.AddWithNullableValue("@StatementReference", model.StatementReference);

                    command.Parameters.AddRange(this.AddParametersForDetails(model.Details).ToArray());

                    connection.Open();
                    var awaiter = await command.ExecuteScalarAsync().ConfigureAwait(false);
                    return awaiter.To<long>();
                }
            }
        }

        public string GetParametersForDetails(List<AdjustmentType> details)
        {
            if (details == null)
            {
                return "NULL::inventory.transfer_type";
            }

            var items = new Collection<string>();
            for (int i = 0; i < details.Count; i++)
            {
                items.Add(string.Format(CultureInfo.InvariantCulture,
                    "ROW(@TransactionType{0}, @ItemCode{0}, @UnitName{0}, @Quantity{0})::inventory.adjustment_type",
                    i.ToString(CultureInfo.InvariantCulture)));
            }

            return string.Join(",", items);
        }

        public IEnumerable<NpgsqlParameter> AddParametersForDetails(List<AdjustmentType> details)
        {
            var parameters = new List<NpgsqlParameter>();

            if (details != null)
            {
                for (int i = 0; i < details.Count; i++)
                {
                    parameters.Add(new NpgsqlParameter("@TransactionType" + i, details[i].TransactionType));
                    parameters.Add(new NpgsqlParameter("@ItemCode" + i, details[i].ItemCode));
                    parameters.Add(new NpgsqlParameter("@UnitName" + i, details[i].UnitName));
                    parameters.Add(new NpgsqlParameter("@Quantity" + i, details[i].Quantity));
                }
            }

            return parameters;
        }
    }
}