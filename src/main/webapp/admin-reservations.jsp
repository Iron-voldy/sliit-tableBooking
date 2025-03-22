<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="com.tablebooknow.model.user.User" %>
<%@ page import="com.tablebooknow.dao.UserDAO" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Management | Gourmet Reserve</title>
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

        .status-label {
            padding: 0.3rem 0.8rem;
            border-radius: 12px;
            font-size: 0.9rem;
            display: inline-block;
        }

        .status-confirmed { background: rgba(76, 175, 80, 0.2); color: #4CAF50; }
        .status-pending { background: rgba(255, 193, 7, 0.2); color: #FFC107; }
        .status-cancelled { background: rgba(244, 67, 54, 0.2); color: #F44336; }

        .filters {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .filter-select {
            padding: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
        }

        .reservation-details {
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

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .reservation-details {
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

        // Get reservations from request attributes
        List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");

        // Get specific reservation if ID was provided
        Reservation specificReservation = null;
        String reservationId = request.getParameter("id");

        if (reservationId != null && reservations != null) {
            for (Reservation res : reservations) {
                if (res.getId().equals(reservationId)) {
                    specificReservation = res;
                    break;
                }
            }
        }

        // Create UserDAO instance to get user information
        UserDAO userDAO = new UserDAO();
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>

            <div class="user-info" style="margin-bottom: 2rem;">
                <div class="user-avatar"><%= adminUsername.charAt(0) %></div>
                <span><%= adminUsername %></span>
            </div>

            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">📊 Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item active-section">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item">🍽️ Table Management</a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item">👥 User Management</a>
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

            <% if (specificReservation != null) { %>
            <!-- Single Reservation View -->
            <div class="card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <h1 style="color: var(--gold);">Reservation Details</h1>
                    <a href="${pageContext.request.contextPath}/admin/reservations" class="action-btn view-btn">Back to All Reservations</a>
                </div>

                <div class="reservation-details">
                    <div class="detail-item">
                        <div class="detail-label">Reservation ID</div>
                        <div><%= specificReservation.getId() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Status</div>
                        <div>
                            <span class="status-label status-<%= specificReservation.getStatus() %>">
                                <%= specificReservation.getStatus().substring(0, 1).toUpperCase() + specificReservation.getStatus().substring(1) %>
                            </span>
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">User ID</div>
                        <div><%= specificReservation.getUserId() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">User Details</div>
                        <div>
                            <%
                                try {
                                    User user = userDAO.findById(specificReservation.getUserId());
                                    if (user != null) {
                                        out.println(user.getUsername() + " - " + user.getEmail());
                                    } else {
                                        out.println("User not found");
                                    }
                                } catch (Exception e) {
                                    out.println("Error loading user: " + e.getMessage());
                                }
                            %>
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Reservation Date</div>
                        <div><%= specificReservation.getReservationDate() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Reservation Time</div>
                        <div><%= specificReservation.getReservationTime() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Duration</div>
                        <div><%= specificReservation.getDuration() %> hours</div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Table ID</div>
                        <div><%= specificReservation.getTableId() != null ? specificReservation.getTableId() : "Not assigned" %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Booking Type</div>
                        <div><%= specificReservation.getBookingType() %></div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Created At</div>
                        <div><%= specificReservation.getCreatedAt() %></div>
                    </div>
                </div>

                <div class="detail-item" style="grid-column: span 2;">
                    <div class="detail-label">Special Requests</div>
                    <div style="background: rgba(0,0,0,0.2); padding: 1rem; border-radius: 5px;">
                        <%= specificReservation.getSpecialRequests() != null && !specificReservation.getSpecialRequests().isEmpty()
                            ? specificReservation.getSpecialRequests()
                            : "No special requests" %>
                    </div>
                </div>

                <div style="margin-top: 2rem; display: flex; gap: 1rem;">
                    <% if (!"cancelled".equals(specificReservation.getStatus())) { %>
                    <form action="${pageContext.request.contextPath}/admin/cancelReservation" method="post" style="display: inline;">
                        <input type="hidden" name="reservationId" value="<%= specificReservation.getId() %>">
                        <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel Reservation</button>
                    </form>
                    <% } %>
                </div>
            </div>

            <% } else { %>
            <!-- All Reservations View -->
            <div class="card">
                <h1 style="color: var(--gold); margin-bottom: 1.5rem;">All Reservations</h1>

                <div class="filters">
                    <select id="statusFilter" class="filter-select">
                        <option value="all">All Statuses</option>
                        <option value="pending">Pending</option>
                        <option value="confirmed">Confirmed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>

                    <select id="dateFilter" class="filter-select">
                        <option value="all">All Dates</option>
                        <option value="today">Today</option>
                        <option value="tomorrow">Tomorrow</option>
                        <option value="upcoming">Upcoming</option>
                        <option value="past">Past</option>
                    </select>

                    <input type="text" id="searchInput" placeholder="Search by ID or User"
                           style="padding: 0.5rem; background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(212, 175, 55, 0.3); border-radius: 6px; color: var(--text);">
                </div>

                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Reservation ID</th>
                            <th>User ID</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Table</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (reservations != null && !reservations.isEmpty()) {
                            for (Reservation reservation : reservations) {
                        %>
                        <tr data-status="<%= reservation.getStatus() %>" data-date="<%= reservation.getReservationDate() %>">
                            <td><%= reservation.getId().substring(0, 8) %>...</td>
                            <td><%= reservation.getUserId().substring(0, 8) %>...</td>
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
                                <% if (!"cancelled".equals(reservation.getStatus())) { %>
                                <form action="${pageContext.request.contextPath}/admin/cancelReservation" method="post" style="display: inline;">
                                    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                    <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel</button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center;">No reservations found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Filtering logic
        document.getElementById('statusFilter').addEventListener('change', filterReservations);
        document.getElementById('dateFilter').addEventListener('change', filterReservations);
        document.getElementById('searchInput').addEventListener('input', filterReservations);

        function filterReservations() {
            const statusFilter = document.getElementById('statusFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;
            const searchInput = document.getElementById('searchInput').value.toLowerCase();

            const rows = document.querySelectorAll('.data-table tbody tr');

            const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format

            // Calculate tomorrow's date
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const tomorrowStr = tomorrow.toISOString().split('T')[0];

            rows.forEach(row => {
                const status = row.getAttribute('data-status');
                const date = row.getAttribute('data-date');
                const rowText = row.textContent.toLowerCase();

                // Status filter
                const statusMatch = statusFilter === 'all' || status === statusFilter;

                // Date filter
                let dateMatch = true;
                if (dateFilter === 'today') {
                    dateMatch = date === today;
                } else if (dateFilter === 'tomorrow') {
                    dateMatch = date === tomorrowStr;
                } else if (dateFilter === 'upcoming') {
                    dateMatch = date >= today;
                } else if (dateFilter === 'past') {
                    dateMatch = date < today;
                }

                // Search filter
                const searchMatch = searchInput === '' || rowText.includes(searchInput);

                // Show/hide row based on all filters
                if (statusMatch && dateMatch && searchMatch) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>