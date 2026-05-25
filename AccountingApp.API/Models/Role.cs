using System;
using System.Collections.Generic;

namespace AccountingApp.API.Models
{
    /// <summary>
    /// Sistemdeki bir rolü temsil eder (ör: Admin, İK, Muhasebe).
    /// Her rolün birden fazla kullanıcısı olabilir (çoka-çok ilişki UserRole üzerinden).
    /// </summary>
    public class Role : BaseEntity<Guid>
    {
        /// <summary>Rolün görüntülenen adı (ör: "Admin").</summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>Normalize edilmiş rol adı — arama ve karşılaştırma kolaylığı için (ör: "ADMIN").</summary>
        public string NormalizedName { get; set; } = string.Empty;

        /// <summary>Rolün açıklaması (opsiyonel).</summary>
        public string? Description { get; set; }

        /// <summary>Bu role sahip kullanıcılar (çoka-çok ilişki).</summary>
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
