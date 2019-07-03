using System.Threading.Tasks;
using MixERP.Sales.ViewModels;

namespace MixERP.Sales.DAL.Backend.Tasks.ReceiptEntry
{
    public interface IReceiptEntry
    {
        Task<long> PostAsync(string tenant, SalesReceipt model);
    }
}