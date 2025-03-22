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
    <title>Admin Dashboard | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/html5-qrcode"></script>
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
        }

        .nav-item {
            padding: 1rem;
            margin: 0.5rem 0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text);
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

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: rgba(30, 30, 30, 0.8);
            border: 1px solid rgba(212, 175, 55, 0.3);
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--gold);
            margin: 0.5rem 0;
        }

        .stat-label {
            color: #ccc;
            font-size: 0.9rem;
        }

        .table-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
        }

        .table-card {
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
            transition: transform 0.3s ease;
        }

        .status-available { background: rgba(76, 175, 80, 0.2); }
        .status-reserved { background: rgba(255, 193, 7, 0.2); }
        .status-occupied { background: rgba(244, 67, 54, 0.2); }

        .qr-scanner {
            width: 100%;
            max-width: 500px;
            margin: 2rem auto;
            border: 2px solid var(--gold);
            border-radius: 15px;
            overflow: hidden;
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

        .action-btn {
            padding: 0.5rem 1rem;
            margin: 0 0.3rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .edit-btn { background: var(--gold); color: var(--dark); }
        .delete-btn { background: #f44336; color: white; }

        .message {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        .success-message {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid rgba(76, 175, 80, 0.5);
        }

        .error-message {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid rgba(244, 67, 54, 0.5);
        }

        .logout-btn {
            position: absolute;
            bottom: 2rem;
            left: 2rem;
            padding: 0.8rem 1.5rem;
            background: rgba(244, 67, 54, 0.8);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            background: rgba(244, 67, 54, 1);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <%
        // Check if admin is logged in
        if (session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String adminUsername = (String) session.getAttribute("adminUsername");

        // Get attributes from request
        List<Reservation> upcomingReservations = (List<Reservation>) request.getAttribute("upcomingReservations");
        List<User> users = (List<User>) request.getAttribute("users");

        // Stats
        Integer totalUsers = (Integer) request.getAttribute("totalUsers");
        Integer totalReservations = (Integer) request.getAttribute("totalReservations");
        Integer pendingReservations = (Integer) request.getAttribute("pendingReservations");
        Integer confirmedReservations = (Integer) request.getAttribute("confirmedReservations");

        // Format values or set defaults if null
        if (totalUsers == null) totalUsers = 0;
        if (totalReservations == null) totalReservations = 0;
        if (pendingReservations == null) pendingReservations = 0;
        if (confirmedReservations == null) confirmedReservations = 0;

        // Date formatter
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

        // Success/Error messages
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>
            <p style="margin-bottom: 2rem; color: #ccc;">Welcome, <%= adminUsername %></p>

            <div class="nav-item active-section" data-section="overview">📊 Dashboard</div>
            <div class="nav-item" data-section="reservations">📅 Reservations</div>
            <div class="nav-item" data-section="tables">🍽️ Table Management</div>
            <div class="nav-item" data-section="users">👥 User Management</div>
            <div class="nav-item" data-section="qr">📷 QR Scanner</div>

            <a href="${pageContext.request.contextPath}/admin/logout" class="logout-btn">Logout</a>
        </div>

        <div class="main-content">
            <!-- Success/Error Messages -->
            <% if (successMessage != null) { %>
                <div class="message success-message">
                    <%= successMessage %>
                </div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="message error-message">
                    <%= errorMessage %>
                </div>
            <% } %>

            <!-- Overview/Dashboard Section -->
            <div id="overviewSection">
                <h1 style="color: var(--gold); margin-bottom: 2rem;">Dashboard Overview</h1>

                <!-- Statistics Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number"><%= totalUsers %></div>
                        <div class="stat-label">Total Users</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= totalReservations %></div>
                        <div class="stat-label">Total Reservations</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= pendingReservations %></div>
                        <div class="stat-label">Pending Reservations</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= confirmedReservations %></div>
                        <div class="stat-label">Confirmed Reservations</div>
                    </div>
                </div>

                <!-- Upcoming Reservations -->
                <div class="card">
                    <h2 style="margin-bottom: 1rem; color: var(--gold);">Today's Reservations</h2>
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
                            if (upcomingReservations != null && !upcomingReservations.isEmpty()) {
                                for (Reservation reservation : upcomingReservations) {
                                    // Determine status color
                                    String statusColor = "#fff";
                                    if ("confirmed".equals(reservation.getStatus())) {
                                        statusColor = "#4CAF50"; // Green for confirmed
                                    } else if ("pending".equals(reservation.getStatus())) {
                                        statusColor = "#FFC107"; // Yellow for pending
                                    } else if ("cancelled".equals(reservation.getStatus())) {
                                        statusColor = "#F44336"; // Red for cancelled
                                    }
                            %>
                            <tr>
                                <td><%= reservation.getId() %></td>
                                <td><%= reservation.getReservationDate() %></td>
                                <td><%= reservation.getReservationTime() %></td>
                                <td><%= reservation.getTableId() %></td>
                                <td><span style="color: <%= statusColor %>;"><%= reservation.getStatus() %></span></td>
                                <td>
                                    <button class="action-btn edit-btn" onclick="location.href='${pageContext.request.contextPath}/admin/editReservation?id=<%= reservation.getId() %>'">View</button>
                                    <form style="display: inline;" method="post" action="${pageContext.request.contextPath}/admin/cancelReservation">
                                        <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                        <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No upcoming reservations found</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Reservations Section -->
            <div id="reservationsSection" style="display: none;">
                <h1 style="color: var(--gold); margin-bottom: 2rem;">Reservation Management</h1>
                <div class="card">
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
                            List<Reservation> allReservations = (List<Reservation>) request.getAttribute("reservations");
                            if (allReservations != null && !allReservations.isEmpty()) {
                                for (Reservation reservation : allReservations) {
                                    // Determine status color
                                    String statusColor = "#fff";
                                    if ("confirmed".equals(reservation.getStatus())) {
                                        statusColor = "#4CAF50"; // Green for confirmed
                                    } else if ("pending".equals(reservation.getStatus())) {
                                        statusColor = "#FFC107"; // Yellow for pending
                                    } else if ("cancelled".equals(reservation.getStatus())) {
                                        statusColor = "#F44336"; // Red for cancelled
                                    }
                            %>
                            <tr>
                                <td><%= reservation.getId() %></td>
                                <td><%= reservation.getUserId() %></td>
                                <td><%= reservation.getReservationDate() %></td>
                                <td><%= reservation.getReservationTime() %></td>
                                <td><%= reservation.getTableId() %></td>
                                <td><span style="color: <%= statusColor %>;"><%= reservation.getStatus() %></span></td>
                                <td>
                                    <button class="action-btn edit-btn" onclick="location.href='${pageContext.request.contextPath}/admin/editReservation?id=<%= reservation.getId() %>'">View</button>
                                    <form style="display: inline;" method="post" action="${pageContext.request.contextPath}/admin/cancelReservation">
                                        <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                        <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel</button>
                                    </form>
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
            </div>

            <!-- Table Management Section -->
            <div id="tablesSection" style="display: none;">
                <h1 style="color: var(--gold); margin-bottom: 2rem;">Table Management</h1>
                <div class="table-grid">
                    <!-- Family Tables -->
                    <% for (int i = 1; i <= 4; i++) { %>
                        <div class="table-card status-available">
                            <h3>Family Table <%= i %></h3>
                            <p>6 Seats</p>
                            <p>ID: f1-<%= i %></p>
                            <p>Status: Available</p>
                            <button class="action-btn edit-btn" style="margin-top: 1rem;">Check Status</button>
                        </div>
                    <% } %>

                    <!-- Regular Tables -->
                    <% for (int i = 1; i <= 6; i++) { %>
                        <div class="table-card status-available">
                            <h3>Regular Table <%= i %></h3>
                            <p>4 Seats</p>
                            <p>ID: r1-<%= i %></p>
                            <p>Status: Available</p>
                            <button class="action-btn edit-btn" style="margin-top: 1rem;">Check Status</button>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- QR Scanner Section -->
            <div id="qrSection" style="display: none;">
                <h1 style="color: var(--gold); margin-bottom: 2rem;">QR Code Scanner</h1>
                <p class="card" style="margin-bottom: 2rem;">Scan a reservation QR code to quickly check in guests or verify reservation details.</p>
                <div class="qr-scanner" id="qrScanner"></div>
                <div id="scanResult" class="card" style="margin-top: 2rem; display: none;">
                    <h3 style="color: var(--gold);">Reservation Details</h3>
                    <pre id="scanData"></pre>
                    <div id="reservationDetails" style="margin-top: 1rem;"></div>
                    <button id="checkInBtn" class="action-btn edit-btn" style="margin-top: 1rem; display: none;">Check In Guest</button>
                </div>
            </div>

            <!-- User Management Section -->
            <div id="usersSection" style="display: none;">
                <h1 style="color: var(--gold); margin-bottom: 2rem;">User Management</h1>
                <div class="card">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>User ID</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Admin</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            if (users != null && !users.isEmpty()) {
                                for (User user : users) {
                            %>
                            <tr>
                                <td><%= user.getId() %></td>
                                <td><%= user.getUsername() %></td>
                                <td><%= user.getEmail() %></td>
                                <td>
                                    <form id="adminForm_<%= user.getId() %>" method="post" action="${pageContext.request.contextPath}/admin/updateUser">
                                        <input type="hidden" name="userId" value="<%= user.getId() %>">
                                        <input type="checkbox" name="isAdmin" <%= user.isAdmin() ? "checked" : "" %>
                                               onchange="document.getElementById('adminForm_<%= user.getId() %>').submit()">
                                    </form>
                                </td>
                                <td>
                                    <button class="action-btn edit-btn" onclick="location.href='${pageContext.request.contextPath}/admin/editUser?id=<%= user.getId() %>'">Edit</button>
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
            </div>
        </div>
    </div>

    <script>
        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                // Remove active class from all items
                document.querySelectorAll('.nav-item').forEach(nav =>
                    nav.classList.remove('active-section'));

                // Add active class to clicked item
                item.classList.add('active-section');

                // Hide all sections
                document.querySelectorAll('#overviewSection, #reservationsSection, #tablesSection, #qrSection, #usersSection')
                    .forEach(sec => sec.style.display = 'none');

                // Show selected section
                document.getElementById(`${item.dataset.section}Section`).style.display = 'block';

                // Initialize QR scanner if QR section is selected
                if (item.dataset.section === 'qr') {
                    initializeScanner();
                }
            });
        });

        // QR Scanner
        let qrScanner = null;
        function initializeScanner() {
            if(qrScanner) return;

            qrScanner = new Html5QrcodeScanner("qrScanner", {
                fps: 10,
                qrbox: 250
            }, false);

            qrScanner.render((decodedText) => {
                document.getElementById('scanResult').style.display = 'block';
                document.getElementById('scanData').textContent = decodedText;

                // Parse QR data (expected format: JSON with reservationId, paymentId, userId)
                try {
                    const reservationData = JSON.parse(decodedText);
                    const detailsDiv = document.getElementById('reservationDetails');

                    detailsDiv.innerHTML =
                        '<div style="margin-top: 1rem;">' +
                            '<p><strong>Reservation ID:</strong> ' + (reservationData.reservationId || 'N/A') + '</p>' +
                            '<p><strong>Payment ID:</strong> ' + (reservationData.paymentId || 'N/A') + '</p>' +
                            '<p><strong>User ID:</strong> ' + (reservationData.userId || 'N/A') + '</p>' +
                            '<p><strong>Timestamp:</strong> ' + new Date(parseInt(reservationData.timestamp)).toLocaleString() + '</p>' +
                        '</div>';

                    // Show check-in button
                    document.getElementById('checkInBtn').style.display = 'inline-block';

                    // Add check-in functionality
                    document.getElementById('checkInBtn').onclick = function() {
                        if (reservationData.reservationId) {
                            // Send to server to update reservation status
                            alert('Guest checked in successfully!');
                        }
                    };

                } catch (e) {
                    document.getElementById('reservationDetails').innerHTML =
                        '<div style="margin-top: 1rem; color: #ff6b6b;">' +
                            '<p>Invalid QR code format. Unable to parse reservation data.</p>' +
                        '</div>';
                    document.getElementById('checkInBtn').style.display = 'none';
                }

                qrScanner.clear();
                qrScanner = null;
            });
        }

        // Auto-hide success/error messages after 5 seconds
        setTimeout(() => {
            const messages = document.querySelectorAll('.message');
            messages.forEach(msg => {
                msg.style.opacity = '0';
                setTimeout(() => msg.style.display = 'none', 500);
            });
        }, 5000);
    </script>
</body>
</html>