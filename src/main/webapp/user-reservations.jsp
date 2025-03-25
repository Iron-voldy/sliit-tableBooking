<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reservations | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
            --glass: rgba(255, 255, 255, 0.05);
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
            background-image:
                linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)),
                url('${pageContext.request.contextPath}/assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
            color: var(--text);
            padding-top: 80px;
        }

        .header-nav {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            padding: 1.5rem 5%;
            background: rgba(26, 26, 26, 0.95);
            backdrop-filter: blur(10px);
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.8rem;
            color: var(--gold);
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
        }

        .nav-links a {
            color: var(--text);
            text-decoration: none;
            font-family: 'Roboto', sans-serif;
            font-weight: 400;
            transition: color 0.3s ease;
        }

        .nav-links a:hover {
            color: var(--gold);
        }

        .container {
            width: 90%;
            max-width: 1200px;
            margin: 2rem auto;
        }

        .page-title {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            color: var(--gold);
            margin-bottom: 1.5rem;
            text-align: center;
        }

        .reservations-tabs {
            display: flex;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .tab {
            padding: 1rem 2rem;
            cursor: pointer;
            transition: all 0.3s;
            background: transparent;
            color: var(--text);
            border: none;
            font-size: 1rem;
            font-family: 'Roboto', sans-serif;
        }

        .tab.active {
            color: var(--gold);
            border-bottom: 2px solid var(--gold);
        }

        .tab:hover:not(.active) {
            background: rgba(212, 175, 55, 0.05);
        }

        .tab-content {
            display: none;
            animation: fadeIn 0.5s ease-out;
        }

        .tab-content.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .reservation-card {
            background: rgba(26, 26, 26, 0.9);
            border-radius: 15px;
            margin-bottom: 1.5rem;
            overflow: hidden;
            border: 1px solid rgba(212, 175, 55, 0.2);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .reservation-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.4);
        }

        .reservation-header {
            background: linear-gradient(135deg, rgba(128, 0, 32, 0.8), rgba(26, 26, 26, 0.8));
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .reservation-date {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            color: var(--gold);
        }

        .reservation-status {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .status-confirmed {
            background: rgba(46, 204, 113, 0.2);
            border: 1px solid rgba(46, 204, 113, 0.5);
            color: #2ecc71;
        }

        .status-pending {
            background: rgba(243, 156, 18, 0.2);
            border: 1px solid rgba(243, 156, 18, 0.5);
            color: #f39c12;
        }

        .status-cancelled {
            background: rgba(231, 76, 60, 0.2);
            border: 1px solid rgba(231, 76, 60, 0.5);
            color: #e74c3c;
        }

        .reservation-body {
            padding: 1.5rem;
        }

        .reservation-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-size: 0.9rem;
            color: var(--gold);
            margin-bottom: 0.3rem;
        }

        .info-value {
            font-size: 1.1rem;
        }

        .reservation-footer {
            padding: 1rem 1.5rem;
            background: rgba(0, 0, 0, 0.2);
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            border: none;
        }

        .btn-view {
            background: rgba(212, 175, 55, 0.2);
            color: var(--gold);
            border: 1px solid rgba(212, 175, 55, 0.5);
        }

        .btn-view:hover {
            background: rgba(212, 175, 55, 0.3);
        }

        .btn-cancel {
            background: rgba(231, 76, 60, 0.2);
            color: #e74c3c;
            border: 1px solid rgba(231, 76, 60, 0.5);
        }

        .btn-cancel:hover {
            background: rgba(231, 76, 60, 0.3);
        }

        .empty-state {
            text-align: center;
            padding: 3rem;
            background: rgba(26, 26, 26, 0.7);
            border-radius: 15px;
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: var(--gold);
            opacity: 0.5;
        }

        .empty-state-text {
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
        }

        .btn-new-reservation {
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            color: white;
            padding: 0.8rem 2rem;
            display: inline-block;
            margin-top: 1rem;
        }

        .btn-new-reservation:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .message {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 8px;
        }

        .success-message {
            background: rgba(46, 204, 113, 0.2);
            border: 1px solid rgba(46, 204, 113, 0.5);
            color: #2ecc71;
        }

        .error-message {
            background: rgba(231, 76, 60, 0.2);
            border: 1px solid rgba(231, 76, 60, 0.5);
            color: #e74c3c;
        }

        @media (max-width: 768px) {
            .reservation-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .reservation-info {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .reservation-footer {
                flex-direction: column;
                gap: 0.5rem;
            }

            .btn {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");

        // Get reservations from request attributes
        List<Reservation> upcomingReservations = (List<Reservation>) request.getAttribute("upcomingReservations");
        List<Reservation> pastReservations = (List<Reservation>) request.getAttribute("pastReservations");
        List<Reservation> cancelledReservations = (List<Reservation>) request.getAttribute("cancelledReservations");

        // Get payment statuses
        Map<String, String> paymentStatuses = (Map<String, String>) request.getAttribute("paymentStatuses");

        // Check if lists exist (avoid NPE)
        if (upcomingReservations == null) upcomingReservations = new ArrayList<>();
        if (pastReservations == null) pastReservations = new ArrayList<>();
        if (cancelledReservations == null) cancelledReservations = new ArrayList<>();
        if (paymentStatuses == null) paymentStatuses = new HashMap<>();

        // Format date
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");

        // Get messages if any
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
    %>

    <!-- Header Navigation -->
    <nav class="header-nav">
        <a href="${pageContext.request.contextPath}/" class="logo">Gourmet Reserve</a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/user/reservations" style="color: var(--gold);">My Reservations</a>
            <a href="${pageContext.request.contextPath}/reservation/dateSelection">New Reservation</a>
            <a href="${pageContext.request.contextPath}/user/profile">Profile</a>
            <a href="${pageContext.request.contextPath}/user/logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <h1 class="page-title">My Reservations</h1>

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

        <!-- Tabs -->
        <div class="reservations-tabs">
            <button class="tab active" data-tab="upcoming">Upcoming</button>
            <button class="tab" data-tab="past">Past</button>
            <button class="tab" data-tab="cancelled">Cancelled</button>
        </div>

        <!-- Upcoming Reservations Tab -->
        <div class="tab-content active" id="upcoming">
            <% if (upcomingReservations.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">📅</div>
                    <div class="empty-state-text">You don't have any upcoming reservations</div>
                    <a href="${pageContext.request.contextPath}/reservation/dateSelection" class="btn btn-new-reservation">Make a Reservation</a>
                </div>
            <% } else { %>
                <% for (Reservation reservation : upcomingReservations) {
                    LocalDate date = LocalDate.parse(reservation.getReservationDate());
                    String formattedDate = date.format(dateFormatter);
                    String tableType = getTableType(reservation.getTableId());
                    String paymentStatus = paymentStatuses.getOrDefault(reservation.getId(), "PENDING");
                %>
                <div class="reservation-card">
                    <div class="reservation-header">
                        <div class="reservation-date"><%= formattedDate %></div>
                        <div class="reservation-status status-<%= reservation.getStatus().toLowerCase() %>">
                            <%= reservation.getStatus().toUpperCase() %>
                        </div>
                    </div>
                    <div class="reservation-body">
                        <div class="reservation-info">
                            <div class="info-item">
                                <div class="info-label">Time</div>
                                <div class="info-value"><%= formatTime(reservation.getReservationTime()) %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Duration</div>
                                <div class="info-value"><%= reservation.getDuration() %> hours</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Table Type</div>
                                <div class="info-value"><%= tableType %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Payment Status</div>
                                <div class="info-value"><%= paymentStatus %></div>
                            </div>
                        </div>
                    </div>
                    <div class="reservation-footer">
                        <a href="${pageContext.request.contextPath}/user/reservations/view?id=<%= reservation.getId() %>" class="btn btn-view">View Details</a>
                        <a href="${pageContext.request.contextPath}/user/reservations/cancel?id=<%= reservation.getId() %>" class="btn btn-cancel">Cancel Reservation</a>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Past Reservations Tab -->
        <div class="tab-content" id="past">
            <% if (pastReservations.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">🗓️</div>
                    <div class="empty-state-text">You don't have any past reservations</div>
                </div>
            <% } else { %>
                <% for (Reservation reservation : pastReservations) {
                    LocalDate date = LocalDate.parse(reservation.getReservationDate());
                    String formattedDate = date.format(dateFormatter);
                    String tableType = getTableType(reservation.getTableId());
                %>
                <div class="reservation-card">
                    <div class="reservation-header">
                        <div class="reservation-date"><%= formattedDate %></div>
                        <div class="reservation-status status-<%= reservation.getStatus().toLowerCase() %>">
                            <%= reservation.getStatus().toUpperCase() %>
                        </div>
                    </div>
                    <div class="reservation-body">
                        <div class="reservation-info">
                            <div class="info-item">
                                <div class="info-label">Time</div>
                                <div class="info-value"><%= formatTime(reservation.getReservationTime()) %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Duration</div>
                                <div class="info-value"><%= reservation.getDuration() %> hours</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Table Type</div>
                                <div class="info-value"><%= tableType %></div>
                            </div>
                        </div>
                    </div>
                    <div class="reservation-footer">
                        <a href="${pageContext.request.contextPath}/user/reservations/view?id=<%= reservation.getId() %>" class="btn btn-view">View Details</a>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Cancelled Reservations Tab -->
        <div class="tab-content" id="cancelled">
            <% if (cancelledReservations.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">❌</div>
                    <div class="empty-state-text">You don't have any cancelled reservations</div>
                </div>
            <% } else { %>
                <% for (Reservation reservation : cancelledReservations) {
                    LocalDate date = LocalDate.parse(reservation.getReservationDate());
                    String formattedDate = date.format(dateFormatter);
                    String tableType = getTableType(reservation.getTableId());
                %>
                <div class="reservation-card">
                    <div class="reservation-header">
                        <div class="reservation-date"><%= formattedDate %></div>
                        <div class="reservation-status status-cancelled">CANCELLED</div>
                    </div>
                    <div class="reservation-body">
                        <div class="reservation-info">
                            <div class="info-item">
                                <div class="info-label">Time</div>
                                <div class="info-value"><%= formatTime(reservation.getReservationTime()) %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Duration</div>
                                <div class="info-value"><%= reservation.getDuration() %> hours</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Table Type</div>
                                <div class="info-value"><%= tableType %></div>
                            </div>
                        </div>
                    </div>
                    <div class="reservation-footer">
                        <a href="${pageContext.request.contextPath}/user/reservations/view?id=<%= reservation.getId() %>" class="btn btn-view">View Details</a>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <script>
        // Tab switching functionality
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function() {
                // Remove active class from all tabs
                document.querySelectorAll('.tab').forEach(t => {
                    t.classList.remove('active');
                });

                // Add active class to clicked tab
                this.classList.add('active');

                // Hide all tab content
                document.querySelectorAll('.tab-content').forEach(content => {
                    content.classList.remove('active');
                });

                // Show content for this tab
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Auto-hide messages after 5 seconds
        setTimeout(() => {
            const messages = document.querySelectorAll('.message');
            messages.forEach(message => {
                message.style.opacity = '0';
                message.style.transition = 'opacity 0.5s';
                setTimeout(() => {
                    message.style.display = 'none';
                }, 500);
            });
        }, 5000);
    </script>
</body>
</html>

<%!
    // Helper method to format time (e.g., "14:30" -> "2:30 PM")
    private String formatTime(String time) {
        try {
            String[] parts = time.split(":");
            int hour = Integer.parseInt(parts[0]);
            int minute = Integer.parseInt(parts[1]);

            String amPm = hour >= 12 ? "PM" : "AM";
            int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

            return String.format("%d:%02d %s", displayHour, minute, amPm);
        } catch (Exception e) {
            return time; // Return the original time if parsing fails
        }
    }

    // Helper method to get table type from table ID
    private String getTableType(String tableId) {
        if (tableId == null || tableId.isEmpty()) {
            return "Regular";
        }

        char typeChar = tableId.charAt(0);
        switch (typeChar) {
            case 'f': return "Family";
            case 'l': return "Luxury";
            case 'c': return "Couple";
            case 'r': return "Regular";
            default: return "Regular";
        }
    }
%>