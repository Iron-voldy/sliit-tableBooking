package com.tablebooknow.util;

import java.util.Base64;

/**
 * Utility class for generating placeholder QR code information.
 * This version doesn't use any external dependencies.
 */
public class QRCodeGenerator {

    /**
     * Returns a dummy byte array representing a QR code.
     * This method doesn't actually generate a QR code image.
     *
     * @param text The text that would be encoded in a real QR code
     * @param width The width that would be used for a real QR code
     * @param height The height that would be used for a real QR code
     * @return A dummy byte array (would be the QR code image in a real implementation)
     */
    public static byte[] generateQRCodeImage(String text, int width, int height) {
        // Log that we're not actually generating a QR code
        System.out.println("QR Code would be generated for: " + text);
        System.out.println("QR Code dimensions would be: " + width + "x" + height);

        // Return a dummy byte array
        return new byte[]{0, 1, 2, 3, 4, 5};
    }

    /**
     * Creates a JSON-formatted string containing reservation information that would be used for a QR code.
     *
     * @param reservationId The reservation ID
     * @param paymentId The payment ID
     * @param userId The user ID
     * @return A JSON-formatted string
     */
    public static String createQRCodeContent(String reservationId, String paymentId, String userId) {
        // Create a JSON-like string with the relevant information
        return String.format("{\"reservationId\":\"%s\",\"paymentId\":\"%s\",\"userId\":\"%s\",\"timestamp\":\"%s\"}",
                reservationId, paymentId, userId, System.currentTimeMillis());
    }

    /**
     * Creates a simulated Base64 QR code representation that can be used in HTML emails and pages.
     * This doesn't actually generate a real QR code, just a placeholder.
     *
     * @param text The text to encode in the QR code
     * @return A placeholder Base64 string that would represent a QR code image
     */
    public static String createQRCodeBase64(String text) {
        // In a real implementation, this would generate a QR code and convert to base64
        // Here we just create a placeholder string
        System.out.println("Would generate Base64 QR code for: " + text);

        // Return a placeholder that indicates this is a dummy
        return "QR_CODE_PLACEHOLDER_" + Base64.getEncoder().encodeToString(text.getBytes());
    }
}