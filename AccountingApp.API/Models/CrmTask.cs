using System;

namespace AccountingApp.API.Models
{
    public enum CrmTaskPriority : byte
    {
        Low = 1,
        Medium = 2,
        High = 3,
        Critical = 4
    }

    public enum CrmTaskStatus : byte
    {
        Todo = 1,
        InProgress = 2,
        Done = 3,
        Cancelled = 4
    }

    public class CrmTask : BaseEntity<Guid>
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public CrmTaskPriority Priority { get; set; } = CrmTaskPriority.Medium;
        public CrmTaskStatus Status { get; set; } = CrmTaskStatus.Todo;

        public DateTime? DueDate { get; set; }
        public DateTime? CompletedAt { get; set; }

        // Atama
        public Guid AssignedToId { get; set; }
        public User AssignedTo { get; set; } = null!;

        public Guid CreatedById { get; set; }
        public User CreatedBy { get; set; } = null!;

        // Polimorfik ilişki — sadece biri dolu olacak
        public Guid? LeadId { get; set; }
        public Lead? Lead { get; set; }

        public Guid? OpportunityId { get; set; }
        public Opportunity? Opportunity { get; set; }

        public Guid? ContactId { get; set; }
        public BusinessContact? Contact { get; set; }
    }
}
