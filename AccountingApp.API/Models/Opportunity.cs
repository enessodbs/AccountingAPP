using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public enum OpportunityStatus : byte
    {
        Open = 1,
        Won = 2,
        Lost = 3
    }

    public class Opportunity : BaseEntity<Guid>
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }

        // İlişkiler
        public Guid ContactId { get; set; }
        public BusinessContact Contact { get; set; } = null!;

        public Guid OwnerId { get; set; }
        public User Owner { get; set; } = null!;

        public int StageId { get; set; }
        public PipelineStage Stage { get; set; } = null!;

        public Guid? SourceLeadId { get; set; }
        public Lead? SourceLead { get; set; }

        // Finansal
        public decimal Amount { get; set; }
        public int CurrencyId { get; set; }
        public Currency Currency { get; set; } = null!;

        public int Probability { get; set; } = 50; // 0-100
        public decimal WeightedAmount { get; set; }

        // Zaman
        public DateTime? ExpectedCloseDate { get; set; }
        public DateTime? ActualCloseDate { get; set; }

        // Durum
        public OpportunityStatus Status { get; set; } = OpportunityStatus.Open;
        public string? LostReason { get; set; }

        // Navigation
        public ICollection<Activity> Activities { get; set; } = new List<Activity>();
        public ICollection<CrmTask> Tasks { get; set; } = new List<CrmTask>();

        public void CalculateWeightedAmount()
        {
            WeightedAmount = Amount * Probability / 100m;
        }
    }
}
