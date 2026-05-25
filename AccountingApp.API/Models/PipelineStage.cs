using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    public class PipelineStage : BaseEntity<int>
    {
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public int DefaultProbability { get; set; } = 50;

        public ICollection<Opportunity> Opportunities { get; set; } = new List<Opportunity>();
    }
}
