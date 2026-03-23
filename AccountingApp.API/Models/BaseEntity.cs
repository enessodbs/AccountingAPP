using System;

namespace AccountingApp.API.Models
{
    public abstract class BaseEntity<TKey>
    {
        public TKey Id { get; set; } = default!;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
