package com.tablebooknow.controller.reservation;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.util.ReservationQueue;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/reservation/*")
public class ReservationServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private ReservationQueue reservationQueue;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        reservationQueue = new ReservationQueue();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        switch (pathInfo) {
            case "/dateSelection":
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                break;
            case "/tableSelection":
                // Get reservation date and time from request parameters
                String reservationDate = request.getParameter("reservationDate");
                String reservationTime = request.getParameter("reservationTime");

                if (reservationDate == null || reservationTime == null) {
                    response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                    return;
                }

                // Set these values as attributes for the table selection page
                request.setAttribute("reservationDate", reservationDate);
                request.setAttribute("reservationTime", reservationTime);

                request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null) {
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        switch (pathInfo) {
            case "/createReservation":
                processDateTimeSelection(request, response);
                break;
            case "/confirmReservation":
                confirmReservation(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                break;
        }
    }

    private void processDateTimeSelection(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationDate = request.getParameter("reservationDate");
        String reservationTime = request.getParameter("reservationTime");
        String bookingType = request.getParameter("bookingType");
        String reservationDuration = request.getParameter("reservationDuration");

        // Default values
        if (bookingType == null) {
            bookingType = "normal";
        }

        if (reservationDuration == null) {
            reservationDuration = (bookingType.equals("special")) ? "3" : "2";
        }

        // Validate date and time
        if (reservationDate == null || reservationTime == null ||
                reservationDate.trim().isEmpty() || reservationTime.trim().isEmpty()) {

            request.setAttribute("errorMessage", "Please select both date and time");
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
            return;
        }

        try {
            // Parse and validate the date
            LocalDate date = LocalDate.parse(reservationDate);
            LocalDate today = LocalDate.now();

            if (date.isBefore(today)) {
                request.setAttribute("errorMessage", "Please select a future date");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // Parse and validate the time
            LocalTime time = LocalTime.parse(reservationTime);
            LocalTime openingTime = LocalTime.of(10, 0); // 10:00 AM
            LocalTime closingTime = LocalTime.of(22, 0); // 10:00 PM

            if (time.isBefore(openingTime) || time.isAfter(closingTime)) {
                request.setAttribute("errorMessage", "Please select a time between 10:00 AM and 10:00 PM");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // If today, check if time is in the past
            if (date.isEqual(today) && time.isBefore(LocalTime.now())) {
                request.setAttribute("errorMessage", "Please select a future time");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // Check closing time based on duration
            int duration = Integer.parseInt(reservationDuration);
            LocalTime endTime = time.plusHours(duration);

            if (endTime.isAfter(closingTime)) {
                request.setAttribute("errorMessage", "Your booking would end after our closing time (10:00 PM). Please select an earlier time or reduce duration.");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // Store the date, time and booking details in the session for later use
            HttpSession session = request.getSession();
            session.setAttribute("reservationDate", reservationDate);
            session.setAttribute("reservationTime", reservationTime);
            session.setAttribute("bookingType", bookingType);
            session.setAttribute("reservationDuration", reservationDuration);

            // Redirect to table selection page
            response.sendRedirect(request.getContextPath() + "/tableSelection.jsp");

        } catch (DateTimeParseException e) {
            request.setAttribute("errorMessage", "Invalid date or time format");
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid duration format");
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
        }
    }

    private void confirmReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String reservationDate = (String) session.getAttribute("reservationDate");
        String reservationTime = (String) session.getAttribute("reservationTime");
        String bookingType = (String) session.getAttribute("bookingType");
        String reservationDuration = (String) session.getAttribute("reservationDuration");

        String tableId = request.getParameter("tableId");
        String specialRequests = request.getParameter("specialRequests");

        if (userId == null || reservationDate == null || reservationTime == null || tableId == null) {
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        // Default values if null
        if (bookingType == null) {
            bookingType = "normal";
        }

        if (reservationDuration == null) {
            reservationDuration = (bookingType.equals("special")) ? "3" : "2";
        }

        try {
            // Check if table is available at this time
            LocalTime startTime = LocalTime.parse(reservationTime);
            int duration = Integer.parseInt(reservationDuration);

            if (!isTableAvailable(tableId, reservationDate, startTime, duration)) {
                request.setAttribute("errorMessage", "This table is no longer available at the selected time. Please choose another table.");
                request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
                return;
            }

            // Create a new reservation
            Reservation reservation = new Reservation();
            reservation.setUserId(userId);
            reservation.setReservationDate(reservationDate);
            reservation.setReservationTime(reservationTime);
            reservation.setDuration(Integer.parseInt(reservationDuration));
            reservation.setTableId(tableId);
            reservation.setBookingType(bookingType);
            reservation.setSpecialRequests(specialRequests);
            reservation.setStatus("confirmed");

            // Save the reservation
            reservationDAO.create(reservation);

            // Add to the queue for processing
            reservationQueue.enqueue(reservation);

            // Clear the session attributes related to the current reservation process
            session.removeAttribute("reservationDate");
            session.removeAttribute("reservationTime");
            session.removeAttribute("bookingType");
            session.removeAttribute("reservationDuration");

            // Set confirmation message and redirect to confirmation page
            session.setAttribute("confirmationMessage", "Your reservation has been confirmed!");
            session.setAttribute("reservationId", reservation.getId());

            // Process the queue using merge sort to order reservations
            processReservationQueue();

            response.sendRedirect(request.getContextPath() + "/confirmation.jsp");

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error creating reservation: " + e.getMessage());
            request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
        }
    }

    private boolean isTableAvailable(String tableId, String date, LocalTime startTime, int duration) throws IOException {
        // Get all reservations for this table and date
        List<Reservation> reservations = reservationDAO.findByTableAndDate(tableId, date);

        // If no reservations, table is available
        if (reservations.isEmpty()) {
            return true;
        }

        LocalTime endTime = startTime.plusHours(duration);

        // Check each reservation for time conflicts
        for (Reservation reservation : reservations) {
            LocalTime existingStart = LocalTime.parse(reservation.getReservationTime());
            LocalTime existingEnd = existingStart.plusHours(reservation.getDuration());

            // Check if the time slots overlap
            if (startTime.isBefore(existingEnd) && existingStart.isBefore(endTime)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Process the reservation queue using merge sort to order by time
     */
    private void processReservationQueue() throws IOException {
        List<Reservation> reservations = reservationQueue.getAllReservations();

        if (reservations.isEmpty()) {
            return;
        }

        // Sort reservations by time using merge sort
        List<Reservation> sortedReservations = mergeSort(reservations);

        // Clear the queue and re-add sorted reservations
        reservationQueue.clear();
        for (Reservation reservation : sortedReservations) {
            reservationQueue.enqueue(reservation);
        }
    }

    /**
     * Merge sort implementation for sorting reservations by time
     */
    private List<Reservation> mergeSort(List<Reservation> reservations) {
        if (reservations.size() <= 1) {
            return reservations;
        }

        int mid = reservations.size() / 2;
        List<Reservation> left = new ArrayList<>(reservations.subList(0, mid));
        List<Reservation> right = new ArrayList<>(reservations.subList(mid, reservations.size()));

        left = mergeSort(left);
        right = mergeSort(right);

        return merge(left, right);
    }

    private List<Reservation> merge(List<Reservation> left, List<Reservation> right) {
        List<Reservation> result = new ArrayList<>();
        int leftIndex = 0;
        int rightIndex = 0;

        while (leftIndex < left.size() && rightIndex < right.size()) {
            Reservation leftRes = left.get(leftIndex);
            Reservation rightRes = right.get(rightIndex);

            // Compare reservation times
            LocalTime leftTime = LocalTime.parse(leftRes.getReservationTime());
            LocalTime rightTime = LocalTime.parse(rightRes.getReservationTime());

            if (leftTime.isBefore(rightTime) || leftTime.equals(rightTime)) {
                result.add(leftRes);
                leftIndex++;
            } else {
                result.add(rightRes);
                rightIndex++;
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
}