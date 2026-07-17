using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;
using System.Security.Claims;

namespace BioRegisto.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly BioRegistoDbContext _context;

    public NotificationsController(
        BioRegistoDbContext context)
    {
        _context = context;
    }

    // GET api/Notifications
// Devolve notificações globais
// + notificações individuais do utilizador autenticado.
[HttpGet]
public async Task<IActionResult> GetAll()
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

    var notifications =
        await _context.Notifications

            // Global:
            // UserId == null
            //
            // Individual:
            // UserId == utilizador autenticado
            .Where(n =>
                n.UserId == null ||
                n.UserId == userId
            )

            .OrderByDescending(
                n => n.CreatedAt
            )

            .Select(n => new
            {
                n.Id,
                n.Title,
                n.Message,
                n.CreatedAt,

                // Pode ser útil no mobile
                // para distinguir os dois tipos.
                IsGlobal =
                    n.UserId == null
            })

            .ToListAsync();

    return Ok(notifications);
}

    // POST api/Notifications
    // Apenas administradores podem
    // enviar notificações globais.
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create(
        CreateNotificationDto request)
    {
        if (string.IsNullOrWhiteSpace(
                request.Title) ||
            string.IsNullOrWhiteSpace(
                request.Message))
        {
            return BadRequest(new
            {
                message =
                    "O título e a mensagem são obrigatórios."
            });
        }

        var notification =
            new Notification
            {
                Title =
                    request.Title.Trim(),

                Message =
                    request.Message.Trim(),

                CreatedAt =
                    DateTime.UtcNow
            };

        _context.Notifications.Add(
            notification
        );

        await _context.SaveChangesAsync();

        return Ok(new
        {
            notification.Id,
            notification.Title,
            notification.Message,
            notification.CreatedAt
        });
    }
}