using AccountingApp.API.Data;
using AccountingApp.API.DTOs;
using AccountingApp.API.Models;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AccountingApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DepartmentsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public DepartmentsController(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<DepartmentDto>>> GetDepartments()
        {
            var departments = await _context.Departments
                .Where(d => d.IsActive)
                .OrderBy(d => d.Name)
                .ToListAsync();

            return Ok(_mapper.Map<IEnumerable<DepartmentDto>>(departments));
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DepartmentDto>> GetDepartment(int id)
        {
            var department = await _context.Departments
                .FirstOrDefaultAsync(d => d.Id == id && d.IsActive);

            if (department == null) return NotFound();

            return Ok(_mapper.Map<DepartmentDto>(department));
        }

        [HttpPost]
        [Authorize(Roles = "Admin,İK")]
        public async Task<ActionResult<DepartmentDto>> CreateDepartment([FromBody] DepartmentCreateDto dto)
        {
            var dept = new Department
            {
                Name = dto.Name,
                IsActive = true
            };

            _context.Departments.Add(dept);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetDepartment), new { id = dept.Id }, _mapper.Map<DepartmentDto>(dept));
        }
    }
}
