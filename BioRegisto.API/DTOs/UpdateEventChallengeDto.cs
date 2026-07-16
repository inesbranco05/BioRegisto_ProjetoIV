namespace BioRegisto.API.DTOs;

public class UpdateEventChallengeDto
{
    public string Title { get; set; }
        = string.Empty;

    public string Description { get; set; }
        = string.Empty;

    public string Type { get; set; }
        = string.Empty;

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public bool IsActive { get; set; }
}