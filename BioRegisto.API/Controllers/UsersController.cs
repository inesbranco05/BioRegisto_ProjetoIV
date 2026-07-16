using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public UsersController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/Users
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users = await _context.Users
            .OrderBy(u => u.Name)
            .Select(u => new
            {
                u.Id,
                u.Name,
                u.Email,
                u.Role
            })
            .ToListAsync();

        return Ok(users);
    }
}