using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public enum LeadStatus : byte
    {
        New = 1,
        Contacted = 2,
        Qualified = 3,
        Converted = 4,
        Lost = 5
    }

    public enum LeadSource : byte
    {
        Web = 1,
        Referral = 2,
        SocialMedia = 3,
        Phone = 4,
        Email = 5,
        Exhibition = 6,
        Other = 10
    }

    public enum LeadPriority : byte
    {
        Low = 1,
        Medium = 2,
        High = 3,
        Critical = 4
    }

    public class Lead : BaseEntity<Guid>
    {
        // Kişi Bilgileri
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? CompanyName { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Website { get; set; }

        // Durum & Kaynak
        public LeadStatus Status { get; set; } = LeadStatus.New;
        public LeadSource Source { get; set; } = LeadSource.Other;
        public LeadPriority Priority { get; set; } = LeadPriority.Medium;

        // Atama
        public Guid? AssignedToId { get; set; }
        public User? AssignedTo { get; set; }

        public Guid CreatedById { get; set; }
        public User CreatedBy { get; set; } = null!;

        // Dönüşüm (Lead → BusinessContact + Opportunity)
        public Guid? ConvertedContactId { get; set; }
        public BusinessContact? ConvertedContact { get; set; }

        public Guid? ConvertedOpportunityId { get; set; }
        public DateTime? ConvertedAt { get; set; }
        public string? LostReason { get; set; }

        // Tahmini Değer
        public decimal? EstimatedValue { get; set; }
        public int? CurrencyId { get; set; }
        public Currency? Currency { get; set; }

        // Ek Bilgiler
        public string? Notes { get; set; }
        public string? Tags { get; set; } // Virgülle ayrılmış etiketler

        // Navigation Properties
        public ICollection<Activity> Activities { get; set; } = new List<Activity>();
        public ICollection<CrmTask> Tasks { get; set; } = new List<CrmTask>();
    }
}
