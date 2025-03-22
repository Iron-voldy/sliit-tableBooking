package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.AdminDAO;
import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.model.admin.Admin;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;
import com.tablebooknow.util.PasswordHasher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for handling admin-related requests and authentication.
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private AdminDAO adminDAO;
    private UserDAO userDAO;
    private ReservationDAO reservationDAO;

    @Override
    public void init() throws ServletException {
        adminDAO = new AdminDAO();
        userDAO = new UserDAO();
        reservationDAO = new ReservationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Default to login page
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/login";
        }

        // Check if this is a login page request
        if (pathInfo.equals("/login")) {
            request.getRequestDispatcher("/adminLogin.jsp").forward(request, response);
            return;
        }

        // For all other paths, check if admin is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        // Instead of using servlet paths, redirect directly to JSP files
        switch (pathInfo) {
            case "/dashboard":
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                break;
            case "/users":
                response.sendRedirect(request.getContextPath() + "/admin-users.jsp");
                break;
            case "/reservations":
                response.sendRedirect(request.getContextPath() + "/admin-reservations.jsp");
                break;
            case "/logout":
                logout(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();

        // Default to login action
        if (pathInfo == null || pathInfo.equals("/")) {
            pathInfo = "/login";
        }

        switch (pathInfo) {
            case "/login":
                login(request, response);
                break;
            case "/cancelReservation":
                cancelReservation(request, response);
                break;
            case "/updateUser":
                updateUser(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                break;
        }
    }

    /**
     * Handle admin login
     */
    private void login(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Validate input
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Username and password are required");
            request.getRequestDispatcher("/adminLogin.jsp").forward(request, response);
            return;
        }

        try {
            // Check admin database first
            Admin admin = adminDAO.findByUsername(username);

            if (admin != null && PasswordHasher.checkPassword(password, admin.getPassword())) {
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("adminId", admin.getId());
                session.setAttribute("adminUsername", admin.getUsername());
                session.setAttribute("isAdmin", true);

                // Redirect directly to admin dashboard JSP

                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            } else {
                // Check if this is a regular user with admin privileges
                User user = userDAO.findByUsername(username);

                if (user != null && user.isAdmin() && PasswordHasher.checkPassword(password, user.getPassword())) {
                    // Create session
                    HttpSession session = request.getSession();
                    session.setAttribute("adminId", user.getId());
                    session.setAttribute("adminUsername", user.getUsername());
                    session.setAttribute("isAdmin", true);

                    // Redirect to admin dashboard
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    request.setAttribute("errorMessage", "Invalid username or password");
                    request.getRequestDispatcher("/adminLogin.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "An error occurred during login: " + e.getMessage());
            request.getRequestDispatcher("/adminLogin.jsp").forward(request, response);
        }
    }

    /**
     * Show admin dashboard with summary statistics
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get statistics for the dashboard
            int totalUsers = userDAO.findAll().size();

            List<Reservation> allReservations = reservationDAO.findAll();
            int totalReservations = allReservations.size();

            // Count reservations by status
            int pendingReservations = 0;
            int confirmedReservations = 0;
            int cancelledReservations = 0;

            for (Reservation reservation : allReservations) {
                String status = reservation.getStatus();
                if ("pending".equals(status)) {
                    pendingReservations++;
                } else if ("confirmed".equals(status)) {
                    confirmedReservations++;
                } else if ("cancelled".equals(status)) {
                    cancelledReservations++;
                }
            }

            // Get upcoming reservations (for today and future)
            List<Reservation> upcomingReservations =
                    reservationDAO.findUpcomingReservations(
                            java.time.LocalDate.now().toString(),
                            java.time.LocalTime.now().toString()
                    );

            // Set attributes for the dashboard
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalReservations", totalReservations);
            request.setAttribute("pendingReservations", pendingReservations);
            request.setAttribute("confirmedReservations", confirmedReservations);
            request.setAttribute("cancelledReservations", cancelledReservations);
            request.setAttribute("upcomingReservations", upcomingReservations);

            // Forward to dashboard JSP
            // Changed path to match the admin-dashboard.jsp file location
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading dashboard: " + e.getMessage());
            // Changed path to match the admin-dashboard.jsp file location
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
        }
    }

    /**
     * Show list of users
     */
    private void showUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<User> users = userDAO.findAll();
            request.setAttribute("users", users);
            // Changed path to match the admin-users.jsp file location
            request.getRequestDispatcher("/admin-users.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading users: " + e.getMessage());
            // Changed path to match the admin-users.jsp file location
            request.getRequestDispatcher("/admin-users.jsp").forward(request, response);
        }
    }

    /**
     * Show list of reservations
     */
    private void showReservations(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get all reservations
            List<Reservation> reservations = reservationDAO.findAll();
            request.setAttribute("reservations", reservations);

            // Forward to reservations JSP
            // Changed path to match the admin-reservations.jsp file location
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
            // Changed path to match the admin-reservations.jsp file location
            request.getRequestDispatcher("/admin-reservations.jsp").forward(request, response);
        }
    }

    /**
     * Cancel a reservation
     */
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String reservationId = request.getParameter("reservationId");

        if (reservationId == null || reservationId.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Reservation ID is required");
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

    /**
     * Update user information
     */
    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String isAdminStr = request.getParameter("isAdmin");

        if (userId == null || userId.trim().isEmpty()) {
            request.setAttribute("errorMessage", "User ID is required");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            User user = userDAO.findById(userId);

            if (user != null) {
                boolean isAdmin = "on".equals(isAdminStr) || "true".equals(isAdminStr);
                user.setAdmin(isAdmin);

                boolean success = userDAO.update(user);

                if (success) {
                    request.setAttribute("successMessage", "User updated successfully");
                } else {
                    request.setAttribute("errorMessage", "Failed to update user");
                }
            } else {
                request.setAttribute("errorMessage", "User not found");
            }

            response.sendRedirect(request.getContextPath() + "/admin/users");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    /**
     * Handle admin logout
     */
    private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/admin/login");
    }
}