using AccountingApp.API.Models;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Data
{
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

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
            base.OnConfiguring(optionsBuilder);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Many-to-Many configuration for UserRoles
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

            // Unique Constraints
            modelBuilder.Entity<User>().HasIndex(u => u.Username).IsUnique();
            modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
            modelBuilder.Entity<Role>().HasIndex(r => r.Name).IsUnique();
            modelBuilder.Entity<Employee>().HasIndex(e => e.IdentityNumber).IsUnique();
            modelBuilder.Entity<Product>().HasIndex(p => p.Code).IsUnique();
            modelBuilder.Entity<Invoice>().HasIndex(i => i.InvoiceNumber).IsUnique();

            // Decimal Precision Configurations
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

            // Relationships to avoid cascading delete issues on multiple execution paths
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

            // Call Seed Extension
            modelBuilder.Seed();
        }
    }
}
