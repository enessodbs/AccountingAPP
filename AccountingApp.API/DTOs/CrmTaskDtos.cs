using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ========== CrmTask Response DTO ==========
    public class CrmTaskDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public byte Priority { get; set; }
        public byte Status { get; set; }

        public DateTime? DueDate { get; set; }
        public DateTime? CompletedAt { get; set; }
        public bool IsOverdue => DueDate.HasValue && DueDate.Value < DateTime.UtcNow && Status < 3;

        public Guid AssignedToId { get; set; }
        public string AssignedToName { get; set; } = string.Empty;

        public Guid CreatedById { get; set; }
        public string CreatedByName { get; set; } = string.Empty;

        public Guid? LeadId { get; set; }
        public string? LeadName { get; set; }

        public Guid? OpportunityId { get; set; }
        public string? OpportunityTitle { get; set; }

        public Guid? ContactId { get; set; }
        public string? ContactName { get; set; }

        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }

    // ========== CrmTask Create DTO ==========
    public class CrmTaskCreateDto
    {
        [Required]
        [MaxLength(300)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        public byte Priority { get; set; } = 2; // Default: Medium

        public DateTime? DueDate { get; set; }

        [Required]
        public Guid AssignedToId { get; set; }

        // Polimorfik: opsiyonel
        public Guid? LeadId { get; set; }
        public Guid? OpportunityId { get; set; }
        public Guid? ContactId { get; set; }
    }

    // ========== CrmTask Update DTO ==========
    public class CrmTaskUpdateDto
    {
        [Required]
        [MaxLength(300)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        public byte Priority { get; set; }

        public DateTime? DueDate { get; set; }

        [Required]
        public Guid AssignedToId { get; set; }

        public Guid? LeadId { get; set; }
        public Guid? OpportunityId { get; set; }
        public Guid? ContactId { get; set; }
    }

    // ========== CrmTask Status Update DTO ==========
    public class CrmTaskStatusUpdateDto
    {
        [Required]
        public byte Status { get; set; }
    }
}
