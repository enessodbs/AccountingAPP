using System;

namespace AccountingApp.API.Models
{
    public enum ActivityType : byte
    {
        Call = 1,
        Email = 2,
        Meeting = 3,
        Note = 4,
        Demo = 5,
        SiteVisit = 6,
        Other = 10
    }

    public class Activity : BaseEntity<Guid>
    {
        public ActivityType Type { get; set; }
        public string Subject { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime ActivityDate { get; set; } = DateTime.UtcNow;
        public int? DurationMinutes { get; set; }

        // Gerçekleştiren kullanıcı
        public Guid PerformedById { get; set; }
        public User PerformedBy { get; set; } = null!;

        // Polimorfik ilişki — sadece biri dolu olacak
        public Guid? LeadId { get; set; }
        public Lead? Lead { get; set; }

        public Guid? OpportunityId { get; set; }
        public Opportunity? Opportunity { get; set; }

        public Guid? ContactId { get; set; }
        public BusinessContact? Contact { get; set; }
    }
}
