using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using AutoMapper;

namespace AccountingApp.API.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // ======== Employee ========
            // MaxDepth(64): CVE-2026-32933 DoS koruması
            CreateMap<Employee, EmployeeDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.DepartmentName, opt => opt.MapFrom(src => src.Department.Name))
                .ForMember(dest => dest.PositionName, opt => opt.MapFrom(src => src.Position.Name))
                .ForMember(dest => dest.CurrencyCode, opt => opt.MapFrom(src => src.Currency.Code));

            CreateMap<EmployeeCreateDto, Employee>().MaxDepth(64);
            CreateMap<EmployeeUpdateDto, Employee>().MaxDepth(64);

            // ======== Invoice ========
            CreateMap<Invoice, InvoiceListDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.ContactName, opt => opt.MapFrom(src => src.BusinessContact.Name))
                .ForMember(dest => dest.CurrencyCode, opt => opt.MapFrom(src => src.Currency.Code));

            CreateMap<Invoice, InvoiceDetailDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.ContactName, opt => opt.MapFrom(src => src.BusinessContact.Name))
                .ForMember(dest => dest.ContactTaxNumber, opt => opt.MapFrom(src => src.BusinessContact.TaxNumber))
                .ForMember(dest => dest.ContactTaxOffice, opt => opt.MapFrom(src => src.BusinessContact.TaxOffice))
                .ForMember(dest => dest.ContactAddress, opt => opt.MapFrom(src => src.BusinessContact.Address))
                .ForMember(dest => dest.CurrencyCode, opt => opt.MapFrom(src => src.Currency.Code))
                .ForMember(dest => dest.SubTotal, opt => opt.MapFrom(src => src.TotalAmount - src.TaxAmount))
                .ForMember(dest => dest.Lines, opt => opt.MapFrom(src => src.InvoiceLines));

            CreateMap<InvoiceLine, InvoiceLineDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name));

            CreateMap<InvoiceCreateDto, Invoice>()
                .MaxDepth(64)
                .ForMember(dest => dest.InvoiceLines, opt => opt.MapFrom(src => src.Lines));

            CreateMap<InvoiceLineCreateDto, InvoiceLine>()
                .MaxDepth(64)
                .ForMember(dest => dest.LineTotal, opt => opt.MapFrom(src => src.Quantity * src.UnitPrice * (1 + (src.TaxRate / 100))));

            // ======== Product ========
            CreateMap<Product, ProductDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name))
                .ForMember(dest => dest.CurrencyCode, opt => opt.MapFrom(src => src.Currency.Code))
                .ForMember(dest => dest.CurrencySymbol, opt => opt.MapFrom(src => src.Currency.Symbol));

            CreateMap<ProductCreateDto, Product>().MaxDepth(64);
            CreateMap<ProductUpdateDto, Product>().MaxDepth(64);

            // ======== Transaction ========
            CreateMap<Transaction, TransactionDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.BusinessContactName, opt => opt.MapFrom(src => src.BusinessContact != null ? src.BusinessContact.Name : null))
                .ForMember(dest => dest.InvoiceNumber, opt => opt.MapFrom(src => src.Invoice != null ? src.Invoice.InvoiceNumber : null))
                .ForMember(dest => dest.CurrencyCode, opt => opt.MapFrom(src => src.Currency.Code))
                .ForMember(dest => dest.CurrencySymbol, opt => opt.MapFrom(src => src.Currency.Symbol));

            CreateMap<TransactionCreateDto, Transaction>().MaxDepth(64);

            // ======== Lookups ========
            CreateMap<Department, DepartmentDto>().MaxDepth(64);
            CreateMap<Position, PositionDto>()
                .MaxDepth(64)
                .ForMember(dest => dest.DepartmentName, opt => opt.MapFrom(src => src.Department.Name));
            CreateMap<Category, CategoryDto>().MaxDepth(64);
            CreateMap<Currency, CurrencyDto>().MaxDepth(64);
            
            CreateMap<BusinessContact, BusinessContactDto>().MaxDepth(64);
            CreateMap<BusinessContactCreateDto, BusinessContact>().MaxDepth(64);

            // ======== CRM — Lead ========
            CreateMap<LeadCreateDto, Lead>()
                .MaxDepth(64)
                .ForMember(dest => dest.Source, opt => opt.MapFrom(src => (LeadSource)src.Source))
                .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => (LeadPriority)src.Priority));

            CreateMap<LeadUpdateDto, Lead>()
                .MaxDepth(64)
                .ForMember(dest => dest.Source, opt => opt.MapFrom(src => (LeadSource)src.Source))
                .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => (LeadPriority)src.Priority));

            // ======== CRM — Activity ========
            CreateMap<ActivityCreateDto, Activity>()
                .MaxDepth(64)
                .ForMember(dest => dest.Type, opt => opt.MapFrom(src => (ActivityType)src.Type));

            // ======== CRM — CrmTask ========
            CreateMap<CrmTaskCreateDto, CrmTask>()
                .MaxDepth(64)
                .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => (CrmTaskPriority)src.Priority));

            CreateMap<CrmTaskUpdateDto, CrmTask>()
                .MaxDepth(64)
                .ForMember(dest => dest.Priority, opt => opt.MapFrom(src => (CrmTaskPriority)src.Priority));
        }
    }
}
