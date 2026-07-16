namespace BioRegisto.API.Models;

public class EventChallenge
{
    public int Id { get; set; }

    public string Title { get; set; }
        = string.Empty;

    public string Description { get; set; }
        = string.Empty;

    // "Event" ou "Challenge"
    public string Type { get; set; }
        = string.Empty;

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public bool IsActive { get; set; }
        = true;

    public DateTime CreatedAt { get; set; }
        = DateTime.UtcNow;
}