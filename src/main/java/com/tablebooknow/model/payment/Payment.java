package com.tablebooknow.model.payment;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Model class for storing payment information
 */
public class Payment implements Serializable {
    private String id;
    private String reservationId;
    private String userId;
    private BigDecimal amount;
    private String currency;
    private String status; // PENDING, COMPLETED, FAILED, REFUNDED
    private String paymentMethod;
    private String transactionId; // ID from payment gateway
    private String paymentGateway; // PayHere, etc.
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    /**
     * Default constructor that generates a unique ID for a new payment.
     */
    public Payment() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = LocalDateTime.now();
        this.status = "PENDING";
        this.currency = "LKR"; // Default currency for Sri Lanka
    }

    /**
     * Constructor with all fields.
     */
    public Payment(String id, String reservationId, String userId, BigDecimal amount,
                   String currency, String status, String paymentMethod,
                   String transactionId, String paymentGateway,
                   LocalDateTime createdAt, LocalDateTime completedAt) {
        this.id = id;
        this.reservationId = reservationId;
        this.userId = userId;
        this.amount = amount;
        this.currency = currency;
        this.status = status;
        this.paymentMethod = paymentMethod;
        this.transactionId = transactionId;
        this.paymentGateway = paymentGateway;
        this.createdAt = createdAt;
        this.completedAt = completedAt;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getReservationId() {
        return reservationId;
    }

    public void setReservationId(String reservationId) {
        this.reservationId = reservationId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getPaymentGateway() {
        return paymentGateway;
    }

    public void setPaymentGateway(String paymentGateway) {
        this.paymentGateway = paymentGateway;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    /**
     * Converts the Payment object to a CSV format string for file storage.
     * Format: id,reservationId,userId,amount,currency,status,paymentMethod,transactionId,paymentGateway,createdAt,completedAt
     */
    public String toCsvString() {
        return String.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
                id,
                reservationId != null ? reservationId : "",
                userId != null ? userId : "",
                amount != null ? amount.toString() : "",
                currency != null ? currency : "",
                status != null ? status : "",
                paymentMethod != null ? paymentMethod : "",
                transactionId != null ? transactionId : "",
                paymentGateway != null ? paymentGateway : "",
                createdAt != null ? createdAt.toString() : "",
                completedAt != null ? completedAt.toString() : "");
    }

    /**
     * Creates a Payment object from a CSV format string.
     */
    public static Payment fromCsvString(String csvLine) {
        String[] parts = csvLine.split(",");
        if (parts.length < 11) {
            throw new IllegalArgumentException("Invalid CSV format for Payment");
        }

        BigDecimal amount = null;
        if (parts[3] != null && !parts[3].isEmpty()) {
            try {
                amount = new BigDecimal(parts[3]);
            } catch (NumberFormatException e) {
                // Keep as null if not parseable
            }
        }

        LocalDateTime createdAt = null;
        if (parts[9] != null && !parts[9].isEmpty()) {
            try {
                createdAt = LocalDateTime.parse(parts[9]);
            } catch (Exception e) {
                // Keep as null if not parseable
            }
        }

        LocalDateTime completedAt = null;
        if (parts[10] != null && !parts[10].isEmpty()) {
            try {
                completedAt = LocalDateTime.parse(parts[10]);
            } catch (Exception e) {
                // Keep as null if not parseable
            }
        }

        return new Payment(
                parts[0],                  // id
                parts[1],                  // reservationId
                parts[2],                  // userId
                amount,                    // amount
                parts[4],                  // currency
                parts[5],                  // status
                parts[6],                  // paymentMethod
                parts[7],                  // transactionId
                parts[8],                  // paymentGateway
                createdAt,                 // createdAt
                completedAt                // completedAt
        );
    }

    @Override
    public String toString() {
        return "Payment{" +
                "id='" + id + '\'' +
                ", reservationId='" + reservationId + '\'' +
                ", userId='" + userId + '\'' +
                ", amount=" + amount +
                ", currency='" + currency + '\'' +
                ", status='" + status + '\'' +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", transactionId='" + transactionId + '\'' +
                ", paymentGateway='" + paymentGateway + '\'' +
                ", createdAt=" + createdAt +
                ", completedAt=" + completedAt +
                '}';
    }
}