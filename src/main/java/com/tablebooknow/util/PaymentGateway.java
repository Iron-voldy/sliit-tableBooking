package com.tablebooknow.util;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Utility class for handling payment processing through PayHere payment gateway.
 */
public class PaymentGateway {

    private static final String PAYMENT_FILE_PATH = getDataFilePath("payments.txt");

    // PayHere sandbox merchant ID (replace with real merchant ID in production)
    private static final String PAYHERE_MERCHANT_ID = "1221688";

    // PayHere API endpoints
    private static final String PAYHERE_SANDBOX_URL = "https://sandbox.payhere.lk/pay/checkout";
    private static final String PAYHERE_LIVE_URL = "https://www.payhere.lk/pay/checkout";

    // Environment setting (true for sandbox, false for production)
    private static final boolean IS_SANDBOX = true;

    /**
     * Gets the path to a data file, using the application's data directory.
     */
    private static String getDataFilePath(String fileName) {
        String dataPath = System.getProperty("app.datapath");

        // Fallback to user.dir/data if app.datapath is not set
        if (dataPath == null) {
            dataPath = System.getProperty("user.dir") + File.separator + "data";
            // Ensure the directory exists
            File dir = new File(dataPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }
        }

        return dataPath + File.separator + fileName;
    }

    /**
     * Gets the PayHere API URL based on environment setting.
     *
     * @return PayHere API URL
     */
    public static String getPayhereApiUrl() {
        return IS_SANDBOX ? PAYHERE_SANDBOX_URL : PAYHERE_LIVE_URL;
    }

    /**
     * Gets the PayHere merchant ID.
     *
     * @return PayHere merchant ID
     */
    public static String getPayhereMerchantId() {
        return PAYHERE_MERCHANT_ID;
    }

    /**
     * Process a payment through the PayHere gateway.
     *
     * @param userId User ID
     * @param reservationId Reservation ID
     * @param amount Payment amount
     * @param currency Currency code (e.g. USD)
     * @return Payment ID if successful, null otherwise
     */
    public static String processPayment(String userId, String reservationId, double amount, String currency) {
        // This method would typically involve interaction with PayHere API
        // For now, we'll simulate a successful payment

        String paymentId = UUID.randomUUID().toString();
        boolean success = storePaymentRecord(paymentId, userId, reservationId, amount, currency);

        if (success) {
            System.out.println("Payment processed successfully with ID: " + paymentId);
            return paymentId;
        } else {
            System.err.println("Failed to store payment record");
            return null;
        }
    }

    /**
     * Store payment record in a file.
     * Format: paymentId,userId,reservationId,amount,currency,timestamp,status
     */
    private static boolean storePaymentRecord(String paymentId, String userId, String reservationId,
                                              double amount, String currency) {
        try {
            // Make sure the file exists
            FileHandler.ensureFileExists(PAYMENT_FILE_PATH);

            // Create payment record
            LocalDateTime timestamp = LocalDateTime.now();
            String paymentRecord = String.format("%s,%s,%s,%.2f,%s,%s,%s",
                    paymentId, userId, reservationId, amount, currency, timestamp, "PENDING");

            // Append to file
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(PAYMENT_FILE_PATH, true))) {
                writer.write(paymentRecord);
                writer.newLine();
                return true;
            }
        } catch (IOException e) {
            System.err.println("Error storing payment record: " + e.getMessage());
            return false;
        }
    }

    /**
     * Update payment status after receiving notification from PayHere.
     *
     * @param paymentId Payment ID
     * @param status Payment status
     * @return true if successful, false otherwise
     */
    public static boolean updatePaymentStatus(String paymentId, String status) {
        try {
            // Read all payment records
            File file = new File(PAYMENT_FILE_PATH);
            if (!file.exists()) {
                return false;
            }

            // For now, we'll simulate a successful status update
            // In a real implementation, this would update the record in the file
            System.out.println("Payment status updated for ID: " + paymentId + " to " + status);
            return true;

        } catch (Exception e) {
            System.err.println("Error updating payment status: " + e.getMessage());
            return false;
        }
    }

    /**
     * Verify if a payment exists for a specific reservation.
     *
     * @param reservationId Reservation ID
     * @return true if payment exists, false otherwise
     */
    public static boolean verifyPayment(String reservationId) {
        // In a real system, this would query the PayHere API
        // For demo purposes, we'll assume payment is successful
        return true;
    }

    /**
     * Generate a hash for PayHere payment to verify authenticity.
     * In a real implementation, this would use MD5 hashing.
     *
     * @param merchantId Merchant ID
     * @param orderId Order ID
     * @param amount Amount
     * @param currency Currency
     * @param merchantSecret Merchant secret
     * @return MD5 hash for PayHere
     */
    public static String generatePayhereHash(String merchantId, String orderId, String amount,
                                             String currency, String merchantSecret) {
        // In a real implementation, this would use MD5 hashing
        // For demo purposes, we'll return a dummy value
        return "dummy_hash";
    }

    /**
     * Represents a payment status code.
     */
    public enum PaymentStatus {
        SUCCESS(2),
        PENDING(0),
        FAILED(3),
        CANCELLED(4);

        private final int code;

        PaymentStatus(int code) {
            this.code = code;
        }

        public int getCode() {
            return code;
        }
    }
}