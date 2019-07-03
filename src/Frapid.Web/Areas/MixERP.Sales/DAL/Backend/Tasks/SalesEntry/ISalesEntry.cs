using System.Threading.Tasks;

namespace MixERP.Sales.DAL.Backend.Tasks.SalesEntry
{
    public interface ISalesEntry
    {
        Task<long> PostAsync(string tenant, ViewModels.Sales model);
    }
}