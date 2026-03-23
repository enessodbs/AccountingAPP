namespace AccountingApp.API.Models
{
    public class Currency : BaseEntity<int>
    {
        public string Code { get; set; } = string.Empty; // USD, EUR, TRY
        public string Symbol { get; set; } = string.Empty; // $, €, ₺
    }
}
