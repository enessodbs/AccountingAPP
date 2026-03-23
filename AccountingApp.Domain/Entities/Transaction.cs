using AccountingApp.Domain.Common;
using AccountingApp.Domain.Enums;

namespace AccountingApp.Domain.Entities;

public class Transaction : BaseEntity<Guid>
{
    public int CategoryId { get; set; }
    public Guid? InvoiceId { get; set; }
    public Guid? EmployeeId { get; set; }
    public TransactionType Type { get; set; }
    public int CurrencyId { get; set; }
    public decimal ExchangeRate { get; set; } = 1.0m;
    public decimal Amount { get; set; }
    public decimal BaseAmount { get; private set; }
    public DateTime TransactionDate { get; set; }
    public string? Description { get; set; }
    
    public Category Category { get; set; } = null!;
    public Invoice? Invoice { get; set; }
    public Employee? Employee { get; set; }
    public Currency Currency { get; set; } = null!;

    public void CalculateBaseAmount()
    {
        BaseAmount = Amount * ExchangeRate;
    }
}
