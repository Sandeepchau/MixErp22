using Frapid.Mapper.Decorators;

namespace MixERP.Sales.DTO
{
    [TableName("sales.gift_card_search_view")]
    public sealed class GiftCardSearchView
    {
        public int GiftCardId { get; set; }
        public string GiftCardNumber { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string PoBox { get; set; }
        public string ZipCode { get; set; }
        public string PhoneNumbers { get; set; }
        public string Fax { get; set; }
    }
}