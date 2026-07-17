using System.Net;
using System.Net.Mail;

namespace BioRegisto.API.Services;

public class EmailService
{
    private readonly IConfiguration
        _configuration;

    public EmailService(
        IConfiguration configuration)
    {
        _configuration =
            configuration;
    }

    public async Task SendPasswordResetCodeAsync(
        string recipientEmail,
        string code)
    {
        var host =
            _configuration[
                "Email:SmtpHost"
            ]!;

        var port =
            int.Parse(
                _configuration[
                    "Email:SmtpPort"
                ]!
            );

        var senderEmail =
            _configuration[
                "Email:SenderEmail"
            ]!;

        var senderName =
            _configuration[
                "Email:SenderName"
            ]!;

        var password =
            _configuration[
                "Email:SmtpPassword"
            ]!;

        using var smtpClient =
            new SmtpClient(
                host,
                port
            )
            {
                EnableSsl = true,

                Credentials =
                    new NetworkCredential(
                        senderEmail,
                        password
                    )
            };

        using var message =
            new MailMessage
            {
                From =
                    new MailAddress(
                        senderEmail,
                        senderName
                    ),

                Subject =
                    "Código de recuperação - BioRegisto",

                Body =
                    $"""
                    Olá,

                    Recebemos um pedido para recuperar a palavra-passe da sua conta BioRegisto.

                    O seu código de recuperação é:

                    {code}

                    Este código é válido durante 15 minutos.

                    Se não solicitou esta alteração, pode ignorar este email.

                    BioRegisto
                    """,

                IsBodyHtml = false
            };

        message.To.Add(
            recipientEmail
        );

        await smtpClient
            .SendMailAsync(
                message
            );
    }
}