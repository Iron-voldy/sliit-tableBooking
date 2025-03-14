package com.tablebooknow.service;

import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;
import com.tablebooknow.util.QRCodeGenerator;

import javax.mail.*;
import javax.mail.internet.*;
import javax.mail.util.ByteArrayDataSource;
import javax.activation.DataHandler;
import java.io.IOException;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;

/**
 * Service class for sending confirmation emails to users.
 */
public class EmailService {

    // SMTP Configuration - Update these with your actual Gmail credentials
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String USERNAME = "hoteltablereservation.sliit@gmail.com"; // Replace with your Gmail address
    private static final String PASSWORD = "zhuc luhf adtx bxas"; // Replace with your app password
    private static final boolean SMTP_AUTH = true;
    private static final boolean SMTP_STARTTLS = true;

    /**
     * Configures mail properties for SMTP connection.
     *
     * @return Properties object with mail settings
     */
    private static Properties getMailProperties() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", SMTP_AUTH);
        props.put("mail.smtp.starttls.enable", SMTP_STARTTLS);
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        return props;
    }

    /**
     * Creates and configures a mail session with authentication.
     *
     * @return Configured mail session
     */
    private static Session getMailSession() {
        return Session.getInstance(getMailProperties(), new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });
    }

    /**
     * Sends a confirmation email with QR code to the user after successful payment.
     * This method now has improved error handling and will not throw exceptions.
     *
     * @param user The user who made the reservation
     * @param reservation The reservation details
     * @param payment The payment details
     * @return true if email was sent successfully, false otherwise
     */
    public static boolean sendConfirmationEmail(User user, Reservation reservation, Payment payment) {
        if (user == null || user.getEmail() == null || user.getEmail().isEmpty()) {
            System.out.println("Cannot send email: User or email is missing");
            return false;
        }

        try {
            // Get mail session
            Session session = getMailSession();

            // Create message
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(user.getEmail()));
            message.setSubject("Reservation Confirmation - Gourmet Reserve");

            // Create QR code content
            String qrCodeContent = QRCodeGenerator.createQRCodeContent(
                    reservation.getId(), payment.getId(), user.getId());

            // Generate QR code image
            byte[] qrCodeBytes;
            try {
                qrCodeBytes = QRCodeGenerator.generateQRCodeImage(qrCodeContent, 300, 300);
            } catch (Exception e) {
                System.err.println("Error generating QR code: " + e.getMessage());
                e.printStackTrace();
                // Create placeholder QR code - empty byte array
                qrCodeBytes = new byte[0];
            }

            // Create HTML content for the email
            String emailContent = createEmailContent(user, reservation, payment);

            // Create multipart email with text and QR code image
            MimeMultipart multipart = new MimeMultipart("related");

            // Add HTML content
            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setContent(emailContent, "text/html; charset=utf-8");
            multipart.addBodyPart(textPart);

            // Only add QR code if we successfully generated it
            if (qrCodeBytes.length > 0) {
                try {
                    // Add QR code as attachment
                    MimeBodyPart qrPart = new MimeBodyPart();
                    ByteArrayDataSource qrDataSource = new ByteArrayDataSource(qrCodeBytes, "image/png");
                    qrPart.setDataHandler(new DataHandler(qrDataSource));
                    qrPart.setHeader("Content-ID", "<qr-code>");
                    qrPart.setFileName("reservation_qr.png");
                    multipart.addBodyPart(qrPart);
                } catch (Exception e) {
                    System.err.println("Error attaching QR code: " + e.getMessage());
                    e.printStackTrace();
                    // Continue without QR code
                }
            }

            // Set content of the message
            message.setContent(multipart);

            // Send message
            Transport.send(message);
            System.out.println("Confirmation email successfully sent to: " + user.getEmail());
            return true;

        } catch (MessagingException e) {
            System.err.println("Error sending confirmation email (messaging exception): " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("Unexpected error sending confirmation email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Creates the HTML content for the confirmation email.
     *
     * @param user The user who made the reservation
     * @param reservation The reservation details
     * @param payment The payment details
     * @return HTML content as a string
     */
    private static String createEmailContent(User user, Reservation reservation, Payment payment) {
        StringBuilder content = new StringBuilder();
        content.append("<html><head><style>");
        content.append("body { font-family: Arial, sans-serif; line-height: 1.6; }");
        content.append("h1 { color: #D4AF37; }");
        content.append(".container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }");
        content.append(".header { background-color: #1a1a1a; color: #fff; padding: 20px; text-align: center; }");
        content.append(".confirmation-info { margin: 20px 0; }");
        content.append(".details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 20px; }");
        content.append(".detail-item { margin-bottom: 10px; }");
        content.append(".qr-section { text-align: center; margin: 30px 0; }");
        content.append(".footer { margin-top: 30px; text-align: center; font-size: 12px; color: #777; }");
        content.append("</style></head><body>");

        content.append("<div class='container'>");
        content.append("<div class='header'><h1>Gourmet Reserve</h1><p>Reservation Confirmation</p></div>");

        content.append("<div class='confirmation-info'>");
        content.append("<p>Dear ").append(user.getUsername()).append(",</p>");
        content.append("<p>Thank you for choosing Gourmet Reserve. Your table reservation has been confirmed!</p>");
        content.append("</div>");

        content.append("<div class='details'>");
        content.append("<h3>Reservation Details</h3>");
        content.append("<div class='detail-item'><strong>Reservation ID:</strong> ").append(reservation.getId()).append("</div>");
        content.append("<div class='detail-item'><strong>Payment ID:</strong> ").append(payment.getId()).append("</div>");
        content.append("<div class='detail-item'><strong>Date:</strong> ").append(reservation.getReservationDate()).append("</div>");

        // Format time to be more readable
        String formattedTime;
        try {
            LocalTime time = LocalTime.parse(reservation.getReservationTime());
            LocalTime endTime = time.plusHours(reservation.getDuration());
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("h:mm a");
            formattedTime = time.format(formatter) + " - " + endTime.format(formatter);
        } catch (Exception e) {
            formattedTime = reservation.getReservationTime();
        }

        content.append("<div class='detail-item'><strong>Time:</strong> ").append(formattedTime).append("</div>");
        content.append("<div class='detail-item'><strong>Duration:</strong> ").append(reservation.getDuration()).append(" hours</div>");

        // Extract table information
        String tableType = "Standard";
        if (reservation.getTableId() != null) {
            char tableTypeChar = reservation.getTableId().charAt(0);
            if (tableTypeChar == 'f') tableType = "Family";
            else if (tableTypeChar == 'l') tableType = "Luxury";
            else if (tableTypeChar == 'c') tableType = "Couple";
            else if (tableTypeChar == 'r') tableType = "Regular";

            content.append("<div class='detail-item'><strong>Table Type:</strong> ").append(tableType).append("</div>");
            content.append("<div class='detail-item'><strong>Table ID:</strong> ").append(reservation.getTableId()).append("</div>");
        }

        if (payment.getAmount() != null) {
            content.append("<div class='detail-item'><strong>Amount Paid:</strong> ").append(payment.getAmount()).append(" ").append(payment.getCurrency()).append("</div>");
        }
        content.append("</div>");

        content.append("<div class='qr-section'>");
        content.append("<p>Please present this QR code when you arrive at the restaurant.</p>");
        content.append("<img src='cid:qr-code' alt='Reservation QR Code' style='width: 200px; height: 200px;'>");
        content.append("<p>This QR code contains your reservation details for quick check-in.</p>");
        content.append("</div>");

        content.append("<div class='footer'>");
        content.append("<p>We look forward to serving you at Gourmet Reserve!</p>");
        content.append("<p>If you need to make any changes to your reservation, please contact us at support@gourmetreserve.com</p>");
        content.append("<p>This is an automated message, please do not reply to this email.</p>");
        content.append("<p>&copy; 2025 Gourmet Reserve. All rights reserved.</p>");
        content.append("</div>");

        content.append("</div></body></html>");

        return content.toString();
    }
}