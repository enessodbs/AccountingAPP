using System;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ========== Lead Response DTO ==========
    public class LeadDto
    {
        public Guid Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public string? CompanyName { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }

        public byte Status { get; set; }
        public byte Source { get; set; }
        public byte Priority { get; set; }

        public Guid? AssignedToId { get; set; }
        public string? AssignedToName { get; set; }
        public Guid CreatedById { get; set; }
        public string CreatedByName { get; set; } = string.Empty;

        public Guid? ConvertedContactId { get; set; }
        public Guid? ConvertedOpportunityId { get; set; }
        public DateTime? ConvertedAt { get; set; }
        public string? LostReason { get; set; }

        public decimal? EstimatedValue { get; set; }
        public int? CurrencyId { get; set; }
        public string? CurrencyCode { get; set; }
        public string? CurrencySymbol { get; set; }

        public string? Notes { get; set; }
        public string? Tags { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; }

        public int ActivityCount { get; set; }
        public int TaskCount { get; set; }
    }

    // ========== Lead Create DTO ==========
    public class LeadCreateDto
    {
        [Required]
        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? CompanyName { get; set; }

        [EmailAddress]
        [MaxLength(200)]
        public string? Email { get; set; }

        [MaxLength(30)]
        public string? Phone { get; set; }

        [MaxLength(300)]
        public string? Website { get; set; }

        public byte Source { get; set; } = 10; // Default: Other
        public byte Priority { get; set; } = 2; // Default: Medium

        public Guid? AssignedToId { get; set; }

        public decimal? EstimatedValue { get; set; }
        public int? CurrencyId { get; set; }

        public string? Notes { get; set; }
        public string? Tags { get; set; }
    }

    // ========== Lead Update DTO ==========
    public class LeadUpdateDto
    {
        [Required]
        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? CompanyName { get; set; }

        [EmailAddress]
        [MaxLength(200)]
        public string? Email { get; set; }

        [MaxLength(30)]
        public string? Phone { get; set; }

        [MaxLength(300)]
        public string? Website { get; set; }

        public byte Source { get; set; }
        public byte Priority { get; set; }

        public Guid? AssignedToId { get; set; }

        public decimal? EstimatedValue { get; set; }
        public int? CurrencyId { get; set; }

        public string? Notes { get; set; }
        public string? Tags { get; set; }
    }

    // ========== Lead Status Change DTO ==========
    public class LeadStatusUpdateDto
    {
        [Required]
        public byte Status { get; set; }
        public string? LostReason { get; set; }
    }

    // ========== Lead Assign DTO ==========
    public class LeadAssignDto
    {
        [Required]
        public Guid AssignedToId { get; set; }
    }

    // ========== Lead Convert DTO ==========
    public class LeadConvertDto
    {
        public bool CreateOpportunity { get; set; } = true;
        public string? OpportunityTitle { get; set; }
        public decimal? OpportunityAmount { get; set; }
        public int? CurrencyId { get; set; }
        public int? StageId { get; set; }
    }

    // ========== Lead Convert Result DTO ==========
    public class LeadConvertResultDto
    {
        public Guid ContactId { get; set; }
        public Guid? OpportunityId { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
