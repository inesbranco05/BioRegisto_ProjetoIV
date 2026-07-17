using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authorization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;
using BioRegisto.API.Services;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly BioRegistoDbContext _context;
    private readonly IConfiguration _configuration;

    private readonly IWebHostEnvironment _environment;

    private readonly EmailService _emailService;

  public AuthController(
    BioRegistoDbContext context,
    IConfiguration configuration,
    IWebHostEnvironment environment,
    EmailService emailService)
{
    _context = context;
    _configuration = configuration;
    _environment = environment;
    _emailService = emailService;
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
                user.Role,
                user.ProfileImageUrl
            }
        });
    }

    [HttpPut("profile")]
[Authorize]
public async Task<IActionResult> UpdateProfile(
    UpdateProfileDto request)
{
    var userIdClaim =
        User.FindFirstValue(
            ClaimTypes.NameIdentifier
        );

    if (!int.TryParse(
        userIdClaim,
        out var userId))
    {
        return Unauthorized();
    }

    if (string.IsNullOrWhiteSpace(
            request.Name) ||
        string.IsNullOrWhiteSpace(
            request.Email))
    {
        return BadRequest(new
        {
            message =
                "O nome e o email são obrigatórios."
        });
    }

    var normalizedEmail =
        request.Email
            .Trim()
            .ToLower();

    // Verificar se o novo email
    // pertence a outro utilizador.
    var emailExists =
        await _context.Users
            .AnyAsync(u =>
                u.Email ==
                    normalizedEmail &&
                u.Id != userId
            );

    if (emailExists)
    {
        return BadRequest(new
        {
            message =
                "Este email já está associado a outra conta."
        });
    }

    var user =
        await _context.Users
            .FindAsync(userId);

    if (user == null)
    {
        return NotFound(new
        {
            message =
                "Utilizador não encontrado."
        });
    }

    user.Name =
        request.Name.Trim();

    user.Email =
        normalizedEmail;

    await _context.SaveChangesAsync();

    return Ok(new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role,
        user.ProfileImageUrl
    });
}

[HttpPut("profile/image")]
[Authorize]
public async Task<IActionResult> UpdateProfileImage(
    IFormFile image)
{
    var userIdClaim =
        User.FindFirstValue(
            ClaimTypes.NameIdentifier
        );

    if (!int.TryParse(
        userIdClaim,
        out var userId))
    {
        return Unauthorized();
    }

    if (image == null ||
        image.Length == 0)
    {
        return BadRequest(new
        {
            message =
                "Selecione uma imagem."
        });
    }

    var user =
        await _context.Users
            .FindAsync(userId);

    if (user == null)
    {
        return NotFound(new
        {
            message =
                "Utilizador não encontrado."
        });
    }

    var uploadsFolder =
        Path.Combine(
            _environment.WebRootPath,
            "uploads",
            "profiles"
        );

    Directory.CreateDirectory(
        uploadsFolder
    );

    var extension =
        Path.GetExtension(
            image.FileName
        );

    var fileName =
        $"{Guid.NewGuid()}{extension}";

    var filePath =
        Path.Combine(
            uploadsFolder,
            fileName
        );

    await using (
        var stream =
            new FileStream(
                filePath,
                FileMode.Create
            )
    )
    {
        await image.CopyToAsync(
            stream
        );
    }

    // Apagar a fotografia anterior,
    // caso exista.
    if (!string.IsNullOrWhiteSpace(
            user.ProfileImageUrl))
    {
        var oldRelativePath =
            user.ProfileImageUrl
                .TrimStart('/')
                .Replace(
                    '/',
                    Path.DirectorySeparatorChar
                );

        var oldFilePath =
            Path.Combine(
                _environment.WebRootPath,
                oldRelativePath
            );

        if (System.IO.File.Exists(
                oldFilePath))
        {
            System.IO.File.Delete(
                oldFilePath
            );
        }
    }

    user.ProfileImageUrl =
        $"/uploads/profiles/{fileName}";

    await _context.SaveChangesAsync();

    return Ok(new
    {
        user.Id,
        user.Name,
        user.Email,
        user.Role,
        user.ProfileImageUrl
    });
}

[HttpPost("forgot-password")]
public async Task<IActionResult> ForgotPassword(
    ForgotPasswordDto request)
{
    var email =
        request.Email
            .Trim()
            .ToLower();

    if (string.IsNullOrWhiteSpace(email))
    {
        return BadRequest(new
        {
            message =
                "Introduza o seu email."
        });
    }

    var user =
        await _context.Users
            .FirstOrDefaultAsync(
                u => u.Email == email
            );

    // Não revelamos se o email existe
    // ou não na aplicação.
    if (user == null)
    {
        return Ok(new
        {
            message =
                "Se existir uma conta associada a este email, receberá um código de recuperação."
        });
    }

    var resetCode =
        Random.Shared
            .Next(100000, 1000000)
            .ToString();

    user.PasswordResetCode =
        resetCode;

    user.PasswordResetCodeExpiresAt =
        DateTime.UtcNow
            .AddMinutes(15);

  await _context.SaveChangesAsync();

try
{
    await _emailService
        .SendPasswordResetCodeAsync(
            user.Email,
            resetCode
        );
}
catch (Exception)
{
    return StatusCode(
        500,
        new
        {
            message =
                "Não foi possível enviar o email de recuperação."
        }
    );
}

return Ok(new
{
    message =
        "Se existir uma conta associada a este email, receberá um código de recuperação."
});
}

[HttpPost("reset-password")]
public async Task<IActionResult> ResetPassword(
    ResetPasswordDto request)
{
    var email =
        request.Email
            .Trim()
            .ToLower();

    var code =
        request.Code.Trim();

    if (string.IsNullOrWhiteSpace(email) ||
        string.IsNullOrWhiteSpace(code) ||
        string.IsNullOrWhiteSpace(
            request.NewPassword))
    {
        return BadRequest(new
        {
            message =
                "Preencha todos os campos."
        });
    }

    if (request.NewPassword.Length < 6)
    {
        return BadRequest(new
        {
            message =
                "A nova palavra-passe deve ter pelo menos 6 caracteres."
        });
    }

    var user =
        await _context.Users
            .FirstOrDefaultAsync(
                u =>
                    u.Email == email &&
                    u.PasswordResetCode ==
                        code
            );

    if (user == null)
    {
        return BadRequest(new
        {
            message =
                "O código de recuperação é inválido."
        });
    }

    if (user.PasswordResetCodeExpiresAt ==
            null ||
        user.PasswordResetCodeExpiresAt <
            DateTime.UtcNow)
    {
        return BadRequest(new
        {
            message =
                "O código de recuperação expirou."
        });
    }

    var passwordHasher =
        new PasswordHasher<User>();

    user.PasswordHash =
        passwordHasher.HashPassword(
            user,
            request.NewPassword
        );

    // O código deixa de poder ser utilizado.
    user.PasswordResetCode =
        null;

    user.PasswordResetCodeExpiresAt =
        null;

    await _context.SaveChangesAsync();

    return Ok(new
    {
        message =
            "Palavra-passe alterada com sucesso."
    });
}
}