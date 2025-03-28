package com.tablebooknow.model.table;

import java.io.Serializable;
import java.util.UUID;

/**
 * Represents a restaurant table in the system.
 */
public class Table implements Serializable {
    private String id;
    private String tableNumber;
    private String tableType;  // family, luxury, regular, couple
    private int capacity;
    private int floor;
    private String locationDescription;
    private boolean active;

    /**
     * Default constructor
     */
    public Table() {
        this.id = UUID.randomUUID().toString();
        this.active = true;  // Tables are active by default
    }

    /**
     * Constructor with all fields except ID (generates new ID)
     */
    public Table(String tableNumber, String tableType, int capacity, int floor, String locationDescription, boolean active) {
        this.id = UUID.randomUUID().toString();
        this.tableNumber = tableNumber;
        this.tableType = tableType;
        this.capacity = capacity;
        this.floor = floor;
        this.locationDescription = locationDescription;
        this.active = active;
    }

    /**
     * Constructor with all fields
     */
    public Table(String id, String tableNumber, String tableType, int capacity,
                 int floor, String locationDescription, boolean active) {
        this.id = id;
        this.tableNumber = tableNumber;
        this.tableType = tableType;
        this.capacity = capacity;
        this.floor = floor;
        this.locationDescription = locationDescription;
        this.active = active;
    }

    // Getters and Setters

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    public String getTableType() {
        return tableType;
    }

    public void setTableType(String tableType) {
        this.tableType = tableType;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getFloor() {
        return floor;
    }

    public void setFloor(int floor) {
        this.floor = floor;
    }

    public String getLocationDescription() {
        return locationDescription;
    }

    public void setLocationDescription(String locationDescription) {
        this.locationDescription = locationDescription;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    /**
     * Gets the table's display name based on its type and number
     */
    public String getDisplayName() {
        if (tableType == null || tableNumber == null) {
            return "Unknown Table";
        }

        String typeLabel;

        switch (tableType.toLowerCase()) {
            case "family":
                typeLabel = "Family";
                break;
            case "luxury":
                typeLabel = "Luxury";
                break;
            case "couple":
                typeLabel = "Couple";
                break;
            case "regular":
                typeLabel = "Regular";
                break;
            default:
                typeLabel = "Table";
        }

        return typeLabel + " Table " + tableNumber;
    }

    /**
     * Generate a table ID based on the type and number
     * Format: f1-3 (for family table floor 1, number 3)
     */
    public String generateSystemId() {
        if (tableType == null || tableNumber == null) {
            return id;
        }

        String prefix;
        switch (tableType.toLowerCase()) {
            case "family":
                prefix = "f";
                break;
            case "luxury":
                prefix = "l";
                break;
            case "couple":
                prefix = "c";
                break;
            case "regular":
                prefix = "r";
                break;
            default:
                prefix = "t";
        }

        return prefix + floor + "-" + tableNumber;
    }

    /**
     * Converts the Table object to a CSV format string for file storage.
     * Format: id,tableNumber,tableType,capacity,floor,locationDescription,active
     */
    public String toCsvString() {
        return String.format("%s,%s,%s,%d,%d,%s,%b",
                id,
                tableNumber != null ? tableNumber : "",
                tableType != null ? tableType : "",
                capacity,
                floor,
                locationDescription != null ? locationDescription.replace(",", ";;") : "",
                active);
    }

    /**
     * Creates a Table object from a CSV format string.
     */
    public static Table fromCsvString(String csvLine) {
        if (csvLine == null || csvLine.trim().isEmpty()) {
            throw new IllegalArgumentException("Empty or null CSV line");
        }

        String[] parts = csvLine.split(",");
        if (parts.length < 7) {
            throw new IllegalArgumentException("Invalid CSV format for Table: " + csvLine);
        }

        // Parse capacity and floor
        int capacity = 0;
        int floor = 0;
        try {
            capacity = Integer.parseInt(parts[3]);
            floor = Integer.parseInt(parts[4]);
        } catch (NumberFormatException e) {
            // Use default values if parsing fails
        }

        // Restore commas in description
        String locationDescription = parts[5].replace(";;", ",");

        // Parse active status
        boolean active = Boolean.parseBoolean(parts[6]);

        return new Table(
                parts[0],                  // id
                parts[1],                  // tableNumber
                parts[2],                  // tableType
                capacity,                  // capacity
                floor,                     // floor
                locationDescription,       // locationDescription
                active                     // active
        );
    }

    @Override
    public String toString() {
        return "Table{" +
                "id='" + id + '\'' +
                ", tableNumber='" + tableNumber + '\'' +
                ", tableType='" + tableType + '\'' +
                ", capacity=" + capacity +
                ", floor=" + floor +
                ", active=" + active +
                '}';
    }
}