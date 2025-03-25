package com.tablebooknow.controller.reservation;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.model.reservation.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Servlet that handles the user's reservation history
 */
@WebServlet("/user/reservations")
public class UserReservationsServlet extends HttpServlet {
    private ReservationDAO reservationDAO;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
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

        try {
            // Get all reservations for this user
            List<Reservation> userReservations = reservationDAO.findByUserId(userId);

            // Sort reservations - most recent date first
            userReservations.sort((r1, r2) -> {
                // For reservations on the same date, sort by time
                if (r1.getReservationDate().equals(r2.getReservationDate())) {
                    return r1.getReservationTime().compareTo(r2.getReservationTime());
                }
                // Otherwise sort by date
                return r2.getReservationDate().compareTo(r1.getReservationDate());
            });

            // Set as request attribute
            request.setAttribute("userReservations", userReservations);

            // Forward to the JSP
            request.getRequestDispatcher("/user-reservations.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
            request.getRequestDispatcher("/user-reservations.jsp").forward(request, response);
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
        String action = request.getParameter("action");
        String reservationId = request.getParameter("reservationId");

        if ("cancel".equals(action) && reservationId != null) {
            try {
                // Get the reservation
                Reservation reservation = reservationDAO.findById(reservationId);

                // Verify the reservation belongs to this user
                if (reservation != null && reservation.getUserId().equals(userId)) {
                    // Cancel the reservation
                    boolean success = reservationDAO.cancelReservation(reservationId);

                    if (success) {
                        request.setAttribute("successMessage", "Reservation successfully cancelled.");
                    } else {
                        request.setAttribute("errorMessage", "Failed to cancel reservation.");
                    }
                } else {
                    request.setAttribute("errorMessage", "Invalid reservation or permission denied.");
                }
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Error cancelling reservation: " + e.getMessage());
            }

            // Redirect to GET to refresh the list
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        // Default: redirect to GET
        response.sendRedirect(request.getContextPath() + "/user/reservations");
    }
}