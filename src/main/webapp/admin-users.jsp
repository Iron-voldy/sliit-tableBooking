<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tablebooknow.model.user.User" %>
<%@ page import="com.tablebooknow.dao.ReservationDAO" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management | Gourmet Reserve</title>
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

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .data-table th, .data-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(212, 175, 55, 0.1);
        }

        .data-table th {
            background: rgba(212, 175, 55, 0.1);
            color: var(--gold);
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
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .edit-btn { background: var(--gold); color: var(--dark); }
        .delete-btn { background: #f44336; color: white; }
        .view-btn { background: #3f51b5; color: white; }

        .user-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .detail-item {
            margin-bottom: 1rem;
        }

        .detail-label {
            font-weight: bold;
            color: var(--gold);
            margin-bottom: 0.3rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .user-avatar {
            width: 30px;
            height: 30px;
            background: var(--gold);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: var(--dark);
        }

        .logout-btn {
            margin-top: 2rem;
            width: 100%;
            padding: 0.8rem;
            background: rgba(244, 67, 54, 0.2);
            color: #F44336;
            border: 1px solid rgba(244, 67, 54, 0.4);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background: rgba(244, 67, 54, 0.3);
        }

        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        .alert-success {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid rgba(76, 175, 80, 0.4);
            color: #4CAF50;
        }

        .alert-error {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid rgba(244, 67, 54, 0.4);
            color: #F44336;
        }

        .search-box {
            width: 100%;
            padding: 0.8rem;
            margin-bottom: 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
        }

        .admin-badge {
            background: var(--gold);
            color: var(--dark);
            padding: 0.2rem 0.5rem;
            border-radius: 10px;
            font-size: 0.8rem;
            font-weight: bold;
        }

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .user-details {
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

        // Get users from request attributes
        List<User> users = (List<User>) request.getAttribute("users");

        // Get specific user if ID was provided
        User specificUser = null;
        String userId = request.getParameter("id");

        if (userId != null && users != null) {
            for (User user : users) {
                if (user.getId().equals(userId)) {
                    specificUser = user;
                    break;
                }
            }
        }

        // Create ReservationDAO instance to get user reservations
        ReservationDAO reservationDAO = new ReservationDAO();
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>

            <div class="user-info" style="margin-bottom: 2rem;">
                <div class="user-avatar"><%= adminUsername.charAt(0) %></div>
                <span><%= adminUsername %></span>
            </div>

            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">📊 Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item">🍽️ Table Management</a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item active-section">👥 User Management</a>
            <a href="${pageContext.request.contextPath}/admin/qr" class="nav-item">📷 QR Scanner</a>

            <form action="${pageContext.request.contextPath}/admin/logout" method="get">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>

        <div class="main-content">
            <!-- Success/Error Message Alerts -->
            <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("successMessage") %>
            </div>
            <% } %>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("errorMessage") %>
            </div>
            <% } %>

            <% if (specificUser != null) { %>
            <!-- Single User View -->
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <h1 style="color: var(--gold);">User Details</h1>
                    <a href="${pageContext.request.contextPath}/admin/users" class="action-btn view-btn">Back to All Users</a>
                </div>

                <div class="user-details">
                    <div class="detail-item">
                        <div class="detail-label">User ID</div>
                        <div><%= specificUser.getId() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Username</div>
                        <div><%= specificUser.getUsername() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Email</div>
                        <div><%= specificUser.getEmail() != null ? specificUser.getEmail() : "Not provided" %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Phone</div>
                        <div><%= specificUser.getPhone() != null ? specificUser.getPhone() : "Not provided" %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Admin Status</div>
                        <div>
                            <% if (specificUser.isAdmin()) { %>
                                <span class="admin-badge">Admin</span>
                            <% } else { %>
                                Regular User
                            <% } %>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 2rem;">
                    <h3 style="color: var(--gold); margin-bottom: 1rem;">User Actions</h3>

                    <form action="${pageContext.request.contextPath}/admin/updateUser" method="post" style="display: inline;">
                        <input type="hidden" name="userId" value="<%= specificUser.getId() %>">
                        <input type="hidden" name="isAdmin" value="<%= !specificUser.isAdmin() %>">
                        <button type="submit" class="action-btn edit-btn">
                            <%= specificUser.isAdmin() ? "Remove Admin Status" : "Make Admin" %>
                        </button>
                    </form>
                </div>

                <div style="margin-top: 2rem;">
                    <h3 style="color: var(--gold); margin-bottom: 1rem;">User Reservations</h3>

                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Reservation ID</th>
                                <th>Date</th>
                                <th>Time</th>
                                <th>Table</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                List<com.tablebooknow.model.reservation.Reservation> userReservations =
                                    reservationDAO.findByUserId(specificUser.getId());

                                if (userReservations != null && !userReservations.isEmpty()) {
                                    for (com.tablebooknow.model.reservation.Reservation reservation : userReservations) {
                            %>
                            <tr>
                                <td><%= reservation.getId().substring(0, 8) %>...</td>
                                <td><%= reservation.getReservationDate() %></td>
                                <td><%= reservation.getReservationTime() %></td>
                                <td><%= reservation.getTableId() != null ? reservation.getTableId() : "Not assigned" %></td>
                                <td>
                                    <span class="status-label status-<%= reservation.getStatus() %>">
                                        <%= reservation.getStatus().substring(0, 1).toUpperCase() + reservation.getStatus().substring(1) %>
                                    </span>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/reservations?id=<%= reservation.getId() %>" class="action-btn view-btn">View</a>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No reservations found for this user</td>
                            </tr>
                            <%
                                }
                            } catch (Exception e) {
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center;">Error loading reservations: <%= e.getMessage() %></td>
                            </tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <% } else { %>
            <!-- All Users View -->
            <div class="card">
                <h1 style="color: var(--gold); margin-bottom: 1.5rem;">User Management</h1>

                <input type="text" id="userSearch" class="search-box" placeholder="Search by username or email">

                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Admin</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (users != null && !users.isEmpty()) {
                            for (User user : users) {
                        %>
                        <tr data-username="<%= user.getUsername().toLowerCase() %>"
                            data-email="<%= user.getEmail() != null ? user.getEmail().toLowerCase() : "" %>">
                            <td><%= user.getUsername() %></td>
                            <td><%= user.getEmail() != null ? user.getEmail() : "Not provided" %></td>
                            <td><%= user.getPhone() != null ? user.getPhone() : "Not provided" %></td>
                            <td>
                                <% if (user.isAdmin()) { %>
                                    <span class="admin-badge">Admin</span>
                                <% } else { %>
                                    No
                                <% } %>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/users?id=<%= user.getId() %>" class="action-btn view-btn">View</a>

                                <form action="${pageContext.request.contextPath}/admin/updateUser" method="post" style="display: inline;">
                                    <input type="hidden" name="userId" value="<%= user.getId() %>">
                                    <input type="hidden" name="isAdmin" value="<%= !user.isAdmin() %>">
                                    <button type="submit" class="action-btn edit-btn">
                                        <%= user.isAdmin() ? "Remove Admin" : "Make Admin" %>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="5" style="text-align: center;">No users found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // User search functionality
        document.getElementById('userSearch').addEventListener('input', function() {
            const searchValue = this.value.toLowerCase();
            const userRows = document.querySelectorAll('.data-table tbody tr');

            userRows.forEach(row => {
                const username = row.getAttribute('data-username');
                const email = row.getAttribute('data-email');

                if (username.includes(searchValue) || email.includes(searchValue)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>