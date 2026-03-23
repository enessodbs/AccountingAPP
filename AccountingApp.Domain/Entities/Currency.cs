using AccountingApp.Domain.Common;

namespace AccountingApp.Domain.Entities;

public class Currency : BaseEntity<int>
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;
    public bool IsBaseCurrency { get; set; } = false;
}
