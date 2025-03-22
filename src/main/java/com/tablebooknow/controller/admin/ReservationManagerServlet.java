package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.dao.PaymentDAO;
import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Servlet for handling admin reservation management functions
 */
@WebServlet("/admin/reservations/*")
public class ReservationManagerServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private PaymentDAO paymentDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
        paymentDAO = new PaymentDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if admin is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/";
        }

        switch (pathInfo) {
            case "/":
            case "/list":
                // List all reservations
                listReservations(request, response);
                break;
            case "/view":
                // View specific reservation
                viewReservation(request, response);
                break;
            case "/edit":
                // Show edit reservation form
                showEditReservationForm(request, response);
                break;
            case "/upcoming":
                // List upcoming reservations
                listUpcomingReservations(request, response);
                break;
            case "/today":
                // List today's reservations
                listTodayReservations(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if admin is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/";
        }

        switch (pathInfo) {
            case "/update":
                // Update reservation
                updateReservation(request, response);
                break;
            case "/cancel":
                // Cancel reservation
                cancelReservation(request, response);
                break;
            case "/confirm":
                // Confirm reservation
                confirmReservation(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                break;
        }
    }

    /**
     * List all reservations
     */
    private void listReservations(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get parameters for filtering
            String status = request.getParameter("status");
            String dateFrom = request.getParameter("dateFrom");
            String dateTo = request.getParameter("dateTo");
            String tableId = request.getParameter("tableId");
            String userId = request.getParameter("userId");

            // Get all reservations
            List<Reservation> allReservations = reservationDAO.findAll();

            // Filter reservations if parameters are provided
            if (status != null && !status.trim().isEmpty()) {
                allReservations = allReservations.stream()
                        .filter(r -> r.getStatus().equals(status))
                        .collect(java.util.stream.Collectors.toList());
            }

            if (dateFrom != null && !dateFrom.trim().isEmpty()) {
                LocalDate fromDate = LocalDate.parse(dateFrom);
                allReservations = allReservations.stream()
                        .filter(r -> {
                            LocalDate reservationDate = LocalDate.parse(r.getReservationDate());
                            return !reservationDate.isBefore(fromDate);
                        })
                        .collect(java.util.stream.Collectors.toList());
            }

            if (dateTo != null && !dateTo.trim().isEmpty()) {
                LocalDate toDate = LocalDate.parse(dateTo);
                allReservations = allReservations.stream()
                        .filter(r -> {
                            LocalDate reservationDate = LocalDate.parse(r.getReservationDate());
                            return !reservationDate.isAfter(toDate);
                        })
                        .collect(java.util.stream.Collectors.toList());
            }

            if (tableId != null && !tableId.trim().isEmpty()) {
                allReservations = allReservations.stream()
                        .filter(r -> r.getTableId() != null && r.getTableId().equals(tableId))
                        .collect(java.util.stream.Collectors.toList());
            }

            if (userId != null && !userId.trim().isEmpty()) {
                allReservations = allReservations.stream()
                        .filter(r -> r.getUserId() != null && r.getUserId().equals(userId))
                        .collect(java.util.stream.Collectors.toList());
            }

            // Sort reservations by date and time (newest first)
            allReservations.sort((r1, r2) -> {
                int dateComparison = r2.getReservationDate().compareTo(r1.getReservationDate());
                if (dateComparison == 0) {
                    return r2.getReservationTime().compareTo(r1.getReservationTime());
                }
                return dateComparison;
            });

            request.setAttribute("reservations", allReservations);

            // Add filter parameters to request for form state preservation
            request.setAttribute("statusFilter", status);
            request.setAttribute("dateFromFilter", dateFrom);
            request.setAttribute("dateToFilter", dateTo);
            request.setAttribute("tableIdFilter", tableId);
            request.setAttribute("userIdFilter", userId);

            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        }
    }

    /**
     * View specific reservation
     */
    private void viewReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("id");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            return;
        }

        try {
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                return;
            }

            // Get user information
            User user = null;
            if (reservation.getUserId() != null) {
                user = userDAO.findById(reservation.getUserId());
            }

            // Get payment information
            List<Payment> payments = paymentDAO.findByReservationId(reservationId);

            request.setAttribute("reservation", reservation);
            request.setAttribute("user", user);
            request.setAttribute("payments", payments);

            request.getRequestDispatcher("/admin-reservation-details.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
        }
    }

    /**
     * Show edit reservation form
     */
    private void showEditReservationForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("id");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            return;
        }

        try {
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                return;
            }

            // Get user information
            User user = null;
            if (reservation.getUserId() != null) {
                user = userDAO.findById(reservation.getUserId());
            }

            request.setAttribute("reservation", reservation);
            request.setAttribute("user", user);

            request.getRequestDispatcher("/admin-reservation-edit.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
        }
    }

    /**
     * List upcoming reservations
     */
    private void listUpcomingReservations(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get today's date
            String today = LocalDate.now().toString();

            // Get all reservations from today onwards
            List<Reservation> upcomingReservations = reservationDAO.findAll().stream()
                    .filter(r -> r.getReservationDate().compareTo(today) >= 0)
                    .filter(r -> !r.getStatus().equals("cancelled"))
                    .sorted((r1, r2) -> {
                        int dateComparison = r1.getReservationDate().compareTo(r2.getReservationDate());
                        if (dateComparison == 0) {
                            return r1.getReservationTime().compareTo(r2.getReservationTime());
                        }
                        return dateComparison;
                    })
                    .collect(java.util.stream.Collectors.toList());

            request.setAttribute("reservations", upcomingReservations);
            request.setAttribute("listType", "upcoming");
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading upcoming reservations: " + e.getMessage());
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        }
    }

    /**
     * List today's reservations
     */
    private void listTodayReservations(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get today's date
            String today = LocalDate.now().toString();

            // Get today's reservations
            List<Reservation> todayReservations = reservationDAO.findByDate(today);

            // Sort by time
            todayReservations.sort((r1, r2) -> r1.getReservationTime().compareTo(r2.getReservationTime()));

            request.setAttribute("reservations", todayReservations);
            request.setAttribute("listType", "today");
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading today's reservations: " + e.getMessage());
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        }
    }

    /**
     * Update reservation
     */
    private void updateReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");
        String tableId = request.getParameter("tableId");
        String date = request.getParameter("reservationDate");
        String time = request.getParameter("reservationTime");
        String status = request.getParameter("status");
        String specialRequests = request.getParameter("specialRequests");
        String duration = request.getParameter("duration");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            return;
        }

        try {
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                return;
            }

            // Update fields if provided
            if (tableId != null && !tableId.trim().isEmpty()) {
                reservation.setTableId(tableId);
            }

            if (date != null && !date.trim().isEmpty()) {
                reservation.setReservationDate(date);
            }

            if (time != null && !time.trim().isEmpty()) {
                reservation.setReservationTime(time);
            }

            if (status != null && !status.trim().isEmpty()) {
                reservation.setStatus(status);
            }

            if (specialRequests != null) {
                reservation.setSpecialRequests(specialRequests);
            }

            if (duration != null && !duration.trim().isEmpty()) {
                try {
                    int durationValue = Integer.parseInt(duration);
                    reservation.setDuration(durationValue);
                } catch (NumberFormatException e) {
                    // Ignore invalid duration
                }
            }

            // Update the reservation
            reservationDAO.update(reservation);

            request.setAttribute("successMessage", "Reservation updated successfully");
            response.sendRedirect(request.getContextPath() + "/admin/reservations/view?id=" + reservationId);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations/edit?id=" + reservationId);
        }
    }

    /**
     * Cancel reservation
     */
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            return;
        }

        try {
            // Check if reservation exists
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                return;
            }

            // Cancel the reservation
            reservationDAO.updateStatus(reservationId, "cancelled");

            request.setAttribute("successMessage", "Reservation cancelled successfully");

            // Redirect back to the referring page or to the list
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error cancelling reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
        }
    }

    /**
     * Confirm reservation
     */
    private void confirmReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            return;
        }

        try {
            // Check if reservation exists
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                return;
            }

            // Confirm the reservation
            reservationDAO.updateStatus(reservationId, "confirmed");

            request.setAttribute("successMessage", "Reservation confirmed successfully");

            // Redirect back to the referring page or to the list
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/reservations/");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error confirming reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations/");
        }
    }
}