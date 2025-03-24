package com.tablebooknow.util;

import com.tablebooknow.model.reservation.Reservation;

import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Queue implementation for managing reservation requests.
 * This implementation uses the FIFO (First In, First Out) principle
 * but can also be sorted by time for priority handling.
 */
public class ReservationQueue {
    private List<Reservation> queue;

    /**
     * Constructor to initialize an empty queue.
     */
    public ReservationQueue() {
        this.queue = new ArrayList<>();
    }

    /**
     * Constructor with initial list of reservations.
     *
     * @param initialReservations List of reservations to initialize the queue with
     */
    public ReservationQueue(List<Reservation> initialReservations) {
        this.queue = new ArrayList<>(initialReservations);
    }

    /**
     * Adds a reservation to the end of the queue.
     *
     * @param reservation The reservation to add
     */
    public void enqueue(Reservation reservation) {
        queue.add(reservation);
    }

    /**
     * Removes and returns the reservation at the front of the queue.
     *
     * @return The reservation at the front of the queue, or null if the queue is empty
     */
    public Reservation dequeue() {
        if (isEmpty()) {
            return null;
        }
        return queue.remove(0);
    }

    /**
     * Returns the reservation at the front of the queue without removing it.
     *
     * @return The reservation at the front of the queue, or null if the queue is empty
     */
    public Reservation peek() {
        if (isEmpty()) {
            return null;
        }
        return queue.get(0);
    }

    /**
     * Checks if the queue is empty.
     *
     * @return true if the queue is empty, false otherwise
     */
    public boolean isEmpty() {
        return queue.isEmpty();
    }

    /**
     * Returns the number of reservations in the queue.
     *
     * @return The number of reservations in the queue
     */
    public int size() {
        return queue.size();
    }

    /**
     * Returns a list of all reservations in the queue.
     *
     * @return A list of all reservations in the queue
     */
    public List<Reservation> getAllReservations() {
        return new ArrayList<>(queue);
    }

    /**
     * Clears all reservations from the queue.
     */
    public void clear() {
        queue.clear();
    }

    /**
     * Sorts the reservations in the queue by their reservation time.
     * Uses merge sort algorithm for sorting.
     *
     * @return A new ReservationQueue with sorted reservations
     */
    public ReservationQueue sortByTime() {
        if (queue.size() <= 1) {
            return this;
        }

        List<Reservation> sorted = mergeSort(queue);
        return new ReservationQueue(sorted);
    }

    /**
     * Implementation of merge sort algorithm for sorting reservations by time.
     *
     * @param reservations The list of reservations to sort
     * @return A new sorted list of reservations
     */
    private List<Reservation> mergeSort(List<Reservation> reservations) {
        if (reservations.size() <= 1) {
            return new ArrayList<>(reservations);
        }

        int mid = reservations.size() / 2;
        List<Reservation> left = new ArrayList<>(reservations.subList(0, mid));
        List<Reservation> right = new ArrayList<>(reservations.subList(mid, reservations.size()));

        left = mergeSort(left);
        right = mergeSort(right);

        return merge(left, right);
    }

    /**
     * Merges two sorted lists of reservations.
     *
     * @param left The left sorted list
     * @param right The right sorted list
     * @return A merged sorted list
     */
    private List<Reservation> merge(List<Reservation> left, List<Reservation> right) {
        List<Reservation> result = new ArrayList<>();
        int leftIndex = 0;
        int rightIndex = 0;

        while (leftIndex < left.size() && rightIndex < right.size()) {
            try {
                Reservation leftRes = left.get(leftIndex);
                Reservation rightRes = right.get(rightIndex);

                // First compare by date
                int dateCompare = leftRes.getReservationDate().compareTo(rightRes.getReservationDate());

                if (dateCompare < 0) {
                    // Left date is earlier
                    result.add(leftRes);
                    leftIndex++;
                } else if (dateCompare > 0) {
                    // Right date is earlier
                    result.add(rightRes);
                    rightIndex++;
                } else {
                    // Same date, compare times
                    try {
                        LocalTime leftTime = LocalTime.parse(leftRes.getReservationTime());
                        LocalTime rightTime = LocalTime.parse(rightRes.getReservationTime());

                        if (leftTime.isBefore(rightTime)) {
                            result.add(leftRes);
                            leftIndex++;
                        } else {
                            result.add(rightRes);
                            rightIndex++;
                        }
                    } catch (DateTimeParseException e) {
                        // If time parsing fails, use string comparison as fallback
                        int timeCompare = leftRes.getReservationTime().compareTo(rightRes.getReservationTime());
                        if (timeCompare <= 0) {
                            result.add(leftRes);
                            leftIndex++;
                        } else {
                            result.add(rightRes);
                            rightIndex++;
                        }
                    }
                }
            } catch (Exception e) {
                // In case of any error, add remaining elements from both lists
                break;
            }
        }

        // Add any remaining elements
        while (leftIndex < left.size()) {
            result.add(left.get(leftIndex));
            leftIndex++;
        }

        while (rightIndex < right.size()) {
            result.add(right.get(rightIndex));
            rightIndex++;
        }

        return result;
    }

