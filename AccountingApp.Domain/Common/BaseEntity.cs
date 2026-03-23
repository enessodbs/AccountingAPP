namespace AccountingApp.Domain.Common;

public abstract class BaseEntity<TId>
{
    public TId Id { get; set; } = default!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}

public abstract class AuditableEntity : BaseEntity<Guid>
{
    public bool IsActive { get; set; } = true;
}
