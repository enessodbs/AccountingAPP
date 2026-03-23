using System;

namespace AccountingApp.API.Models
{
    public enum MovementType : byte
    {
        In = 1,
        Out = 2
    }

    public class StockMovement : BaseEntity<Guid>
    {
        public int ProductId { get; set; }
        public Product Product { get; set; } = null!;

        public decimal Quantity { get; set; }
        public MovementType MovementType { get; set; }
        public DateTime Date { get; set; }

        public Guid? InvoiceId { get; set; }
        public Invoice Invoice { get; set; } = null!;

        public string Description { get; set; } = string.Empty;
    }
}
