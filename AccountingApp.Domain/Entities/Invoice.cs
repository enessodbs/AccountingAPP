using AccountingApp.Domain.Common;
using AccountingApp.Domain.Enums;

namespace AccountingApp.Domain.Entities;

public class Invoice : BaseEntity<Guid>
{
    public string InvoiceNumber { get; set; } = string.Empty;
    public InvoiceType Type { get; set; }
    public string ContactName { get; set; } = string.Empty;
    public DateTime IssueDate { get; set; }
    public DateTime DueDate { get; set; }
    public int CurrencyId { get; set; }
    public decimal ExchangeRate { get; set; } = 1.0m;
    public decimal TotalAmount { get; set; }
    public decimal BaseTotalAmount { get; private set; }
    public InvoiceStatus Status { get; set; } = InvoiceStatus.Pending;
    
    public Currency Currency { get; set; } = null!;
    public ICollection<InvoiceLine> InvoiceLines { get; set; } = new List<InvoiceLine>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<StockMovement> StockMovements { get; set; } = new List<StockMovement>();

    public void CalculateBaseAmount()
    {
        BaseTotalAmount = TotalAmount * ExchangeRate;
    }
}
