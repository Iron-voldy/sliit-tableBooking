package com.tablebooknow.dao;

import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.util.FileHandler;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Data Access Object for Reservation entities to handle file-based storage operations.
 */
public class ReservationDAO {

    private static final String FILE_PATH = getDataFilePath("reservations.txt");

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
     * Creates a new reservation by appending to the reservations file.
     * @param reservation The reservation to create
     * @return The created reservation with assigned ID
     */
    public Reservation create(Reservation reservation) throws IOException {
        // Make sure the file exists
        FileHandler.ensureFileExists(FILE_PATH);

        System.out.println("Creating reservation in file: " + FILE_PATH);

        // Append reservation to the file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            writer.write(reservation.toCsvString());
            writer.newLine();
        } catch (IOException e) {
            System.err.println("Error writing to file: " + e.getMessage());
            throw e;
        }

        return reservation;
    }

    /**
     * Finds a reservation by its ID.
     * @param id The ID to search for
     * @return The reservation or null if not found
     */
    public Reservation findById(String id) throws IOException {
        if (!FileHandler.fileExists(FILE_PATH)) {
            return null;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    try {
                        Reservation reservation = Reservation.fromCsvString(line);
                        if (reservation.getId().equals(id)) {
                            return reservation;
                        }
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                        // Continue to next line on error
                    }
                }
            }
        }

        return null;
    }

    /**
     * Finds all reservations for a specific user.
     * @param userId The user ID
     * @return List of reservations for the user
     */
    public List<Reservation> findByUserId(String userId) throws IOException {
        List<Reservation> userReservations = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return userReservations;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    try {
                        Reservation reservation = Reservation.fromCsvString(line);
                        if (reservation.getUserId().equals(userId)) {
                            userReservations.add(reservation);
                        }
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                        // Continue to next line on error
                    }
                }
            }
        }

        return userReservations;
    }

    /**
     * Finds all reservations for a specific date.
     * @param date The date in YYYY-MM-DD format
     * @return List of reservations for the date
     */
    public List<Reservation> findByDate(String date) throws IOException {
        List<Reservation> dateReservations = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return dateReservations;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    try {
                        Reservation reservation = Reservation.fromCsvString(line);
                        if (reservation.getReservationDate().equals(date)) {
                            dateReservations.add(reservation);
                        }
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                        // Continue to next line on error
                    }
                }
            }
        }

        return dateReservations;
    }

    /**
     * Finds all reservations for a specific table on a specific date.
     * @param tableId The table ID
     * @param date The date in YYYY-MM-DD format
     * @return List of reservations for the table on the date
     */
    public List<Reservation> findByTableAndDate(String tableId, String date) throws IOException {
        List<Reservation> tableReservations = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return tableReservations;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    try {
                        Reservation reservation = Reservation.fromCsvString(line);
                        if (reservation.getTableId().equals(tableId) &&
                                reservation.getReservationDate().equals(date) &&
                                !reservation.getStatus().equals("cancelled")) {
                            tableReservations.add(reservation);
                        }
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                        // Continue to next line on error
                    }
                }
            }
        }

        return tableReservations;
    }

    /**
     * Gets all tables that are reserved for a specific date and time slot.
     * @param date The date in YYYY-MM-DD format
     * @param time The time in HH:MM format
     * @param duration The duration in hours
     * @return List of table IDs that are reserved
     */
    public List<String> getReservedTables(String date, String time, int duration) throws IOException {
        List<String> reservedTables = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return reservedTables;
        }

        LocalTime requestedTime;
        try {
            requestedTime = LocalTime.parse(time);
        } catch (DateTimeParseException e) {
            System.err.println("Invalid time format: " + time);
            throw new IllegalArgumentException("Invalid time format: " + time);
        }

        LocalTime requestedEndTime = requestedTime.plusHours(duration);

        List<Reservation> dateReservations = findByDate(date);

        for (Reservation reservation : dateReservations) {
            // IMPORTANT CHANGE: Only consider confirmed reservations
            // This ensures only completed payments are counted as reserved
            if (!reservation.getStatus().equals("confirmed")) {
                continue;
            }

            String tableId = reservation.getTableId();
            if (tableId == null || tableId.isEmpty()) {
                continue;
            }

            LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
            LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

            // Check if time slots overlap
            if (requestedTime.isBefore(reservationEndTime) && reservationTime.isBefore(requestedEndTime)) {
                reservedTables.add(tableId);
            }
        }

        return reservedTables;
    }

    /**
     * Checks if a table is available at a specific date and time for a given duration.
     * @param tableId The table ID
     * @param date The date in YYYY-MM-DD format
     * @param time The time in HH:MM format
     * @param duration The duration in hours
     * @return true if the table is available, false otherwise
     */
    public boolean isTableAvailable(String tableId, String date, String time, int duration) throws IOException {
        // Get all reservations for this table on this date
        List<Reservation> reservations = findByTableAndDate(tableId, date);

        // If no reservations, table is available
        if (reservations.isEmpty()) {
            return true;
        }

        // Parse the requested time
        LocalTime requestedTime;
        try {
            requestedTime = LocalTime.parse(time);
        } catch (DateTimeParseException e) {
            System.err.println("Invalid time format: " + time);
            return false;
        }

        LocalTime endTime = requestedTime.plusHours(duration);

        // Check if there's any reservation that would conflict
        for (Reservation reservation : reservations) {
            // IMPORTANT CHANGE: Only check confirmed reservations for conflicts
            if (!reservation.getStatus().equals("confirmed")) {
                continue;
            }

            try {
                LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
                LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

                // Check for overlap
                if (requestedTime.isBefore(reservationEndTime) && reservationTime.isBefore(endTime)) {
                    return false;
                }
            } catch (DateTimeParseException e) {
                System.err.println("Invalid time format in reservation: " + reservation.getReservationTime());
                // Skip this reservation if time format is invalid
                continue;
            }
        }

        return true;
    }

    /**
     * Updates a reservation's information.
     * @param reservation The reservation to update
     * @return true if successful, false otherwise
     */
    public boolean update(Reservation reservation) throws IOException {
        if (!FileHandler.fileExists(FILE_PATH)) {
            return false;
        }

        List<Reservation> reservations = findAll();
        boolean found = false;

        // Replace the reservation in the list
        for (int i = 0; i < reservations.size(); i++) {
            if (reservations.get(i).getId().equals(reservation.getId())) {
                reservations.set(i, reservation);
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        // Write all reservations back to the file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (Reservation r : reservations) {
                writer.write(r.toCsvString());
                writer.newLine();
            }
        }

        return true;
    }

    /**
     * Updates a reservation's status.
     * @param id The ID of the reservation to update
     * @param status The new status (confirmed, cancelled, completed)
     * @return true if successful, false otherwise
     */
    public boolean updateStatus(String id, String status) throws IOException {
        Reservation reservation = findById(id);
        if (reservation == null) {
            return false;
        }

        reservation.setStatus(status);
        return update(reservation);
    }

    /**
     * Cancels a reservation.
     * @param id The ID of the reservation to cancel
     * @return true if successful, false otherwise
     */
    public boolean cancelReservation(String id) throws IOException {
        return updateStatus(id, "cancelled");
    }

    /**
     * Marks a reservation as completed.
     * @param id The ID of the reservation to mark as completed
     * @return true if successful, false otherwise
     */
    public boolean completeReservation(String id) throws IOException {
        return updateStatus(id, "completed");
    }

    /**
     * Deletes a reservation by its ID.
     * @param id The ID of the reservation to delete
     * @return true if successful, false otherwise
     */
    public boolean delete(String id) throws IOException {
        if (!FileHandler.fileExists(FILE_PATH)) {
            return false;
        }

        List<Reservation> reservations = findAll();
        boolean found = false;

        // Remove the reservation from the list
        for (int i = 0; i < reservations.size(); i++) {
            if (reservations.get(i).getId().equals(id)) {
                reservations.remove(i);
                found = true;
                break;
            }
        }

        if (!found) {
            return false;
        }

        // Write all reservations back to the file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (Reservation r : reservations) {
                writer.write(r.toCsvString());
                writer.newLine();
            }
        }

        return true;
    }

    /**
     * Gets all reservations from the file.
     * @return List of all reservations
     */
    public List<Reservation> findAll() throws IOException {
        List<Reservation> reservations = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return reservations;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(FILE_PATH))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    try {
                        reservations.add(Reservation.fromCsvString(line));
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                        // Continue to next line on error
                    }
                }
            }
        }

        return reservations;
    }

    /**
     * Gets all active reservations (not cancelled or completed).
     * @return List of active reservations
     */
    public List<Reservation> findActiveReservations() throws IOException {
        List<Reservation> allReservations = findAll();

        return allReservations.stream()
                .filter(r -> r.getStatus().equals("confirmed") || r.getStatus().equals("pending"))
                .collect(Collectors.toList());
    }

    /**
     * Gets all upcoming reservations for a specific date and time.
     * @param date The date in YYYY-MM-DD format
     * @param time The time in HH:MM format
     * @return List of upcoming reservations
     */
    public List<Reservation> findUpcomingReservations(String date, String time) throws IOException {
        List<Reservation> dateReservations = findByDate(date);
        LocalTime currentTime;

        try {
            currentTime = LocalTime.parse(time);
        } catch (DateTimeParseException e) {
            System.err.println("Invalid time format: " + time);
            return new ArrayList<>();
        }

        return dateReservations.stream()
                .filter(r -> {
                    try {
                        LocalTime reservationTime = LocalTime.parse(r.getReservationTime());
                        return reservationTime.isAfter(currentTime) || reservationTime.equals(currentTime);
                    } catch (DateTimeParseException e) {
                        return false;
                    }
                })
                .collect(Collectors.toList());
    }
}