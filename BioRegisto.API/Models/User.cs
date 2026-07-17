namespace BioRegisto.API.Models;

public class User
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string? ProfileImageUrl { get; set; }

    public string PasswordHash { get; set; } = string.Empty;

    public string Role { get; set; } = "Observer";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<Observation> Observations { get; set; } = new();

    public bool IsActive { get; set; } = true;

    public string? PasswordResetCode { get; set; }

    public DateTime? PasswordResetCodeExpiresAt { get; set; }

}