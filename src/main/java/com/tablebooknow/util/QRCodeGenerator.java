package com.tablebooknow.util;

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
}