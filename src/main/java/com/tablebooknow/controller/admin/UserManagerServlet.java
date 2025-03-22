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
 * Servlet for handling admin user management functions
 */
@WebServlet("/admin/users/*")
public class UserManagerServlet extends HttpServlet {
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
        if (pathInfo == null) {
            pathInfo = "/";
        }

        switch (pathInfo) {
            case "/":
                // List all users
                listUsers(request, response);
                break;
            case "/view":
                // View specific user
                viewUser(request, response);
                break;
            case "/add":
                // Show add user form
                showAddUserForm(request, response);
                break;
            case "/edit":
                // Show edit user form
                showEditUserForm(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/users/");
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
            case "/add":
                // Add new user
                addUser(request, response);
                break;
            case "/edit":
                // Update user
                updateUser(request, response);
                break;
            case "/delete":
                // Delete user
                deleteUser(request, response);
                break;
            case "/toggleAdmin":
                // Toggle admin status
                toggleAdminStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                break;
        }
    }

    /**
     * List all users
     */
    private void listUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<User> users = userDAO.findAll();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/WEB-INF/admin/user-list.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading users: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/user-list.jsp").forward(request, response);
        }
    }

    /**
     * View specific user details
     */
    private void viewUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users/");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                return;
            }

            // Get user's reservations
            List<Reservation> userReservations = reservationDAO.findByUserId(userId);

            request.setAttribute("user", user);
            request.setAttribute("userReservations", userReservations);
            request.getRequestDispatcher("/WEB-INF/admin/user-view.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        }
    }

    /**
     * Show add user form
     */
    private void showAddUserForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/admin/user-add.jsp").forward(request, response);
    }

    /**
     * Add new user
     */
    private void addUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String isAdminStr = request.getParameter("isAdmin");

        // Validate input
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Username and password are required");
            request.getRequestDispatcher("/WEB-INF/admin/user-add.jsp").forward(request, response);
            return;
        }

        try {
            // Check if username already exists
            if (userDAO.findByUsername(username) != null) {
                request.setAttribute("errorMessage", "Username already exists");
                request.getRequestDispatcher("/WEB-INF/admin/user-add.jsp").forward(request, response);
                return;
            }

            // Check if email already exists
            if (email != null && !email.trim().isEmpty() && userDAO.findByEmail(email) != null) {
                request.setAttribute("errorMessage", "Email already exists");
                request.getRequestDispatcher("/WEB-INF/admin/user-add.jsp").forward(request, response);
                return;
            }

            // Create new user
            User user = new User();
            user.setUsername(username);
            user.setPassword(PasswordHasher.hashPassword(password));
            user.setEmail(email);
            user.setPhone(phone);
            user.setAdmin("on".equals(isAdminStr) || "true".equals(isAdminStr));

            userDAO.create(user);

            request.setAttribute("successMessage", "User created successfully");
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error creating user: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/user-add.jsp").forward(request, response);
        }
    }

    /**
     * Show edit user form
     */
    private void showEditUserForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users/");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                return;
            }

            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/admin/user-edit.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        }
    }

    /**
     * Update user
     */
    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String isAdminStr = request.getParameter("isAdmin");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users/");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                return;
            }

            // Check if username is already taken by another user
            User existingUser = userDAO.findByUsername(username);
            if (existingUser != null && !existingUser.getId().equals(userId)) {
                request.setAttribute("errorMessage", "Username already exists");
                request.getRequestDispatcher("/WEB-INF/admin/user-edit.jsp").forward(request, response);
                return;
            }

            // Check if email is already taken by another user
            if (email != null && !email.trim().isEmpty()) {
                existingUser = userDAO.findByEmail(email);
                if (existingUser != null && !existingUser.getId().equals(userId)) {
                    request.setAttribute("errorMessage", "Email already exists");
                    request.getRequestDispatcher("/WEB-INF/admin/user-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Update user properties
            user.setUsername(username);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAdmin("on".equals(isAdminStr) || "true".equals(isAdminStr));

            // Only update password if provided
            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(PasswordHasher.hashPassword(password));
            }

            userDAO.update(user);

            request.setAttribute("successMessage", "User updated successfully");
            response.sendRedirect(request.getContextPath() + "/admin/users/view?id=" + userId);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating user: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/user-edit.jsp").forward(request, response);
        }
    }

    /**
     * Delete user
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users/");
            return;
        }

        try {
            // Check if user exists
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                return;
            }

            // Delete the user
            userDAO.delete(userId);

            request.setAttribute("successMessage", "User deleted successfully");
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error deleting user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        }
    }

    /**
     * Toggle admin status
     */
    private void toggleAdminStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("id");

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users/");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                response.sendRedirect(request.getContextPath() + "/admin/users/");
                return;
            }

            // Toggle admin status
            user.setAdmin(!user.isAdmin());

            userDAO.update(user);

            request.setAttribute("successMessage",
                    user.isAdmin() ? "User is now an administrator" : "Administrator privileges revoked");
            response.sendRedirect(request.getContextPath() + "/admin/users/view?id=" + userId);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error updating user: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/users/");
        }
    }
}