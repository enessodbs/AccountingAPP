using AccountingApp.API.Models;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Data
{
    /// <summary>
    /// Uygulamanın ana veritabanı bağlamı (DbContext).
    /// Tüm entity setlerini, ilişki konfigürasyonlarını ve seed verilerini yönetir.
    /// SaveChangesAsync override edilmiş olup UpdatedAt alanlarını otomatik olarak günceller.
    /// </summary>
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Global
        public DbSet<Currency> Currencies { get; set; }

        // Auth
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }

        // HR
        public DbSet<Department> Departments { get; set; }
        public DbSet<Position> Positions { get; set; }
        public DbSet<Employee> Employees { get; set; }

        // Inventory
        public DbSet<Category> Categories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<StockMovement> StockMovements { get; set; }

        // Finance
        public DbSet<BusinessContact> BusinessContacts { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<InvoiceLine> InvoiceLines { get; set; }
        public DbSet<Transaction> Transactions { get; set; }

        // CRM
        public DbSet<Lead> Leads { get; set; }
        public DbSet<PipelineStage> PipelineStages { get; set; }
        public DbSet<Opportunity> Opportunities { get; set; }
        public DbSet<Activity> Activities { get; set; }
        public DbSet<CrmTask> CrmTasks { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
            base.OnConfiguring(optionsBuilder);
        }

        /// <summary>
        /// SaveChangesAsync override — Değiştirilen entity'lerin UpdatedAt alanını otomatik günceller.
        /// Bu sayede her controller'da UpdatedAt = DateTime.UtcNow yazmak zorunda kalmayız.
        /// </summary>
        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            var modifiedEntries = ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Modified);

            foreach (var entry in modifiedEntries)
            {
                var updatedAtProp = entry.Properties
                    .FirstOrDefault(p => p.Metadata.Name == "UpdatedAt");

                if (updatedAtProp != null && updatedAtProp.Metadata.ClrType == typeof(DateTime?))
                {
                    updatedAtProp.CurrentValue = DateTime.UtcNow;
                }
            }

            return await base.SaveChangesAsync(cancellationToken);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ============ Auth: Many-to-Many configuration for UserRoles ============
            modelBuilder.Entity<UserRole>()
                .HasKey(ur => new { ur.UserId, ur.RoleId });

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId);

            // ============ Unique Constraints ============
            modelBuilder.Entity<User>().HasIndex(u => u.Username).IsUnique();
            modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
            modelBuilder.Entity<Role>().HasIndex(r => r.Name).IsUnique();
            modelBuilder.Entity<Role>().HasIndex(r => r.NormalizedName).IsUnique();
            modelBuilder.Entity<Employee>().HasIndex(e => e.IdentityNumber).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.Code).IsUnique();
            modelBuilder.Entity<Invoice>().HasIndex(i => i.InvoiceNumber).IsUnique();

            // ============ String Length Configurations ============
            modelBuilder.Entity<User>().Property(u => u.Username).HasMaxLength(50);
            modelBuilder.Entity<User>().Property(u => u.Email).HasMaxLength(100);
            modelBuilder.Entity<User>().Property(u => u.FullName).HasMaxLength(100);
            modelBuilder.Entity<User>().Property(u => u.RefreshToken).HasMaxLength(500);
            modelBuilder.Entity<Role>().Property(r => r.Name).HasMaxLength(50);
            modelBuilder.Entity<Role>().Property(r => r.NormalizedName).HasMaxLength(50);
            modelBuilder.Entity<Role>().Property(r => r.Description).HasMaxLength(200);

            // ============ Decimal Precision Configurations ============
            modelBuilder.Entity<Employee>().Property(e => e.BaseSalary).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Product>().Property(p => p.UnitPrice).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Product>().Property(p => p.StockQuantity).HasColumnType("decimal(18,2)");
            modelBuilder.Entity<StockMovement>().Property(sm => sm.Quantity).HasColumnType("decimal(18,2)");
            modelBuilder.Entity<Invoice>().Property(i => i.TotalAmount).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Invoice>().Property(i => i.TaxAmount).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Invoice>().Property(i => i.ExchangeRate).HasColumnType("decimal(18,6)");
            modelBuilder.Entity<InvoiceLine>().Property(il => il.Quantity).HasColumnType("decimal(18,2)");
            modelBuilder.Entity<InvoiceLine>().Property(il => il.UnitPrice).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<InvoiceLine>().Property(il => il.TaxRate).HasColumnType("decimal(5,2)");
            modelBuilder.Entity<InvoiceLine>().Property(il => il.LineTotal).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Transaction>().Property(t => t.Amount).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Transaction>().Property(t => t.ExchangeRate).HasColumnType("decimal(18,6)");

            // ============ Relationships — Restrict Delete ============
            modelBuilder.Entity<Employee>()
                .HasOne(e => e.Department)
                .WithMany(d => d.Employees)
                .HasForeignKey(e => e.DepartmentId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Invoice>()
                .HasOne(i => i.CreatedBy)
                .WithMany()
                .HasForeignKey(i => i.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Transaction>()
                .HasOne(t => t.CreatedBy)
                .WithMany()
                .HasForeignKey(t => t.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<InvoiceLine>()
                .HasOne(il => il.Product)
                .WithMany()
                .HasForeignKey(il => il.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<StockMovement>()
                .HasOne(sm => sm.Product)
                .WithMany(p => p.StockMovements)
                .HasForeignKey(sm => sm.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // ============ CRM Configurations ============

            // Lead relationships
            modelBuilder.Entity<Lead>()
                .HasOne(l => l.AssignedTo)
                .WithMany()
                .HasForeignKey(l => l.AssignedToId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Lead>()
                .HasOne(l => l.CreatedBy)
                .WithMany()
                .HasForeignKey(l => l.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Lead>()
                .HasOne(l => l.ConvertedContact)
                .WithMany()
                .HasForeignKey(l => l.ConvertedContactId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Lead>().Property(l => l.EstimatedValue).HasColumnType("decimal(18,4)");

            // Opportunity relationships
            modelBuilder.Entity<Opportunity>()
                .HasOne(o => o.Contact)
                .WithMany()
                .HasForeignKey(o => o.ContactId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Opportunity>()
                .HasOne(o => o.Owner)
                .WithMany()
                .HasForeignKey(o => o.OwnerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Opportunity>()
                .HasOne(o => o.Stage)
                .WithMany(s => s.Opportunities)
                .HasForeignKey(o => o.StageId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Opportunity>()
                .HasOne(o => o.SourceLead)
                .WithMany()
                .HasForeignKey(o => o.SourceLeadId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Opportunity>().Property(o => o.Amount).HasColumnType("decimal(18,4)");
            modelBuilder.Entity<Opportunity>().Property(o => o.WeightedAmount).HasColumnType("decimal(18,4)");

            // Activity relationships
            modelBuilder.Entity<Activity>()
                .HasOne(a => a.PerformedBy)
                .WithMany()
                .HasForeignKey(a => a.PerformedById)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Lead)
                .WithMany(l => l.Activities)
                .HasForeignKey(a => a.LeadId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Opportunity)
                .WithMany(o => o.Activities)
                .HasForeignKey(a => a.OpportunityId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Activity>()
                .HasOne(a => a.Contact)
                .WithMany()
                .HasForeignKey(a => a.ContactId)
                .OnDelete(DeleteBehavior.Restrict);

            // CrmTask relationships
            modelBuilder.Entity<CrmTask>()
                .HasOne(t => t.AssignedTo)
                .WithMany()
                .HasForeignKey(t => t.AssignedToId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<CrmTask>()
                .HasOne(t => t.CreatedBy)
                .WithMany()
                .HasForeignKey(t => t.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<CrmTask>()
                .HasOne(t => t.Lead)
                .WithMany(l => l.Tasks)
                .HasForeignKey(t => t.LeadId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<CrmTask>()
                .HasOne(t => t.Opportunity)
                .WithMany(o => o.Tasks)
                .HasForeignKey(t => t.OpportunityId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<CrmTask>()
                .HasOne(t => t.Contact)
                .WithMany()
                .HasForeignKey(t => t.ContactId)
                .OnDelete(DeleteBehavior.Restrict);

            // Call Seed Extension
            modelBuilder.Seed();
        }
    }
}
