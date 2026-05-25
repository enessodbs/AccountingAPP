using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace AccountingApp.API.DTOs
{
    // ========== Opportunity List DTO (for list views) ==========
    public class OpportunityListDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public int Probability { get; set; }
        public decimal WeightedAmount { get; set; }
        public DateTime? ExpectedCloseDate { get; set; }

        public Guid ContactId { get; set; }
        public string ContactName { get; set; } = string.Empty;

        public Guid OwnerId { get; set; }
        public string OwnerName { get; set; } = string.Empty;

        public int StageId { get; set; }
        public string StageName { get; set; } = string.Empty;

        public Guid? SourceLeadId { get; set; }
        public string? SourceLeadCompany { get; set; }

        public byte Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    // ========== Opportunity Detail DTO (full details) ==========
    public class OpportunityDetailDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Amount { get; set; }
        public int Probability { get; set; }
        public decimal WeightedAmount { get; set; }
        public DateTime? ExpectedCloseDate { get; set; }
        public DateTime? ActualCloseDate { get; set; }

        public byte Status { get; set; }
        public string? LostReason { get; set; }

        public Guid ContactId { get; set; }
        public string ContactName { get; set; } = string.Empty;

        public Guid OwnerId { get; set; }
        public string OwnerName { get; set; } = string.Empty;

        public int StageId { get; set; }
        public string StageName { get; set; } = string.Empty;

        public Guid? SourceLeadId { get; set; }
        public string? SourceLeadCompany { get; set; }

        public int CurrencyId { get; set; }

        public int ActivityCount { get; set; }
        public int TaskCount { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; }
    }

    // ========== Opportunity Create DTO ==========
    public class CreateOpportunityDto
    {
        [Required]
        [MaxLength(300)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        public decimal Amount { get; set; }
        public int Probability { get; set; } = 50;
        public DateTime? ExpectedCloseDate { get; set; }

        [Required]
        public Guid ContactId { get; set; }

        [Required]
        public int StageId { get; set; }

        public Guid? SourceLeadId { get; set; }
        public int CurrencyId { get; set; } = 1;
    }

    // ========== Opportunity Update DTO ==========
    public class UpdateOpportunityDto
    {
        [Required]
        [MaxLength(300)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        public decimal Amount { get; set; }
        public int Probability { get; set; } = 50;
        public DateTime? ExpectedCloseDate { get; set; }

        [Required]
        public Guid ContactId { get; set; }

        [Required]
        public int StageId { get; set; }

        public Guid? SourceLeadId { get; set; }
        public Guid OwnerId { get; set; }
        public int CurrencyId { get; set; } = 1;
    }

    // ========== Move Opportunity DTO (stage change) ==========
    public class MoveOpportunityDto
    {
        [Required]
        public int StageId { get; set; }

        public int? Probability { get; set; }
    }

    // ========== Close Opportunity DTO ==========
    public class CloseOpportunityDto
    {
        [Required]
        public bool IsWon { get; set; }

        public string? LostReason { get; set; }
    }

    // ========== Pipeline Board Column DTO ==========
    public class PipelineBoardColumnDto
    {
        public int StageId { get; set; }
        public string StageName { get; set; } = string.Empty;
        public int StageOrder { get; set; }
        public int DefaultProbability { get; set; }
        public List<OpportunityListDto> Opportunities { get; set; } = new();
    }

    // ========== PipelineStage Response DTO ==========
    public class PipelineStageDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public int DefaultProbability { get; set; }
        public bool IsActive { get; set; }
        public int OpportunityCount { get; set; }
    }

    // ========== PipelineStage Create DTO ==========
    public class CreatePipelineStageDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public int SortOrder { get; set; }
        public int DefaultProbability { get; set; } = 50;
    }

    // ========== PipelineStage Update DTO ==========
    public class UpdatePipelineStageDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public int SortOrder { get; set; }
        public int DefaultProbability { get; set; } = 50;
    }

    // ========== PipelineStage Reorder DTO ==========
    public class ReorderStageDto
    {
        public int Id { get; set; }
        public int SortOrder { get; set; }
    }
}
