package com.tablebooknow.controller.user;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.PaymentDAO;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.payment.Payment;

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
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

/**
 * Servlet for managing user reservations
 */
@WebServlet("/user/reservations/*")
public class UserReservationsServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        paymentDAO = new PaymentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String pathInfo = request.getPathInfo();

        // Default path handling
        if (pathInfo == null || pathInfo.equals("/")) {
            listReservations(request, response, userId);
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/view":
                viewReservation(request, response, userId);
                break;
            case "/cancel":
                // Just show confirmation page for cancel
                showCancelConfirmation(request, response, userId);
                break;
            default:
                listReservations(request, response, userId);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String pathInfo = request.getPathInfo();

        // Default path handling
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/cancel":
                cancelReservation(request, response, userId);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                break;
        }
    }

    /**
     * Lists all reservations for a user
     */
    private void listReservations(HttpServletRequest request, HttpServletResponse response, String userId)
            throws ServletException, IOException {
        try {
            // Get all reservations for the user
            List<Reservation> userReservations = reservationDAO.findByUserId(userId);

            // Sort reservations by date and time (upcoming first)
            userReservations.sort((r1, r2) -> {
                // First compare by date
                int dateCompare = r1.getReservationDate().compareTo(r2.getReservationDate());
                if (dateCompare != 0) {
                    return dateCompare;
                }
                // Then by time
                return r1.getReservationTime().compareTo(r2.getReservationTime());
            });

            // Separate into upcoming, past, and cancelled reservations
            List<Reservation> upcomingReservations = new ArrayList<>();
            List<Reservation> pastReservations = new ArrayList<>();
            List<Reservation> cancelledReservations = new ArrayList<>();

            LocalDate today = LocalDate.now();
            LocalTime now = LocalTime.now();

            for (Reservation reservation : userReservations) {
                if ("cancelled".equals(reservation.getStatus())) {
                    cancelledReservations.add(reservation);
                    continue;
                }

                LocalDate reservationDate = LocalDate.parse(reservation.getReservationDate());

                if (reservationDate.isAfter(today) ||
                        (reservationDate.isEqual(today) &&
                                LocalTime.parse(reservation.getReservationTime()).isAfter(now))) {
                    upcomingReservations.add(reservation);
                } else {
                    pastReservations.add(reservation);
                }
            }

            // Get payment status for each reservation
            Map<String, String> paymentStatuses = new HashMap<>();

            for (Reservation reservation : userReservations) {
                List<Payment> payments = paymentDAO.findByReservationId(reservation.getId());
                if (payments != null && !payments.isEmpty()) {
                    Payment latestPayment = payments.get(payments.size() - 1);
                    paymentStatuses.put(reservation.getId(), latestPayment.getStatus());
                } else {
                    paymentStatuses.put(reservation.getId(), "PENDING");
                }
            }

            // Add all data to the request
            request.setAttribute("upcomingReservations", upcomingReservations);
            request.setAttribute("pastReservations", pastReservations);
            request.setAttribute("cancelledReservations", cancelledReservations);
            request.setAttribute("paymentStatuses", paymentStatuses);

            // Forward to JSP
            request.getRequestDispatcher("/user-reservations.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error listing user reservations: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading your reservations: " + e.getMessage());
            request.getRequestDispatcher("/user-reservations.jsp").forward(request, response);
        }
    }

    /**
     * Shows detailed view of a specific reservation
     */
    private void viewReservation(HttpServletRequest request, HttpServletResponse response, String userId)
            throws ServletException, IOException {
        String reservationId = request.getParameter("id");

        if (reservationId == null || reservationId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        try {
            // Get the reservation
            Reservation reservation = reservationDAO.findById(reservationId);

            // Check if reservation exists and belongs to this user
            if (reservation == null || !userId.equals(reservation.getUserId())) {
                request.setAttribute("errorMessage", "Reservation not found or access denied");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Get payment information
            List<Payment> payments = paymentDAO.findByReservationId(reservationId);
            Payment payment = payments != null && !payments.isEmpty() ? payments.get(payments.size() - 1) : null;

            // Determine if reservation can be cancelled (only if it's in the future and confirmed)
            boolean canCancel = false;

            if (!"cancelled".equals(reservation.getStatus())) {
                LocalDate reservationDate = LocalDate.parse(reservation.getReservationDate());
                LocalDate today = LocalDate.now();

                if (reservationDate.isAfter(today) ||
                        (reservationDate.isEqual(today) &&
                                LocalTime.parse(reservation.getReservationTime()).isAfter(LocalTime.now()))) {
                    canCancel = true;
                }
            }

            // Add data to request
            request.setAttribute("reservation", reservation);
            request.setAttribute("payment", payment);
            request.setAttribute("canCancel", canCancel);

            // Forward to JSP
            request.getRequestDispatcher("/user-reservation-details.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error viewing reservation: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading reservation details: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user/reservations");
        }
    }

    /**
     * Shows confirmation page before cancelling a reservation
     */
    private void showCancelConfirmation(HttpServletRequest request, HttpServletResponse response, String userId)
            throws ServletException, IOException {
        String reservationId = request.getParameter("id");

        if (reservationId == null || reservationId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        try {
            // Get the reservation
            Reservation reservation = reservationDAO.findById(reservationId);

            // Check if reservation exists and belongs to this user
            if (reservation == null || !userId.equals(reservation.getUserId())) {
                request.setAttribute("errorMessage", "Reservation not found or access denied");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Check if reservation is already cancelled
            if ("cancelled".equals(reservation.getStatus())) {
                request.setAttribute("errorMessage", "This reservation is already cancelled");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Check if reservation is in the past
            LocalDate reservationDate = LocalDate.parse(reservation.getReservationDate());
            LocalDate today = LocalDate.now();

            if (reservationDate.isBefore(today) ||
                    (reservationDate.isEqual(today) &&
                            LocalTime.parse(reservation.getReservationTime()).isBefore(LocalTime.now()))) {
                request.setAttribute("errorMessage", "Cannot cancel a past reservation");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Add data to request
            request.setAttribute("reservation", reservation);

            // Forward to JSP
            request.getRequestDispatcher("/user-reservation-cancel.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error showing cancel confirmation: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing cancellation request: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user/reservations");
        }
    }

    /**
     * Processes the actual cancellation of a reservation
     */
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response, String userId)
            throws ServletException, IOException {
        String reservationId = request.getParameter("id");
        String confirmCancel = request.getParameter("confirmCancel");

        if (reservationId == null || reservationId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        // Check if user confirmed cancellation
        if (!"yes".equals(confirmCancel)) {
            response.sendRedirect(request.getContextPath() + "/user/reservations/view?id=" + reservationId);
            return;
        }

        try {
            // Get the reservation
            Reservation reservation = reservationDAO.findById(reservationId);

            // Check if reservation exists and belongs to this user
            if (reservation == null || !userId.equals(reservation.getUserId())) {
                request.setAttribute("errorMessage", "Reservation not found or access denied");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Check if reservation is already cancelled
            if ("cancelled".equals(reservation.getStatus())) {
                request.setAttribute("errorMessage", "This reservation is already cancelled");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Check if reservation is in the past
            LocalDate reservationDate = LocalDate.parse(reservation.getReservationDate());
            LocalDate today = LocalDate.now();

            if (reservationDate.isBefore(today) ||
                    (reservationDate.isEqual(today) &&
                            LocalTime.parse(reservation.getReservationTime()).isBefore(LocalTime.now()))) {
                request.setAttribute("errorMessage", "Cannot cancel a past reservation");
                response.sendRedirect(request.getContextPath() + "/user/reservations");
                return;
            }

            // Cancel the reservation
            boolean success = reservationDAO.cancelReservation(reservationId);

            if (success) {
                // Set success message
                request.setAttribute("successMessage", "Your reservation has been successfully cancelled");
                // Redirect to reservations list
                response.sendRedirect(request.getContextPath() + "/user/reservations");
            } else {
                request.setAttribute("errorMessage", "Failed to cancel reservation");
                response.sendRedirect(request.getContextPath() + "/user/reservations/view?id=" + reservationId);
            }

        } catch (Exception e) {
            System.err.println("Error cancelling reservation: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error cancelling reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user/reservations");
        }
    }
}