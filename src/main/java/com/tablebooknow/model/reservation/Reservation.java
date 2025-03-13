package com.tablebooknow.model.reservation;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Represents a table reservation in the system.
 */
public class Reservation implements Serializable {
    private String id;
    private String userId;
    private String tableId;
    private String reservationDate;
    private String reservationTime;
    private int duration;  // in hours
    private String bookingType;  // "normal" or "special"
    private String specialRequests;
    private String status;  // confirmed, cancelled, completed
    private LocalDateTime createdAt;

    /**
     * Default constructor that generates a unique ID for a new reservation.
     */
    public Reservation() {
        this.id = UUID.randomUUID().toString();
        this.createdAt = LocalDateTime.now();
        this.status = "pending";
        this.duration = 2;  // Default duration is 2 hours
        this.bookingType = "normal";  // Default booking type is normal
    }

    /**
     * Constructor with all fields.
     */
    public Reservation(String id, String userId, String tableId, String reservationDate,
                       String reservationTime, int duration, String bookingType,
                       String specialRequests, String status, LocalDateTime createdAt) {
        this.id = id;
        this.userId = userId;
        this.tableId = tableId;
        this.reservationDate = reservationDate;
        this.reservationTime = reservationTime;
        this.duration = duration;
        this.bookingType = bookingType;
        this.specialRequests = specialRequests;
        this.status = status;
        this.createdAt = createdAt != null ? createdAt : LocalDateTime.now();
    }

    // Getters and Setters

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getTableId() {
        return tableId;
    }

    public void setTableId(String tableId) {
        this.tableId = tableId;
    }

    public String getReservationDate() {
        return reservationDate;
    }

    public void setReservationDate(String reservationDate) {
        this.reservationDate = reservationDate;
    }

    public String getReservationTime() {
        return reservationTime;
    }

    public void setReservationTime(String reservationTime) {
        this.reservationTime = reservationTime;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getBookingType() {
        return bookingType;
    }

    public void setBookingType(String bookingType) {
        this.bookingType = bookingType;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Converts the Reservation object to a CSV format string for file storage.
     * Format: id,userId,tableId,reservationDate,reservationTime,duration,bookingType,specialRequests,status,createdAt
     */
    public String toCsvString() {
        return String.format("%s,%s,%s,%s,%s,%d,%s,%s,%s,%s",
                id,
                userId != null ? userId : "",
                tableId != null ? tableId : "",
                reservationDate != null ? reservationDate : "",
                reservationTime != null ? reservationTime : "",
                duration,
                bookingType != null ? bookingType : "normal",
                specialRequests != null ? specialRequests.replace(",", ";;") : "",  // Replace commas in special requests
                status != null ? status : "",
                createdAt != null ? createdAt.toString() : LocalDateTime.now().toString());
    }

    /**
     * Creates a Reservation object from a CSV format string.
     */
    public static Reservation fromCsvString(String csvLine) {
        String[] parts = csvLine.split(",");
        if (parts.length < 10) {
            throw new IllegalArgumentException("Invalid CSV format for Reservation");
        }

        LocalDateTime createdAt = null;
        try {
            if (!parts[9].isEmpty()) {
                createdAt = LocalDateTime.parse(parts[9]);
            }
        } catch (Exception e) {
            createdAt = LocalDateTime.now();
        }

        // Convert duration from string to int
        int duration = 2;  // Default
        try {
            duration = Integer.parseInt(parts[5]);
        } catch (NumberFormatException e) {
            // Keep default
        }

        // Restore commas in special requests
        String specialRequests = parts[7].replace(";;", ",");

        return new Reservation(
                parts[0],                  // id
                parts[1],                  // userId
                parts[2],                  // tableId
                parts[3],                  // reservationDate
                parts[4],                  // reservationTime
                duration,                  // duration
                parts[6],                  // bookingType
                specialRequests,           // specialRequests
                parts[8],                  // status
                createdAt                  // createdAt
        );
    }

    @Override
    public String toString() {
        return "Reservation{" +
                "id='" + id + '\'' +
                ", userId='" + userId + '\'' +
                ", tableId='" + tableId + '\'' +
                ", reservationDate='" + reservationDate + '\'' +
                ", reservationTime='" + reservationTime + '\'' +
                ", duration=" + duration +
                ", bookingType='" + bookingType + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}