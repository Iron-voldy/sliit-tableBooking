<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cancel Reservation | Gourmet Reserve</title>
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
            max-width: 700px;
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

        .cancel-card {
            background: rgba(26, 26, 26, 0.95);
            border-radius: 15px;
            overflow: hidden;
            border: 1px solid rgba(212, 175, 55, 0.2);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
        }

        .cancel-header {
            background: linear-gradient(135deg, rgba(231, 76, 60, 0.8), rgba(26, 26, 26, 0.8));
            padding: 2rem;
            text-align: center;
        }

        .cancel-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #e74c3c;
        }

        .cancel-title {
            font-family: 'Playfair Display', serif;
            font-size: 2rem;
            color: var(--text);
            margin-bottom: 0.5rem;
        }

        .cancel-subtitle {
            font-size: 1.1rem;
            opacity: 0.8;
        }

        .cancel-body {
            padding: 2rem;
        }

        .reservation-summary {
            background: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .summary-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            color: var(--gold);
            margin-bottom: 1rem;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
        }

        .summary-item {
            display: flex;
            flex-direction: column;
        }

        .summary-label {
            font-size: 0.9rem;
            color: var(--gold);
            margin-bottom: 0.3rem;
        }

        .summary-value {
            font-size: 1.1rem;
        }

        .cancel-warning {
            margin: 2rem 0;
            padding: 1.5rem;
            background: rgba(231, 76, 60, 0.1);
            border-left: 3px solid #e74c3c;
            border-radius: 5px;
        }

        .warning-title {
            font-weight: 500;
            color: #e74c3c;
            margin-bottom: 0.5rem;
        }

        .warning-text {
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .cancel-form {
            margin-top: 2rem;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 1rem;
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
            flex: 1;
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
            background: rgba(231, 76, 60, 0.8);
            color: white;
        }

        .btn-danger:hover {
            background: rgba(231, 76, 60, 1);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .message {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 8px;
        }

        .error-message {
            background: rgba(231, 76, 60, 0.2);
            border: 1px solid rgba(231, 76, 60, 0.5);
            color: #e74c3c;
        }

        @media (max-width: 768px) {
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

        // Get reservation from request attribute
        Reservation reservation = (Reservation) request.getAttribute("reservation");

        if (reservation == null) {
            // Redirect if no reservation found
            response.sendRedirect(request.getContextPath() + "/user/reservations");
            return;
        }

        // Format date and time
        LocalDate date = LocalDate.parse(reservation.getReservationDate());
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
        String formattedDate = date.format(dateFormatter);

        // Get messages if any
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

        <!-- Error Messages -->
        <% if (errorMessage != null) { %>
            <div class="message error-message">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="cancel-card">
            <div class="cancel-header">
                <div class="cancel-icon">❌</div>
                <h1 class="cancel-title">Cancel Reservation</h1>
                <p class="cancel-subtitle">Please confirm you want to cancel this reservation</p>
            </div>

            <div class="cancel-body">
                <!-- Reservation Summary -->
                <div class="reservation-summary">
                    <h2 class="summary-title">Reservation Summary</h2>
                    <div class="summary-grid">
                        <div class="summary-item">
                            <div class="summary-label">Date</div>
                            <div class="summary-value"><%= formattedDate %></div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">Time</div>
                            <div class="summary-value"><%= formatTime(reservation.getReservationTime()) %></div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">Duration</div>
                            <div class="summary-value"><%= reservation.getDuration() %> hours</div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">Table Type</div>
                            <div class="summary-value"><%= getTableType(reservation.getTableId()) %></div>
                        </div>
                    </div>
                </div>

                <!-- Cancellation Warning -->
                <div class="cancel-warning">
                    <div class="warning-title">Important Note</div>
                    <div class="warning-text">
                        <p>Please be aware that cancelling your reservation cannot be undone. If you wish to dine with us again, you will need to make a new reservation, subject to availability.</p>
                        <p>If you have any questions or need assistance, please contact our customer service team.</p>
                    </div>
                </div>

                <!-- Cancellation Form -->
                <form class="cancel-form" method="post" action="${pageContext.request.contextPath}/user/reservations/cancel">
                    <input type="hidden" name="id" value="<%= reservation.getId() %>">
                    <input type="hidden" name="confirmCancel" value="yes">

                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/user/reservations/view?id=<%= reservation.getId() %>" class="btn btn-secondary">No, Keep My Reservation</a>
                        <button type="submit" class="btn btn-danger">Yes, Cancel Reservation</button>
                    </div>
                </form>
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