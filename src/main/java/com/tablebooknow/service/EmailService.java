package com.tablebooknow.service;

import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;
import com.tablebooknow.util.QRCodeGenerator;

/**
 * Service class for sending confirmation emails to users.
 * This is a simplified version that doesn't actually send emails
 * but logs the email content that would have been sent.
 */
public class EmailService {

    /**
     * Simulates sending a confirmation email to the user with QR code.
     *
     * @param user The user who made the reservation
     * @param reservation The reservation details
     * @param payment The payment details
     */
    public static void sendConfirmationEmail(User user, Reservation reservation, Payment payment) {
        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            System.out.println("Cannot send email: User email is missing");
            return;
        }

        try {
            System.out.println("EMAIL WOULD BE SENT TO: " + user.getEmail());
            System.out.println("SUBJECT: Reservation Confirmation - Gourmet Reserve");

            // Generate QR code content
            String qrCodeContent = QRCodeGenerator.createQRCodeContent(
                    reservation.getId(),
                    payment.getId(),
                    user.getId());

            // In a real implementation, this would generate a QR code image
            // and attach it to the email
            System.out.println("QR CODE CONTENT: " + qrCodeContent);

            // Create email content with QR code reference
            String emailContent = createEmailContent(user, reservation, payment, qrCodeContent);

            // Log the first 200 characters of what would be sent
            System.out.println("EMAIL CONTENT PREVIEW: " +
                    (emailContent.length() > 200 ?
                            emailContent.substring(0, 200) + "..." :
                            emailContent));

            System.out.println("RESERVATION ID: " + reservation.getId());
            System.out.println("PAYMENT ID: " + payment.getId());

            // Log success message
            System.out.println("Email with QR code would have been successfully sent to: " + user.getEmail());
        } catch (Exception e) {
            System.err.println("Error preparing email content: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Creates the HTML content for the confirmation email with QR code.
     *
     * @param user The user who made the reservation
     * @param reservation The reservation details
     * @param payment The payment details
     * @param qrCodeContent Content for the QR code
     * @return HTML content as a string
     */
    private static String createEmailContent(User user, Reservation reservation, Payment payment, String qrCodeContent) {
        StringBuilder content = new StringBuilder();
        content.append("<html><head><style>");
        content.append("body { font-family: Arial, sans-serif; line-height: 1.6; }");
        content.append("h1 { color: #D4AF37; }");
        content.append("</style></head><body>");

        content.append("<div>");
        content.append("<h1>Gourmet Reserve</h1><p>Reservation Confirmation</p>");

        content.append("<div>");
        content.append("<p>Dear ").append(user.getUsername()).append(",</p>");
        content.append("<p>Thank you for choosing Gourmet Reserve. Your table reservation has been confirmed!</p>");
        content.append("</div>");

        content.append("<div>");
        content.append("<h3>Reservation Details</h3>");
        content.append("<div><strong>Reservation ID:</strong> ").append(reservation.getId()).append("</div>");
        content.append("<div><strong>Payment ID:</strong> ").append(payment.getId()).append("</div>");
        content.append("<div><strong>Date:</strong> ").append(reservation.getReservationDate()).append("</div>");
        content.append("<div><strong>Time:</strong> ").append(reservation.getReservationTime()).append("</div>");
        content.append("<div><strong>Duration:</strong> ").append(reservation.getDuration()).append(" hours</div>");

        // Extract table information
        String tableType = "Standard";
        if (reservation.getTableId() != null) {
            char tableTypeChar = reservation.getTableId().charAt(0);
            if (tableTypeChar == 'f') tableType = "Family";
            else if (tableTypeChar == 'l') tableType = "Luxury";
            else if (tableTypeChar == 'c') tableType = "Couple";
            else if (tableTypeChar == 'r') tableType = "Regular";

            content.append("<div><strong>Table Type:</strong> ").append(tableType).append("</div>");
            content.append("<div><strong>Table ID:</strong> ").append(reservation.getTableId()).append("</div>");
        }

        if (payment.getAmount() != null) {
            content.append("<div><strong>Amount Paid:</strong> ").append(payment.getAmount()).append(" ").append(payment.getCurrency()).append("</div>");
        }
        content.append("</div>");

        content.append("<div>");
        content.append("<p>Please show your reservation ID or scan the QR code below when you arrive at the restaurant.</p>");

        // QR Code placeholder
        content.append("<div style='margin: 20px auto; padding: 15px; background-color: #f5f5f5; border-radius: 8px; width: 250px; text-align: center;'>");
        content.append("<p>Your QR Code for check-in:</p>");
        content.append("<div style='font-family: monospace; background-color: #fff; padding: 15px; width: 200px; height: 200px; margin: 0 auto; border: 1px solid #ddd; display: flex; align-items: center; justify-content: center;'>");
        content.append("<span style='font-weight: bold;'>QR</span>");
        content.append("</div>");
        content.append("<p style='font-size: 12px; margin-top: 10px;'>QR Content: ").append(qrCodeContent).append("</p>");
        content.append("</div>");

        content.append("<div style='margin: 20px auto; padding: 15px; background-color: #f5f5f5; border-radius: 8px; width: 250px; text-align: center;'>");
        content.append("<span style='font-family: monospace; font-size: 18px; font-weight: bold; color: #000;'>").append(reservation.getId()).append("</span>");
        content.append("</div>");
        content.append("<p>You can also access your reservation details from your account.</p>");
        content.append("</div>");

        content.append("<div>");
        content.append("<p>We look forward to serving you at Gourmet Reserve!</p>");
        content.append("<p>If you need to make any changes to your reservation, please contact us.</p>");
        content.append("<p>This is an automated message, please do not reply to this email.</p>");
        content.append("<p>&copy; 2025 Gourmet Reserve. All rights reserved.</p>");
        content.append("</div>");

        content.append("</div></body></html>");

        return content.toString();
    }
}