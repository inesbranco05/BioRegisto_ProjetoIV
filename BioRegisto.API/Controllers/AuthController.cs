using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly BioRegistoDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(
        BioRegistoDbContext context,
        IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    private string GenerateJwtToken(User user)
{
    var claims = new List<Claim>
    {
        new Claim(
            ClaimTypes.NameIdentifier,
            user.Id.ToString()
        ),

        new Claim(
            ClaimTypes.Name,
            user.Name
        ),

        new Claim(
            ClaimTypes.Email,
            user.Email
        ),

        new Claim(
            ClaimTypes.Role,
            user.Role
        )
    };

    var key = new SymmetricSecurityKey(
        Encoding.UTF8.GetBytes(
            _configuration["Jwt:Key"]!
        )
    );

    var credentials =
        new SigningCredentials(
            key,
            SecurityAlgorithms.HmacSha256
        );

    var expirationMinutes =
        int.Parse(
            _configuration[
                "Jwt:ExpirationMinutes"
            ]!
        );

    var token = new JwtSecurityToken(
        issuer:
            _configuration["Jwt:Issuer"],

        audience:
            _configuration["Jwt:Audience"],

        claims: claims,

        expires:
            DateTime.UtcNow.AddMinutes(
                expirationMinutes
            ),

        signingCredentials:
            credentials
    );

    return new JwtSecurityTokenHandler()
        .WriteToken(token);
}

    [HttpPost("register")]
    public async Task<IActionResult> Register(
        RegisterDto request)
    {
        // Verificar se o email já está registado
        var emailExists = await _context.Users
            .AnyAsync(user =>
                user.Email == request.Email);

        if (emailExists)
        {
            return BadRequest(new
            {
                message =
                    "Este email já está registado."
            });
        }

        var user = new User
        {
            Name = request.Name.Trim(),
            Email = request.Email
                .Trim()
                .ToLower(),

            Role = "Observer",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        // Criar hash seguro da password
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
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto request)
    {
        var email = request.Email
            .Trim()
            .ToLower();

        var user = await _context.Users
            .FirstOrDefaultAsync(
                user => user.Email == email
            );

        if (user == null)
{
    return Unauthorized(new
    {
        message = "Email ou palavra-passe incorretos."
    });
}

// Impedir o login de contas desativadas
if (!user.IsActive)
{
    return Unauthorized(new
    {
        message =
            "Esta conta encontra-se desativada."
    });
}

var passwordHasher =
    new PasswordHasher<User>();

        var result =
            passwordHasher.VerifyHashedPassword(
                user,
                user.PasswordHash,
                request.Password
            );

        if (result ==
            PasswordVerificationResult.Failed)
        {
            return Unauthorized(new
            {
                message = "Email ou palavra-passe incorretos."
            });
        }

        var token = GenerateJwtToken(user);

        return Ok(new
        {
            token,

            user = new
            {
                user.Id,
                user.Name,
                user.Email,
                user.Role
            }
        });
    }
}