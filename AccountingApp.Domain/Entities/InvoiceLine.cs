using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class InvoiceLine : BaseEntity<Guid>
{
    public Guid InvoiceId { get; set; }
    public Guid? ProductId { get; set; }
    public string? CustomDescription { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; private set; }
    
    public Invoice Invoice { get; set; } = null!;
    public Product? Product { get; set; }

    public void CalculateTotalPrice()
    {
        TotalPrice = Quantity * UnitPrice;
    }
}
