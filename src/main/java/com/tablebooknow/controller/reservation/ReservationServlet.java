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
import java.util.Enumeration;
import java.util.List;

@WebServlet("/reservation/*")
public class ReservationServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private ReservationQueue reservationQueue;

    @Override
    public void init() throws ServletException {
        System.out.println("Initializing ReservationServlet");
        reservationDAO = new ReservationDAO();
        reservationQueue = new ReservationQueue();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("GET request to: " + pathInfo);

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            System.out.println("No path info, redirecting to date selection page");
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        System.out.println("Processing path: " + pathInfo);
        switch (pathInfo) {
            case "/dateSelection":
                System.out.println("Forwarding to date selection page");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                break;
            case "/tableSelection":
                // Get reservation date and time from request parameters
                String reservationDate = request.getParameter("reservationDate");
                String reservationTime = request.getParameter("reservationTime");
                System.out.println("Table selection requested with date=" + reservationDate + ", time=" + reservationTime);

                if (reservationDate == null || reservationTime == null) {
                    System.out.println("Missing date or time, redirecting to date selection page");
                    response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                    return;
                }

                // Set these values as attributes for the table selection page
                request.setAttribute("reservationDate", reservationDate);
                request.setAttribute("reservationTime", reservationTime);
                System.out.println("Forwarding to table selection page with date and time attributes set");
                request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
                break;
            default:
                System.out.println("Unknown path: " + pathInfo + ", redirecting to date selection page");
                response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("POST request to: " + pathInfo);
        dumpRequestParams(request);

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null) {
            System.out.println("No path info in POST request, redirecting to date selection page");
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        System.out.println("Processing POST path: " + pathInfo);
        switch (pathInfo) {
            case "/createReservation":
                System.out.println("Creating reservation");
                processDateTimeSelection(request, response);
                break;
            case "/confirmReservation":
                System.out.println("Confirming reservation");
                confirmReservation(request, response);
                break;
            default:
                System.out.println("Unknown POST path: " + pathInfo + ", redirecting to date selection page");
                response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
                break;
        }
    }

    // Utility method to dump request parameters for debugging
    private void dumpRequestParams(HttpServletRequest request) {
        System.out.println("Request parameters:");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String[] paramValues = request.getParameterValues(paramName);
            for (String value : paramValues) {
                System.out.println("  " + paramName + " = " + value);
            }
        }
    }

    private void processDateTimeSelection(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Processing date and time selection");
        String reservationDate = request.getParameter("reservationDate");
        String reservationTime = request.getParameter("reservationTime");
        String bookingType = request.getParameter("bookingType");
        String reservationDuration = request.getParameter("reservationDuration");

        System.out.println("Parameters received: date=" + reservationDate + ", time=" + reservationTime +
                ", type=" + bookingType + ", duration=" + reservationDuration);

        // Default values
        if (bookingType == null) {
            bookingType = "normal";
            System.out.println("Using default booking type: normal");
        }

        if (reservationDuration == null) {
            reservationDuration = (bookingType.equals("special")) ? "3" : "2";
            System.out.println("Using default duration: " + reservationDuration);
        }

        // Validate date and time
        if (reservationDate == null || reservationTime == null ||
                reservationDate.trim().isEmpty() || reservationTime.trim().isEmpty()) {

            System.out.println("Missing date or time, returning to date selection page with error");
            request.setAttribute("errorMessage", "Please select both date and time");
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
            return;
        }

        try {
            // Parse and validate the date
            LocalDate date = LocalDate.parse(reservationDate);
            LocalDate today = LocalDate.now();
            System.out.println("Date parsed: " + date + ", today is: " + today);

            if (date.isBefore(today)) {
                System.out.println("Date is in the past");
                request.setAttribute("errorMessage", "Please select a future date");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // Parse and validate the time
            LocalTime time = LocalTime.parse(reservationTime);
            LocalTime openingTime = LocalTime.of(10, 0); // 10:00 AM
            LocalTime closingTime = LocalTime.of(22, 0); // 10:00 PM
            System.out.println("Time parsed: " + time + ", opening: " + openingTime + ", closing: " + closingTime);

            if (time.isBefore(openingTime) || time.isAfter(closingTime)) {
                System.out.println("Time is outside business hours");
                request.setAttribute("errorMessage", "Please select a time between 10:00 AM and 10:00 PM");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // If today, check if time is in the past
            if (date.isEqual(today) && time.isBefore(LocalTime.now())) {
                System.out.println("Time is in the past on today's date");
                request.setAttribute("errorMessage", "Please select a future time");
                request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
                return;
            }

            // Check closing time based on duration
            int duration = Integer.parseInt(reservationDuration);
            LocalTime endTime = time.plusHours(duration);
            System.out.println("End time calculated: " + endTime);

            if (endTime.isAfter(closingTime)) {
                System.out.println("Reservation would end after closing time");
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

            System.out.println("Successfully stored in session: date=" + reservationDate +
                    ", time=" + reservationTime + ", type=" + bookingType + ", duration=" + reservationDuration);
            System.out.println("Redirecting to table selection page");

            // Redirect to table selection page
            response.sendRedirect(request.getContextPath() + "/tableSelection.jsp");

        } catch (DateTimeParseException e) {
            System.err.println("Date/time parsing error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid date or time format: " + e.getMessage());
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            System.err.println("Number format error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid duration format: " + e.getMessage());
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/dateSelection.jsp").forward(request, response);
        }
    }

    private void confirmReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Confirming reservation");
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String reservationDate = (String) session.getAttribute("reservationDate");
        String reservationTime = (String) session.getAttribute("reservationTime");
        String bookingType = (String) session.getAttribute("bookingType");
        String reservationDuration = (String) session.getAttribute("reservationDuration");

        System.out.println("Session data: userId=" + userId + ", date=" + reservationDate +
                ", time=" + reservationTime + ", type=" + bookingType + ", duration=" + reservationDuration);

        String tableId = request.getParameter("tableId");
        String specialRequests = request.getParameter("specialRequests");
        System.out.println("Request parameters: tableId=" + tableId + ", specialRequests=" +
                (specialRequests != null ? specialRequests.substring(0, Math.min(20, specialRequests.length())) + "..." : "null"));

        if (userId == null || reservationDate == null || reservationTime == null || tableId == null) {
            System.out.println("Missing required data, redirecting to date selection page");
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        // Default values if null
        if (bookingType == null) {
            bookingType = "normal";
            System.out.println("Using default booking type: normal");
        }

        if (reservationDuration == null) {
            reservationDuration = (bookingType.equals("special")) ? "3" : "2";
            System.out.println("Using default duration: " + reservationDuration);
        }

        try {
            // Check if table is available at this time
            LocalTime startTime = LocalTime.parse(reservationTime);
            int duration = Integer.parseInt(reservationDuration);
            System.out.println("Checking if table " + tableId + " is available at " + startTime + " for " + duration + " hours");

            if (!isTableAvailable(tableId, reservationDate, startTime, duration)) {
                System.out.println("Table is not available");
                request.setAttribute("errorMessage", "This table is no longer available at the selected time. Please choose another table.");
                request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
                return;
            }

            System.out.println("Table is available, creating reservation");
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
            System.out.println("Saving reservation with ID: " + reservation.getId());
            reservationDAO.create(reservation);
            System.out.println("Reservation created successfully");

            // Add to the queue for processing
            reservationQueue.enqueue(reservation);
            System.out.println("Added reservation to queue");

            // Clear the session attributes related to the current reservation process
            session.removeAttribute("reservationDate");
            session.removeAttribute("reservationTime");
            session.removeAttribute("bookingType");
            session.removeAttribute("reservationDuration");
            System.out.println("Cleared session attributes");

            // Set confirmation message and redirect to confirmation page
            session.setAttribute("confirmationMessage", "Your reservation has been confirmed!");
            session.setAttribute("reservationId", reservation.getId());
            System.out.println("Set confirmation message and reservation ID: " + reservation.getId());

            // Process the queue using merge sort to order reservations
            processReservationQueue();
            System.out.println("Processed reservation queue");

            System.out.println("Redirecting to confirmation page");
            response.sendRedirect(request.getContextPath() + "/confirmation.jsp");

        } catch (Exception e) {
            System.err.println("Error creating reservation: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error creating reservation: " + e.getMessage());
            request.getRequestDispatcher("/tableSelection.jsp").forward(request, response);
        }
    }

    private boolean isTableAvailable(String tableId, String date, LocalTime startTime, int duration) throws IOException {
        System.out.println("Checking table availability: tableId=" + tableId + ", date=" + date +
                ", startTime=" + startTime + ", duration=" + duration);

        // Get all reservations for this table and date
        List<Reservation> reservations = reservationDAO.findByTableAndDate(tableId, date);
        System.out.println("Found " + reservations.size() + " existing reservations for this table and date");

        // If no reservations, table is available
        if (reservations.isEmpty()) {
            System.out.println("No existing reservations, table is available");
            return true;
        }

        LocalTime endTime = startTime.plusHours(duration);
        System.out.println("Requested time slot: " + startTime + " to " + endTime);

        // Check each reservation for time conflicts
        for (Reservation reservation : reservations) {
            LocalTime existingStart = LocalTime.parse(reservation.getReservationTime());
            LocalTime existingEnd = existingStart.plusHours(reservation.getDuration());
            System.out.println("Checking against existing reservation: " + existingStart + " to " + existingEnd);

            // Check if the time slots overlap
            if (startTime.isBefore(existingEnd) && existingStart.isBefore(endTime)) {
                System.out.println("Conflict detected - table is not available");
                return false;
            }
        }

        System.out.println("No conflicts found - table is available");
        return true;
    }

    /**
     * Process the reservation queue using merge sort to order by time
     */
    private void processReservationQueue() throws IOException {
        System.out.println("Processing reservation queue");
        List<Reservation> reservations = reservationQueue.getAllReservations();
        System.out.println("Queue size: " + reservations.size());

        if (reservations.isEmpty()) {
            System.out.println("Queue is empty, nothing to process");
            return;
        }

        // Sort reservations by time using merge sort
        List<Reservation> sortedReservations = mergeSort(reservations);
        System.out.println("Sorted queue size: " + sortedReservations.size());

        // Clear the queue and re-add sorted reservations
        reservationQueue.clear();
        for (Reservation reservation : sortedReservations) {
            reservationQueue.enqueue(reservation);
        }
        System.out.println("Queue updated with sorted reservations");
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