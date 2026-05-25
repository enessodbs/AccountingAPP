using System;
using System.Linq;
using AccountingApp.API.Data;
using AccountingApp.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

var builder = new ConfigurationBuilder().AddJsonFile(\"appsettings.json\");
var config = builder.Build();

var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();
optionsBuilder.UseSqlServer(config.GetConnectionString(\"DefaultConnection\"));

using (var db = new AppDbContext(optionsBuilder.Options))
{
    var incomes = db.Invoices.Where(i => i.Type == InvoiceType.Sales).Sum(i => i.TotalAmount);
    var expenses = db.Invoices.Where(i => i.Type == InvoiceType.Purchase).Sum(i => i.TotalAmount);
    var pending = db.Invoices.Count(i => i.Status == InvoiceStatus.Pending);
    Console.WriteLine($\"Total Sales: {incomes}, Total Purchases: {expenses}, Pending: {pending}\");
    
    var thisMonth = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
    var incomesThisMonth = db.Invoices.Where(i => i.Type == InvoiceType.Sales && i.IssueDate >= thisMonth).Sum(i => i.TotalAmount);
    Console.WriteLine($\"This month sales: {incomesThisMonth}\");
}
