using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;



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
                u.Role,
                u.IsActive
            })
            .ToListAsync();

        return Ok(users);
    }

    // POST api/Users
[HttpPost]
public async Task<IActionResult> Create(
    CreateUserDto request)
{
    if (string.IsNullOrWhiteSpace(request.Name) ||
        string.IsNullOrWhiteSpace(request.Email) ||
        string.IsNullOrWhiteSpace(request.Password))
    {
        return BadRequest(new
        {
            message =
                "Nome, email e palavra-passe são obrigatórios."
        });
    }

    var email = request.Email
        .Trim()
        .ToLower();

    var emailExists =
        await _context.Users.AnyAsync(
            user => user.Email == email
        );

    if (emailExists)
    {
        return BadRequest(new
        {
            message =
                "Este email já está registado."
        });
    }

    // O administrador pode criar
    // Observadores ou Técnicos.
    var validRoles = new[]
    {
        "Observer",
        "Validator"
    };

    if (!validRoles.Contains(request.Role))
    {
        return BadRequest(new
        {
            message =
                "O papel selecionado não é válido."
        });
    }

    var user = new User
    {
        Name = request.Name.Trim(),
        Email = email,
        Role = request.Role,
        IsActive = true,
        CreatedAt = DateTime.UtcNow
    };

    var passwordHasher =
        new PasswordHasher<User>();

    user.PasswordHash =
        passwordHasher.HashPassword(
            user,
            request.Password
        );

    _context.Users.Add(user);

    await _context.SaveChangesAsync();

    return Ok(new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role
    });
}

// PUT api/Users/{id}
[HttpPut("{id:int}")]
public async Task<IActionResult> Update(
    int id,
    UpdateUserDto request)
{
    var user =
        await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new
        {
            message =
                "Utilizador não encontrado."
        });
    }

    // Não permitir alterar a conta Admin
    // através da gestão normal.
    if (user.Role == "Admin")
    {
        return BadRequest(new
        {
            message =
                "A conta de administrador não pode ser alterada."
        });
    }

    if (string.IsNullOrWhiteSpace(request.Name) ||
        string.IsNullOrWhiteSpace(request.Email))
    {
        return BadRequest(new
        {
            message =
                "Nome e email são obrigatórios."
        });
    }

    var email = request.Email
        .Trim()
        .ToLower();

    var emailExists =
        await _context.Users.AnyAsync(
            other =>
                other.Email == email &&
                other.Id != id
        );

    if (emailExists)
    {
        return BadRequest(new
        {
            message =
                "Este email já está associado a outra conta."
        });
    }

    var validRoles = new[]
    {
        "Observer",
        "Validator"
    };

    if (!validRoles.Contains(request.Role))
    {
        return BadRequest(new
        {
            message =
                "O papel selecionado não é válido."
        });
    }

    user.Name =
        request.Name.Trim();

    user.Email = email;

    user.Role =
        request.Role;

    await _context.SaveChangesAsync();

    return Ok(new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role
    });
}

// PATCH api/Users/{id}/status
[HttpPatch("{id:int}/status")]
public async Task<IActionResult> ChangeStatus(
    int id)
{
    var user =
        await _context.Users.FindAsync(id);

    if (user == null)
    {
        return NotFound(new
        {
            message = "Utilizador não encontrado."
        });
    }

    if (user.Role == "Admin")
    {
        return BadRequest(new
        {
            message =
                "A conta de administrador não pode ser desativada."
        });
    }

    user.IsActive = !user.IsActive;

    await _context.SaveChangesAsync();

    return Ok(new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role,
        user.IsActive
    });
}

}