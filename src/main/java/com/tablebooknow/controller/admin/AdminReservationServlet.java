package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for admin reservation management
 */
@WebServlet("/admin/reservations/*")
public class AdminReservationServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
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

        // Default path handling
        if (pathInfo == null || pathInfo.equals("/")) {
            listAllReservations(request, response);
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/view":
                viewReservation(request, response);
                break;
            case "/edit":
                showEditForm(request, response);
                break;
            default:
                listAllReservations(request, response);
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

        // Default path handling
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/update":
                updateReservation(request, response);
                break;
            case "/cancel":
                cancelReservation(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/reservations");
                break;
        }
    }

    private void listAllReservations(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<Reservation> allReservations = reservationDAO.findAll();
            request.setAttribute("reservations", allReservations);
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        }
    }

    private void viewReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id == null || id.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        try {
            Reservation reservation = reservationDAO.findById(id);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                response.sendRedirect(request.getContextPath() + "/admin/reservations");
                return;
            }

            User user = userDAO.findById(reservation.getUserId());

            request.setAttribute("reservation", reservation);
            request.setAttribute("user", user);
            request.getRequestDispatcher("/admin-reservation-details.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for showing edit form
    }

    private void updateReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for updating reservation
    }

    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");
        if (reservationId == null || reservationId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        try {
            boolean success = reservationDAO.cancelReservation(reservationId);
            if (success) {
                request.setAttribute("successMessage", "Reservation cancelled successfully");
            } else {
                request.setAttribute("errorMessage", "Failed to cancel reservation");
            }

            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error cancelling reservation: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        }
    }
}