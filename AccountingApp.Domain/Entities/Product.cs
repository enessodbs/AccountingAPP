using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Product : AuditableEntity
{
    public string ProductCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Barcode { get; set; }
    public string Unit { get; set; } = "Adet";
    public decimal UnitPrice { get; set; }
    public int CurrencyId { get; set; }
    public decimal StockQuantity { get; set; } = 0;
    public bool IsService { get; set; } = false;
    
    public Currency Currency { get; set; } = null!;
    public ICollection<StockMovement> StockMovements { get; set; } = new List<StockMovement>();
}
