package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.model.user.User;
import com.tablebooknow.model.reservation.Reservation;
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
 * Servlet for admin user management
 */
@WebServlet("/admin/users/*")
public class AdminUserServlet extends HttpServlet {
    private UserDAO userDAO;
    private ReservationDAO reservationDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        reservationDAO = new ReservationDAO();
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
            listAllUsers(request, response);
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/view":
                viewUser(request, response);
                break;
            case "/edit":
                showEditForm(request, response);
                break;
            default:
                listAllUsers(request, response);
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
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        // Handle specific paths
        switch (pathInfo) {
            case "/update":
                updateUser(request, response);
                break;
            case "/updateAdmin":
                toggleAdminStatus(request, response);
                break;
            case "/delete":
                deleteUser(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/users");
                break;
        }
    }

    private void listAllUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<User> users = userDAO.findAll();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin-users.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading users: " + e.getMessage());
            request.getRequestDispatcher("/admin-users.jsp").forward(request, response);
        }
    }

    private void viewUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("id");
        if (userId == null || userId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            List<Reservation> userReservations = reservationDAO.findByUserId(userId);

            request.setAttribute("user", user);
            request.setAttribute("userReservations", userReservations);
            request.getRequestDispatcher("/admin-user-details.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for showing user edit form
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for updating user
    }

    private void toggleAdminStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String isAdminStr = request.getParameter("isAdmin");

        if (userId == null || userId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            boolean isAdmin = "on".equals(isAdminStr) || "true".equals(isAdminStr);
            user.setAdmin(isAdmin);

            boolean success = userDAO.update(user);

            if (success) {
                request.setAttribute("successMessage",
                        isAdmin ? "User is now an administrator" : "Administrator privileges revoked");
            } else {
                request.setAttribute("errorMessage", "Failed to update user admin status");
            }

            response.sendRedirect(request.getContextPath() + "/admin/users");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating user admin status: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for deleting user
    }
}