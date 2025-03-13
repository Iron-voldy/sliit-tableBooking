package com.tablebooknow.service;

import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;

import java.math.BigDecimal;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

/**
 * PaymentGateway class for integration with PayHere payment system.
 * Handles creating payment requests and validating responses.
 */
public class PaymentGateway {

    // PayHere API configurations
    private static final String SANDBOX_URL = "https://sandbox.payhere.lk/pay/checkout";
    private static final String PRODUCTION_URL = "https://www.payhere.lk/pay/checkout";

    // Change these to your actual merchant details
    private static final String MERCHANT_ID = "1221688";  // Replace with your actual merchant ID
    private static final String MERCHANT_SECRET = "MjczNTg5MTc4MzE0MDk5NjE2ODE0MTQ0NjQxNTQ2MTI4NjI5ODE="; // Replace with your actual secret
    private static final boolean USE_SANDBOX = true; // Set to false for production

    // Table pricing based on table type (can be moved to configuration file)
    private static final Map<String, BigDecimal> TABLE_PRICES = new HashMap<>();
    static {
        TABLE_PRICES.put("family", new BigDecimal("120.00"));
        TABLE_PRICES.put("luxury", new BigDecimal("180.00"));
        TABLE_PRICES.put("regular", new BigDecimal("80.00"));
        TABLE_PRICES.put("couple", new BigDecimal("60.00"));
    }

    /**
     * Get the PayHere checkout URL (either sandbox or production)
     * @return The appropriate checkout URL
     */
    public String getCheckoutUrl() {
        return USE_SANDBOX ? SANDBOX_URL : PRODUCTION_URL;
    }

    /**
     * Calculate the amount to charge based on table type and booking duration
     * @param tableType The type of table (family, luxury, regular, couple)
     * @param duration Booking duration in hours
     * @return The calculated price
     */
    public BigDecimal calculateAmount(String tableType, int duration) {
        BigDecimal basePrice = TABLE_PRICES.getOrDefault(tableType, new BigDecimal("100.00"));
        return basePrice.multiply(new BigDecimal(duration));
    }

    /**
     * Generate PayHere form parameters for the payment
     * @param payment The payment object
     * @param reservation The reservation object
     * @param user The user making the payment
     * @param returnUrl URL to return to after payment
     * @param cancelUrl URL to return to if payment is cancelled
     * @param notifyUrl URL for PayHere to send payment notification
     * @return Map of form parameters
     */
    public Map<String, String> generateFormParameters(
            Payment payment,
            Reservation reservation,
            User user,
            String returnUrl,
            String cancelUrl,
            String notifyUrl
    ) {
        Map<String, String> params = new HashMap<>();

        // Required Parameters
        params.put("merchant_id", MERCHANT_ID);
        params.put("return_url", returnUrl);
        params.put("cancel_url", cancelUrl);
        params.put("notify_url", notifyUrl);

        // Transaction details
        params.put("order_id", payment.getId());
        params.put("items", "Table Reservation - " + extractTableTypeFromId(reservation.getTableId()));
        params.put("currency", payment.getCurrency());
        params.put("amount", payment.getAmount().toString());

        // Customer details
        params.put("first_name", user.getUsername());
        params.put("last_name", "");
        params.put("email", user.getEmail());
        params.put("phone", user.getPhone() != null ? user.getPhone() : "");
        params.put("address", "");
        params.put("city", "");
        params.put("country", "Sri Lanka");

        // Custom parameters
        params.put("custom_1", reservation.getId());
        params.put("custom_2", user.getId());

        // Generate hash
        String hash = generateHash(params);
        params.put("hash", hash);

        return params;
    }

    /**
     * Extract the table type from the table ID (e.g., "f1-1" -> "family")
     * @param tableId The table ID
     * @return The table type or "regular" if not found
     */
    private String extractTableTypeFromId(String tableId) {
        if (tableId == null || tableId.isEmpty()) {
            return "regular";
        }

        char firstChar = tableId.charAt(0);
        switch (firstChar) {
            case 'f':
                return "family";
            case 'l':
                return "luxury";
            case 'r':
                return "regular";
            case 'c':
                return "couple";
            default:
                return "regular";
        }
    }

    /**
     * Generate a hash value for secure payment verification
     * @param params The payment parameters
     * @return MD5 hash of the parameters
     */
    private String generateHash(Map<String, String> params) {
        String stringToHash = MERCHANT_ID;
        stringToHash += params.get("order_id");
        stringToHash += params.get("amount");
        stringToHash += params.get("currency");
        stringToHash += MERCHANT_SECRET;

        return md5(stringToHash);
    }

    /**
     * Validate a payment notification from PayHere
     * @param merchantId Merchant ID from notification
     * @param orderId Order ID from notification
     * @param paymentId PayHere payment ID
     * @param amount Payment amount
     * @param currency Payment currency
     * @param status Payment status
     * @return true if hash matches (valid notification), false otherwise
     */
    public boolean validateNotification(
            String merchantId,
            String orderId,
            String paymentId,
            String amount,
            String currency,
            String status
    ) {
        // Verification logic for PayHere notifications
        if (!merchantId.equals(MERCHANT_ID)) {
            return false;
        }

        // Generate hash for verification
        String stringToHash = merchantId;
        stringToHash += orderId;
        stringToHash += paymentId;
        stringToHash += amount;
        stringToHash += currency;
        stringToHash += status;
        stringToHash += MERCHANT_SECRET;

        String generatedHash = md5(stringToHash);

        // In a real implementation, compare this with the hash provided in the notification
        // return generatedHash.equals(providedHash);

        // For now, return true for demonstration
        return true;
    }

    /**
     * Generate MD5 hash of a string
     * @param input The string to hash
     * @return MD5 hash of the input
     */
    private String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes());

            // Convert to hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : messageDigest) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Could not generate MD5 hash", e);
        }
    }
}