    /**
     * Find reservations for a specific table and date.
     *
     * @param tableId The table ID to search for
     * @param date The date in YYYY-MM-DD format
     * @return A list of reservations for the specified table and date
     */
    public List<Reservation> findByTableAndDate(String tableId, String date) {
        List<Reservation> result = new ArrayList<>();

        for (Reservation reservation : queue) {
            if (reservation.getTableId() != null &&
                    reservation.getTableId().equals(tableId) &&
                    reservation.getReservationDate() != null &&
                    reservation.getReservationDate().equals(date) &&
                    !reservation.getStatus().equals("cancelled")) {

                result.add(reservation);
            }
        }

        return result;
    }

    /**
     * Check if a table is available at a specific date and time.
     *
     * @param tableId The table ID to check
     * @param date The date in YYYY-MM-DD format
     * @param time The time in HH:MM format
     * @param duration The duration in hours
     * @return true if the table is available, false otherwise
     */
    public boolean isTableAvailable(String tableId, String date, String time, int duration) {
        List<Reservation> tableReservations = findByTableAndDate(tableId, date);

        if (tableReservations.isEmpty()) {
            return true;
        }

        try {
            LocalTime requestedTime = LocalTime.parse(time);
            LocalTime requestedEndTime = requestedTime.plusHours(duration);

            for (Reservation reservation : tableReservations) {
                // Skip cancelled reservations
                if ("cancelled".equals(reservation.getStatus())) {
                    continue;
                }

                LocalTime reservationTime = LocalTime.parse(reservation.getReservationTime());
                LocalTime reservationEndTime = reservationTime.plusHours(reservation.getDuration());

                // Check for overlap
                if (requestedTime.isBefore(reservationEndTime) &&
                        reservationTime.isBefore(requestedEndTime)) {
                    return false;
                }
            }

            return true;
        } catch (Exception e) {
            // If there's any error, assume the table is not available to be safe
            return false;
        }
    }

    /**
     * Find reservations with pending status.
     *
     * @return A list of pending reservations
     */
    public List<Reservation> findPendingReservations() {
        List<Reservation> result = new ArrayList<>();

        for (Reservation reservation : queue) {
            if ("pending".equals(reservation.getStatus())) {
                result.add(reservation);
            }
        }

        return result;
    }

    /**
     * Process the next reservation in the queue.
     * This will dequeue the first pending reservation.
     *
     * @return The processed reservation or null if queue is empty
     */
    public Reservation processNextReservation() {
        // Find the first pending reservation
        for (int i = 0; i < queue.size(); i++) {
            Reservation reservation = queue.get(i);
            if ("pending".equals(reservation.getStatus())) {
                // Update status to confirmed
                reservation.setStatus("confirmed");
                // Remove from queue
                return queue.remove(i);
            }
        }

        return null; // No pending reservations found
    }

    /**
     * Returns the next pending reservation without removing it.
     *
     * @return The next pending reservation or null if none is found
     */
    public Reservation peekNextPending() {
        for (Reservation reservation : queue) {
            if ("pending".equals(reservation.getStatus())) {
                return reservation;
            }
        }

        return null; // No pending reservations found
    }

    /**
     * Move a reservation to the front of the queue.
     *
     * @param reservationId The ID of the reservation to prioritize
     * @return true if the reservation was found and moved, false otherwise
     */
    public boolean prioritize(String reservationId) {
        for (int i = 0; i < queue.size(); i++) {
            Reservation reservation = queue.get(i);
            if (reservation.getId().equals(reservationId)) {
                // Remove from current position
                queue.remove(i);
                // Add to front of queue
                queue.add(0, reservation);
                return true;
            }
        }

        return false; // Reservation not found
    }

    /**
     * Filter reservations by status.
     *
     * @param status The status to filter by
     * @return A list of reservations with the specified status
     */
    public List<Reservation> filterByStatus(String status) {
        List<Reservation> result = new ArrayList<>();

        for (Reservation reservation : queue) {
            if (reservation.getStatus().equals(status)) {
                result.add(reservation);
            }
        }

        return result;
    }
}