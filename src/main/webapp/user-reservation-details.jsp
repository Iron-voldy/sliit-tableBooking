<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="com.tablebooknow.model.payment.Payment" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details | Gourmet Reserve</title>
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
            max-width: 800px;
            margin: 2rem auto;
        }

        .back-link {
            display: block;
            margin-bottom: 1.5rem;
            color: var(--gold);
            text-decoration: none;
            transition: color 0.3s;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .detail-card {
            background: rgba(26, 26, 26, 0.95);
            border-radius: 15px;
            overflow: hidden;
            border: 1px solid rgba(212, 175, 55, 0.2);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
        }

        .detail-header {
            background: linear-gradient(135deg, rgba(128, 0, 32, 0.8), rgba(26, 26, 26, 0.8));
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-left h1 {
            font-family: 'Playfair Display', serif;
            font-size: 1.8rem;
            color: var(--gold);
            margin-bottom: 0.5rem;
        }

        .header-left p {
            font-size: 1.1rem;
            opacity: 0.8;
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

        .detail-body {
            padding: 2rem;
        }

        .detail-section {
            margin-bottom: 2rem;
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            color: var(--gold);
            margin-bottom: 1rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
            padding-bottom: 0.5rem;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            margin-bottom: 1rem;
        }

        .detail-label {
            font-size: 0.9rem;
            color: var(--gold);
            margin-bottom: 0.3rem;
        }

        .detail-value {
            font-size: 1.1rem;
        }

        .qr-section {
            text-align: center;
            margin-top: 2rem;
            padding: 1.5rem;
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
        }

        .qr-code {
            max-width: 200px;
            margin: 1rem auto;
        }

        .qr-instructions {
            font-size: 0.9rem;
            margin-top: 1rem;
            opacity: 0.8;
        }

        .action-buttons {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
            justify-content: center;
        }

        .btn {
            padding: 0.8rem 1.8rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
            border: none;
            text-align: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .btn-secondary {
            background: rgba(212, 175, 55, 0.2);
            color: var(--gold);
            border: 1px solid rgba(212, 175, 55, 0.5);
        }

        .btn-secondary:hover {
            background: rgba(212, 175, 55, 0.3);
        }

        .btn-danger {
            background: rgba(231, 76, 60, 0.2);
            color: #e74c3c;
            border: 1px solid rgba(231, 76, 60, 0.5);
        }

        .btn-danger:hover {
            background: rgba(231, 76, 60, 0.3);
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

        .special-requests {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
        }

        @media (max-width: 768px) {
            .detail-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn {
                width: 100%;
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

        // Get data from request attributes
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        Payment payment = (Payment) request.getAttribute("payment");
        Boolean canCancel = (Boolean) request.getAttribute("canCancel");

        if (reservation == null) {
            // Redirect if no reservation found
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        // Format date and time
        LocalDate date = LocalDate.parse(reservation.getReservationDate());
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
        String formattedDate = date.format(dateFormatter);

        // Messages
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
        <a href="${pageContext.request.contextPath}/user/reservations" class="back-link">← Back to My Reservations</a>

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

        <div class="detail-card">
            <div class="detail-header">
                <div class="header-left">
                    <h1>Reservation Details</h1>
                    <p><%= formattedDate %></p>
                </div>
                <div class="reservation-status status-<%= reservation.getStatus().toLowerCase() %>">
                    <%= reservation.getStatus().toUpperCase() %>
                </div>
            </div>

            <div class="detail-body">
                <!-- Reservation Details Section -->
                <div class="detail-section">
                    <h2 class="section-title">Reservation Information</h2>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <div class="detail-label">Time</div>
                            <div class="detail-value"><%= formatTime(reservation.getReservationTime()) %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Duration</div>
                            <div class="detail-value"><%= reservation.getDuration() %> hours</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">End Time</div>
                            <div class="detail-value"><%= calculateEndTime(reservation.getReservationTime(), reservation.getDuration()) %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Booking Type</div>
                            <div class="detail-value"><%= capitalize(reservation.getBookingType()) %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Table Type</div>
                            <div class="detail-value"><%= getTableType(reservation.getTableId()) %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Table ID</div>
                            <div class="detail-value"><%= reservation.getTableId() %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Reservation ID</div>
                            <div class="detail-value"><%= reservation.getId() %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Created</div>
                            <div class="detail-value"><%= reservation.getCreatedAt() != null ? reservation.getCreatedAt().toString().replace("T", " ") : "N/A" %></div>
                        </div>
                    </div>

                    <!-- Special Requests -->
                    <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().trim().isEmpty()) { %>
                    <div class="detail-item">
                        <div class="detail-label">Special Requests</div>
                        <div class="detail-value special-requests">
                            <%= reservation.getSpecialRequests() %>
                        </div>
                    </div>
                    <% } %>
                </div>

                <!-- Payment Information Section (if available) -->
                <% if (payment != null) { %>
                <div class="detail-section">
                    <h2 class="section-title">Payment Information</h2>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <div class="detail-label">Payment Status</div>
                            <div class="detail-value"><%= payment.getStatus() %></div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Amount</div>
                            <div class="detail-value">
                                <%= payment.getAmount() != null ? payment.getAmount().toString() : "N/A" %>
                                <%= payment.getCurrency() != null ? payment.getCurrency() : "" %>
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Payment Method</div>
                            <div class="detail-value">
                                <%= payment.getPaymentMethod() != null ? payment.getPaymentMethod() : "N/A" %>
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Payment Date</div>
                            <div class="detail-value">
                                <%= payment.getCompletedAt() != null ? payment.getCompletedAt().toString().replace("T", " ") : "N/A" %>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>

                <!-- QR Code for Check-in (if reservation is confirmed) -->
                <% if ("confirmed".equalsIgnoreCase(reservation.getStatus())) { %>
                <div class="qr-section">
                    <h3>Check-in QR Code</h3>
                    <!-- This would normally be generated dynamically from your backend -->
                    <img src="${pageContext.request.contextPath}/QRCodeServlet?id=<%= reservation.getId() %>" alt="Check-in QR Code" class="qr-code">
                    <div class="qr-instructions">
                        Present this QR code to the staff when you arrive at the restaurant.
                    </div>
                </div>
                <% } %>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <% if (canCancel != null && canCancel && !"cancelled".equals(reservation.getStatus())) { %>
                        <a href="${pageContext.request.contextPath}/user/reservations/cancel?id=<%= reservation.getId() %>" class="btn btn-danger">Cancel Reservation</a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/user/reservations" class="btn btn-secondary">Back to All Reservations</a>
                </div>
            </div>
        </div>
    </div>

    <script>
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

    // Helper method to calculate end time
    private String calculateEndTime(String startTime, int duration) {
        try {
            String[] parts = startTime.split(":");
            int hour = Integer.parseInt(parts[0]);
            int minute = Integer.parseInt(parts[1]);

            hour = (hour + duration) % 24;

            String amPm = hour >= 12 ? "PM" : "AM";
            int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

            return String.format("%d:%02d %s", displayHour, minute, amPm);
        } catch (Exception e) {
            return "N/A"; // Return placeholder if calculation fails
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

    // Helper method to capitalize first letter
    private String capitalize(String text) {
        if (text == null || text.isEmpty()) {
            return "Normal";
        }
        return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
    }
%>