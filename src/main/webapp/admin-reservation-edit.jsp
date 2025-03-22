<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="com.tablebooknow.model.user.User" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Reservation | Gourmet Reserve Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            background: var(--dark);
            font-family: 'Roboto', sans-serif;
            color: var(--text);
        }

        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: 100vh;
        }

        .sidebar {
            background: rgba(20, 20, 20, 0.95);
            padding: 2rem;
            border-right: 1px solid rgba(212, 175, 55, 0.3);
        }

        .main-content {
            padding: 2rem;
            background: rgba(30, 30, 30, 0.95);
            overflow-y: auto;
        }

        .nav-item {
            padding: 1rem;
            margin: 0.5rem 0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text);
            text-decoration: none;
            display: block;
        }

        .nav-item:hover {
            background: rgba(212, 175, 55, 0.1);
        }

        .active-section {
            background: rgba(212, 175, 55, 0.2);
            color: var(--gold);
        }

        .card {
            background: rgba(40, 40, 40, 0.6);
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .page-title {
            color: var(--gold);
            font-size: 2rem;
            font-family: 'Playfair Display', serif;
        }

        .action-btn {
            padding: 0.5rem 1rem;
            margin: 0 0.3rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            transition: transform 0.3s ease;
            display: inline-block;
            text-decoration: none;
            text-align: center;
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .save-btn { background: var(--gold); color: var(--dark); }
        .cancel-btn { background: #dc3545; color: white; }
        .back-btn { background: #6c757d; color: white; }

        .form-section {
            margin-bottom: 2rem;
        }

        .section-title {
            color: var(--gold);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            font-size: 0.9rem;
            color: #aaa;
            margin-bottom: 0.5rem;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--gold);
        }

        .form-select {
            width: 100%;
            padding: 0.8rem;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-select:focus {
            outline: none;
            border-color: var(--gold);
        }

        .form-textarea {
            width: 100%;
            padding: 0.8rem;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
            font-size: 1rem;
            resize: vertical;
            min-height: 100px;
            transition: border-color 0.3s;
        }

        .form-textarea:focus {
            outline: none;
            border-color: var(--gold);
        }

        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        .alert-success {
            background: rgba(40, 167, 69, 0.2);
            border: 1px solid rgba(40, 167, 69, 0.4);
            color: #28a745;
        }

        .alert-danger {
            background: rgba(220, 53, 69, 0.2);
            border: 1px solid rgba(220, 53, 69, 0.4);
            color: #dc3545;
        }

        .user-info {
            background: rgba(0, 0, 0, 0.2);
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .user-info p {
            margin-bottom: 0.5rem;
        }

        .user-info strong {
            color: var(--gold);
        }

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if admin is logged in
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String adminUsername = (String) session.getAttribute("adminUsername");

        // Get reservation details from request
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        User user = (User) request.getAttribute("user");

        if (reservation == null) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        // Format date and time for form display
        String formattedDate = reservation.getReservationDate();
        String formattedTime = reservation.getReservationTime();
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>

            <div style="display: flex; align-items: center; margin-bottom: 2rem;">
                <div style="width: 30px; height: 30px; background: var(--gold); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 10px; color: var(--dark); font-weight: bold;">
                    <%= adminUsername.charAt(0) %>
                </div>
                <span><%= adminUsername %></span>
            </div>

            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">📊 Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item active-section">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item">🍽️ Table Management</a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item">👥 User Management</a>

            <a href="${pageContext.request.contextPath}/admin/logout" class="nav-item" style="margin-top: 2rem; color: #dc3545;">🚪 Logout</a>
        </div>

        <div class="main-content">
            <!-- Success/Error Message Alerts -->
            <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("successMessage") %>
            </div>
            <% } %>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("errorMessage") %>
            </div>
            <% } %>

            <div class="page-header">
                <h1 class="page-title">Edit Reservation</h1>
                <a href="${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>" class="action-btn back-btn">Back to Details</a>
            </div>

            <div class="card">
                <% if (user != null) { %>
                <div class="user-info">
                    <h3 style="margin-bottom: 1rem; color: var(--gold);">Customer Information</h3>
                    <p><strong>Username:</strong> <%= user.getUsername() %></p>
                    <p><strong>Email:</strong> <%= user.getEmail() != null ? user.getEmail() : "Not provided" %></p>
                    <p><strong>Phone:</strong> <%= user.getPhone() != null ? user.getPhone() : "Not provided" %></p>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/admin/reservations/update" method="post">
                    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">

                    <div class="form-section">
                        <h2 class="section-title">Reservation Details</h2>
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">Reservation Date</label>
                                <input type="date" class="form-control" name="reservationDate" value="<%= formattedDate %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Reservation Time</label>
                                <input type="time" class="form-control" name="reservationTime" value="<%= formattedTime %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Duration (hours)</label>
                                <select class="form-select" name="duration">
                                    <option value="1" <%= reservation.getDuration() == 1 ? "selected" : "" %>>1 hour</option>
                                    <option value="2" <%= reservation.getDuration() == 2 ? "selected" : "" %>>2 hours</option>
                                    <option value="3" <%= reservation.getDuration() == 3 ? "selected" : "" %>>3 hours</option>
                                    <option value="4" <%= reservation.getDuration() == 4 ? "selected" : "" %>>4 hours</option>
                                    <option value="5" <%= reservation.getDuration() == 5 ? "selected" : "" %>>5 hours</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Table ID</label>
                                <input type="text" class="form-control" name="tableId" value="<%= reservation.getTableId() %>" required>
                                <small style="font-size: 0.8rem; color: #aaa; margin-top: 0.3rem; display: block;">
                                    Format: [type][floor]-[number] (e.g., f1-3, r2-5)
                                </small>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="status">
                                    <option value="pending" <%= "pending".equals(reservation.getStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="confirmed" <%= "confirmed".equals(reservation.getStatus()) ? "selected" : "" %>>Confirmed</option>
                                    <option value="cancelled" <%= "cancelled".equals(reservation.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Special Requests</label>
                            <textarea class="form-textarea" name="specialRequests"><%= reservation.getSpecialRequests() != null ? reservation.getSpecialRequests() : "" %></textarea>
                        </div>
                    </div>

                    <div style="margin-top: 2rem; display: flex; gap: 1rem;">
                        <button type="submit" class="action-btn save-btn">Save Changes</button>
                        <a href="${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>" class="action-btn back-btn">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.style.display = 'none', 500);
            });
        }, 5000);
    </script>
</body>
</html>