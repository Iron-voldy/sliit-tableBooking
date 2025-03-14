package com.tablebooknow.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Utility class for generating QR codes for reservation confirmations.
 */
public class QRCodeGenerator {

    /**
     * Generates a QR code image from the specified text.
     *
     * @param text The text to encode in the QR code
     * @param width The width of the QR code image
     * @param height The height of the QR code image
     * @return A byte array containing the QR code image in PNG format
     * @throws WriterException If an error occurs during QR code generation
     * @throws IOException If an error occurs writing the image
     */
    public static byte[] generateQRCodeImage(String text, int width, int height) throws WriterException, IOException {
        // Set up encoding parameters
        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H); // High error correction
        hints.put(EncodeHintType.MARGIN, 2); // Default margin

        // Generate the QR code bit matrix
        BitMatrix bitMatrix = new MultiFormatWriter().encode(text, BarcodeFormat.QR_CODE, width, height, hints);

        // Convert to PNG image
        ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);

        return pngOutputStream.toByteArray();
    }

    /**
     * Creates a JSON-formatted string containing reservation information for the QR code.
     *
     * @param reservationId The reservation ID
     * @param paymentId The payment ID
     * @param userId The user ID
     * @return A JSON-formatted string for encoding in the QR code
     */
    public static String createQRCodeContent(String reservationId, String paymentId, String userId) {
        // Create a JSON-like string with the relevant information
        return String.format("{\"reservationId\":\"%s\",\"paymentId\":\"%s\",\"userId\":\"%s\",\"timestamp\":\"%s\"}",
                reservationId, paymentId, userId, System.currentTimeMillis());
    }
}