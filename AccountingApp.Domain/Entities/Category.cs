using AccountingApp.Domain.Common;
using AccountingApp.Domain.Enums;

namespace AccountingApp.Domain.Entities;

public class Category : BaseEntity<int>
{
    public string Name { get; set; } = string.Empty;
    public TransactionType Type { get; set; }
}
