using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BioRegisto.API.Data;
using BioRegisto.API.DTOs;
using BioRegisto.API.Models;

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
    // Todos os utilizadores autenticados
    // podem consultar notificações globais.
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var notifications =
            await _context.Notifications
                .OrderByDescending(
                    n => n.CreatedAt
                )
                .Select(n => new
                {
                    n.Id,
                    n.Title,
                    n.Message,
                    n.CreatedAt
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