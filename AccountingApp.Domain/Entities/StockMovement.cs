using AccountingApp.Domain.Common;
using AccountingApp.Domain.Enums;

namespace AccountingApp.Domain.Entities;

public class StockMovement : BaseEntity<Guid>
{
    public Guid ProductId { get; set; }
    public MovementType MovementType { get; set; }
    public decimal Quantity { get; set; }
    public DateTime MovementDate { get; set; } = DateTime.UtcNow;
    public string? Description { get; set; }
    public Guid? InvoiceId { get; set; }
    
    public Product Product { get; set; } = null!;
    public Invoice? Invoice { get; set; }
}
