using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ========== Activity Response DTO ==========
    public class ActivityDto
    {
        public Guid Id { get; set; }
        public byte Type { get; set; }
        public string Subject { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime ActivityDate { get; set; }
        public int? DurationMinutes { get; set; }

        public Guid PerformedById { get; set; }
        public string PerformedByName { get; set; } = string.Empty;

        public Guid? LeadId { get; set; }
        public string? LeadName { get; set; }

        public Guid? OpportunityId { get; set; }
        public string? OpportunityTitle { get; set; }

        public Guid? ContactId { get; set; }
        public string? ContactName { get; set; }

        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }

    // ========== Activity Create DTO ==========
    public class ActivityCreateDto
    {
        [Required]
        public byte Type { get; set; }

        [Required]
        [MaxLength(300)]
        public string Subject { get; set; } = string.Empty;

        public string? Description { get; set; }

        [Required]
        public DateTime ActivityDate { get; set; }

        public int? DurationMinutes { get; set; }

        // Polimorfik: en az biri doldurulmalı
        public Guid? LeadId { get; set; }
        public Guid? OpportunityId { get; set; }
        public Guid? ContactId { get; set; }
    }
}
