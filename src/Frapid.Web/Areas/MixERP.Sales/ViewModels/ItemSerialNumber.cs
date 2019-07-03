using System;
using System.Collections.Generic;

namespace MixERP.Sales.ViewModels
{
    public class ItemSerialNumber
    {
        public long SerialNumberId { get; set; }
        public string ItemName { get; set; }
        public string UnitCode { get; set; }
        public string BatchNumber { get; set; }
        public string SerialNumber { get; set; }
        public DateTime? ExpiryDate { get; set; }
    }

    public class PostSerial
    {
        public long CheckoutId { get; set; }
        public long TransactionMasterId { get; set; }
        public List<long> SerialNumbers { get; set; }
    }
}