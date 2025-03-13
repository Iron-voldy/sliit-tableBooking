package com.tablebooknow.util;

import com.tablebooknow.model.reservation.Reservation;

import java.util.ArrayList;
import java.util.List;

/**
 * Queue implementation for managing reservation requests.
 * This implementation uses the FIFO (First In, First Out) principle.
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
}