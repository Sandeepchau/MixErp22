using System.Collections.Generic;
using MixERP.Sales.DTO;

namespace MixERP.Sales.ViewModels
{
    public class CheckoutInfo
    {
        public int ItemId { get; set; }
        public string ItemName { get; set; }
        public int UnitId { get; set; }
        public string UnitName { get; set; }
        public int Quantity { get; set; }
        public long CheckoutId { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; }
        public string TransactionType { get; set; }
        public long TransactionMasterId { get; set; }
    }

    public class SerialNumber
    {
        public List<CheckoutInfo> CheckoutInfos { get; set; }
        public List<SerialNumberView> SerialNumberViews { get; set; }
    }
}