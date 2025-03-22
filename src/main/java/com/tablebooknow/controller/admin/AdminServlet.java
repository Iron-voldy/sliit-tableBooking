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
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * Main servlet for handling admin-related requests and authentication.
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

        // Check admin role and permissions (for future use)
        String adminRole = (String) session.getAttribute("adminRole");
        if (adminRole == null) {
            adminRole = "admin"; // Default role
        }

        // Route to appropriate handler based on path
        switch (pathInfo) {
            case "/dashboard":
                showDashboard(request, response);
                break;
            case "/profile":
                showAdminProfile(request, response);
                break;
            case "/settings":
                showAdminSettings(request, response);
                break;
            case "/logout":
                logout(request, response);
                break;
            default:
                // If the path starts with a known admin section, redirect to that section
                if (pathInfo.startsWith("/users")) {
                    response.sendRedirect(request.getContextPath() + "/admin/users/");
                } else if (pathInfo.startsWith("/reservations")) {
                    response.sendRedirect(request.getContextPath() + "/admin/reservations/");
                } else if (pathInfo.startsWith("/tables")) {
                    response.sendRedirect(request.getContextPath() + "/admin/tables/");
                } else if (pathInfo.startsWith("/stats")) {
                    response.sendRedirect(request.getContextPath() + "/admin/stats/dashboard");
                } else {
                    // Default to dashboard for unknown paths
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                }
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
            case "/updateProfile":
                updateAdminProfile(request, response);
                break;
            case "/changePassword":
                changeAdminPassword(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
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
                session.setAttribute("adminRole", admin.getRole());

                // Add admin menu to session for use in JSPs
                session.setAttribute("adminMenu", AdminDashboardConfig.getAdminMenu());

                // Redirect to admin dashboard
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                // Check if this is a regular user with admin privileges
                User user = userDAO.findByUsername(username);

                if (user != null && user.isAdmin() && PasswordHasher.checkPassword(password, user.getPassword())) {
                    // Create session
                    HttpSession session = request.getSession();
                    session.setAttribute("adminId", user.getId());
                    session.setAttribute("adminUsername", user.getUsername());
                    session.setAttribute("isAdmin", true);
                    session.setAttribute("adminRole", "admin"); // Default role for user-admins

                    // Add admin menu to session for use in JSPs
                    session.setAttribute("adminMenu", AdminDashboardConfig.getAdminMenu());

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
                            LocalDate.now().toString(),
                            LocalTime.now().toString()
                    );

            // Set attributes for the dashboard
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalReservations", totalReservations);
            request.setAttribute("pendingReservations", pendingReservations);
            request.setAttribute("confirmedReservations", confirmedReservations);
            request.setAttribute("cancelledReservations", cancelledReservations);
            request.setAttribute("upcomingReservations", upcomingReservations);

            // Add admin menu for navigation
            request.setAttribute("adminMenu", AdminDashboardConfig.getAdminMenu());

            // Get users for upcoming reservations
            Map<String, User> userMap = new java.util.HashMap<>();
            for (Reservation reservation : upcomingReservations) {
                String userId = reservation.getUserId();
                if (!userMap.containsKey(userId)) {
                    User user = userDAO.findById(userId);
                    if (user != null) {
                        userMap.put(userId, user);
                    }
                }
            }
            request.setAttribute("userMap", userMap);

            // Forward to dashboard JSP
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading dashboard: " + e.getMessage());
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
        }
    }

    /**
     * Show admin profile page
     */
    private void showAdminProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String adminId = (String) session.getAttribute("adminId");

        try {
            // First try to find in admin table
            Admin admin = adminDAO.findById(adminId);

            if (admin != null) {
                request.setAttribute("admin", admin);
                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If not found in admin table, check user table (for user-admins)
            User user = userDAO.findById(adminId);
            if (user != null && user.isAdmin()) {
                request.setAttribute("admin", user);
                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If admin not found in either table, redirect to login
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/admin/login");

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading admin profile: " + e.getMessage());
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
        }
    }

    /**
     * Show admin settings page
     */
    private void showAdminSettings(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String adminRole = (String) session.getAttribute("adminRole");

        // Only allow superadmins to access settings
        if (!"superadmin".equals(adminRole)) {
            request.setAttribute("errorMessage", "You don't have permission to access settings");
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/admin/admin-settings.jsp").forward(request, response);
    }

    /**
     * Update admin profile information
     */
    private void updateAdminProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String adminId = (String) session.getAttribute("adminId");
        String adminRole = (String) session.getAttribute("adminRole");

        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");

        try {
            // Check if admin exists in admin table
            Admin admin = adminDAO.findById(adminId);

            if (admin != null) {
                // Update admin profile
                admin.setEmail(email);
                admin.setFullName(fullName);

                boolean success = adminDAO.update(admin);

                if (success) {
                    request.setAttribute("successMessage", "Profile updated successfully");
                } else {
                    request.setAttribute("errorMessage", "Failed to update profile");
                }

                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If not in admin table, check user table (for user-admins)
            User user = userDAO.findById(adminId);
            if (user != null && user.isAdmin()) {
                // Update user profile
                user.setEmail(email);

                boolean success = userDAO.update(user);

                if (success) {
                    request.setAttribute("successMessage", "Profile updated successfully");
                } else {
                    request.setAttribute("errorMessage", "Failed to update profile");
                }

                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If admin not found in either table, redirect to login
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/admin/login");

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating profile: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
        }
    }

    /**
     * Handle admin password change
     */
    private void changeAdminPassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String adminId = (String) session.getAttribute("adminId");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate input
        if (currentPassword == null || newPassword == null || confirmPassword == null ||
                currentPassword.trim().isEmpty() || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All password fields are required");
            request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "New passwords don't match");
            request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
            return;
        }

        try {
            // Check admin table first
            Admin admin = adminDAO.findById(adminId);

            if (admin != null) {
                // Verify current password
                if (!PasswordHasher.checkPassword(currentPassword, admin.getPassword())) {
                    request.setAttribute("errorMessage", "Current password is incorrect");
                    request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                    return;
                }

                // Update password
                admin.setPassword(PasswordHasher.hashPassword(newPassword));
                boolean success = adminDAO.update(admin);

                if (success) {
                    request.setAttribute("successMessage", "Password changed successfully");
                } else {
                    request.setAttribute("errorMessage", "Failed to change password");
                }

                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If not in admin table, check user table (for user-admins)
            User user = userDAO.findById(adminId);
            if (user != null && user.isAdmin()) {
                // Verify current password
                if (!PasswordHasher.checkPassword(currentPassword, user.getPassword())) {
                    request.setAttribute("errorMessage", "Current password is incorrect");
                    request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                    return;
                }

                // Update password
                user.setPassword(PasswordHasher.hashPassword(newPassword));
                boolean success = userDAO.update(user);

                if (success) {
                    request.setAttribute("successMessage", "Password changed successfully");
                } else {
                    request.setAttribute("errorMessage", "Failed to change password");
                }

                request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
                return;
            }

            // If admin not found in either table, redirect to login
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/admin/login");

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error changing password: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/admin-profile.jsp").forward(request, response);
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