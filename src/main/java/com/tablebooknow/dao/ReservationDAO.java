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
import java.time.format.DateTimeFormatter;
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

        // Append reservation to the file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            writer.write(reservation.toCsvString());
            writer.newLine();
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
     * Find reservations by user ID.
     * @param userId The user ID to search for
     * @return List of reservations for the specified user
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
                    }
                }
            }
        }

        return userReservations;
    }

    /**
     * Find reservations by table ID.
     * @param tableId The table ID to search for
     * @return List of reservations for the specified table
     */
    public List<Reservation> findByTableId(String tableId) throws IOException {
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
                        if (tableId.equals(reservation.getTableId())) {
                            tableReservations.add(reservation);
                        }
                    } catch (Exception e) {
                        System.err.println("Error parsing reservation line: " + line);
                    }
                }
            }
        }

        return tableReservations;
    }

    /**
     * Finds upcoming reservations (today and future).
     * @param currentDate The current date string (YYYY-MM-DD)
     * @param currentTime The current time string (HH:MM)
     * @return List of upcoming reservations
     */
    public List<Reservation> findUpcomingReservations(String currentDate, String currentTime) throws IOException {
        List<Reservation> upcomingReservations = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return upcomingReservations;
        }

        try {
            LocalDate today = LocalDate.parse(currentDate);
            LocalTime now = LocalTime.parse(currentTime);

            List<Reservation> allReservations = findAll();

            for (Reservation reservation : allReservations) {
                try {
                    LocalDate reservationDate = LocalDate.parse(reservation.getReservationDate());
                    LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());

                    // Include if date is in the future or if it's today and time is in the future
                    if (reservationDate.isAfter(today) ||
                            (reservationDate.isEqual(today) && reservationTime.isAfter(now))) {
                        upcomingReservations.add(reservation);
                    }
                } catch (Exception e) {
                    System.err.println("Error parsing date/time for reservation: " + reservation.getId());
                }
            }
        } catch (Exception e) {
            System.err.println("Error finding upcoming reservations: " + e.getMessage());
        }

        return upcomingReservations;
    }

    /**
     * Get a list of tables that are reserved for a specific date and time.
     * This method checks for any reservations that would conflict with the given time slot.
     *
     * @param date The date to check
     * @param time The starting time to check
     * @param duration The duration in hours
     * @return A list of table IDs that are reserved during the specified time slot
     * @throws IOException If there's an error reading the reservation file
     */
    public List<String> getReservedTables(String date, String time, int duration) throws IOException {
        List<String> reservedTables = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return reservedTables;
        }

        try {
            // Parse the requested time
            LocalTime requestedTime = LocalTime.parse(time);
            LocalTime requestedEndTime = requestedTime.plusHours(duration);

            // Get all reservations for the date
            List<Reservation> allReservations = findAll();

            // Filter reservations for the specified date with confirmed or pending status
            List<Reservation> dateReservations = allReservations.stream()
                    .filter(r -> date.equals(r.getReservationDate()) &&
                            (r.getStatus().equals("confirmed") || r.getStatus().equals("pending")))
                    .collect(Collectors.toList());

            // Check each reservation for time conflict
            for (Reservation reservation : dateReservations) {
                if (reservation.getTableId() == null || reservation.getTableId().isEmpty()) {
                    continue;
                }

                LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
                LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

                // Check if the time slots overlap
                if (reservationTime.isBefore(requestedEndTime) &&
                        requestedTime.isBefore(reservationEndTime)) {
                    // Table is reserved during requested time slot
                    reservedTables.add(reservation.getTableId());
                }
            }
        } catch (Exception e) {
            System.err.println("Error finding reserved tables: " + e.getMessage());
            e.printStackTrace();
        }

        return reservedTables;
    }

    /**
     * Check if a table is available at a specific date and time.
     *
     * @param tableId The table ID to check
     * @param date The date to check
     * @param time The starting time to check
     * @param duration The duration in hours
     * @return true if the table is available, false otherwise
     * @throws IOException If there's an error reading the reservation file
     */
    public boolean isTableAvailable(String tableId, String date, String time, int duration) throws IOException {
        if (!FileHandler.fileExists(FILE_PATH)) {
            // If the file doesn't exist, no reservations exist, so the table is available
            return true;
        }

        try {
            // Parse the requested time
            LocalTime requestedTime = LocalTime.parse(time);
            LocalTime requestedEndTime = requestedTime.plusHours(duration);

            // Get all reservations for the specified table and date
            List<Reservation> tableReservations = findAll().stream()
                    .filter(r -> tableId.equals(r.getTableId()) &&
                            date.equals(r.getReservationDate()) &&
                            (r.getStatus().equals("confirmed") || r.getStatus().equals("pending")))
                    .collect(Collectors.toList());

            // Check for time conflicts
            for (Reservation reservation : tableReservations) {
                LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
                LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

                // Check if the time slots overlap
                if (reservationTime.isBefore(requestedEndTime) &&
                        requestedTime.isBefore(reservationEndTime)) {
                    // Time conflict, table is not available
                    return false;
                }
            }

            // No conflicts found, table is available
            return true;
        } catch (Exception e) {
            System.err.println("Error checking table availability: " + e.getMessage());
            e.printStackTrace();
            // If an error occurs, conservatively return false (not available)
            return false;
        }
    }
    
    /**
     * Find reserved tables for a specific date and time.
     * @param date The reservation date
     * @param time The reservation time
     * @param duration The reservation duration in hours
     * @return List of table IDs that are reserved during the specified time slot
     */
    public List<String> findReservedTables(String date, String time, int duration) throws IOException {
        List<String> reservedTables = new ArrayList<>();

        if (!FileHandler.fileExists(FILE_PATH)) {
            return reservedTables;
        }

        try {
            // Parse the requested time
            LocalTime requestedTime = LocalTime.parse(time);
            LocalTime requestedEndTime = requestedTime.plusHours(duration);

            List<Reservation> dateReservations = findAll().stream()
                    .filter(r -> date.equals(r.getReservationDate()) &&
                            (r.getStatus().equals("confirmed") || r.getStatus().equals("pending")))
                    .collect(Collectors.toList());

            for (Reservation reservation : dateReservations) {
                if (reservation.getTableId() == null || reservation.getTableId().isEmpty()) {
                    continue;
                }

                LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
                LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

                // Check if the time slots overlap
                if (reservationTime.isBefore(requestedEndTime) &&
                        requestedTime.isBefore(reservationEndTime)) {
                    reservedTables.add(reservation.getTableId());
                }
            }
        } catch (Exception e) {
            System.err.println("Error finding reserved tables: " + e.getMessage());
        }

        return reservedTables;
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
     * Cancel a reservation (change status to "cancelled").
     * @param id The ID of the reservation to cancel
     * @return true if successfully cancelled, false otherwise
     */
    public boolean cancelReservation(String id) throws IOException {
        Reservation reservation = findById(id);
        if (reservation == null) {
            return false;
        }

        reservation.setStatus("cancelled");
        return update(reservation);
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
}