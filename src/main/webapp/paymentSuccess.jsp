<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Status | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
            --success: #28a745;
            --error: #dc3545;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: var(--dark);
            font-family: 'Roboto', sans-serif;
            background-image:
                linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)),
                url('${pageContext.request.contextPath}/assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
        }

        .container {
            background: rgba(26, 26, 26, 0.95);
            padding: 3rem;
            border-radius: 20px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: 1px solid rgba(212, 175, 55, 0.2);
            animation: fadeIn 0.5s ease-out;
            text-align: center;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .status-circle {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin: 0 auto 2rem;
            display: flex;
            justify-content: center;
            align-items: center;
            animation: scaleUp 0.5s ease-out forwards;
        }

        .success-circle {
            background: rgba(40, 167, 69, 0.1);
            border: 2px solid var(--success);
        }

        .error-circle {
            background: rgba(220, 53, 69, 0.1);
            border: 2px solid var(--error);
        }

        @keyframes scaleUp {
            0% { transform: scale(0.5); opacity: 0; }
            70% { transform: scale(1.1); }
            100% { transform: scale(1); opacity: 1; }
        }

        .checkmark {
            width: 40px;
            height: 80px;
            border-right: 4px solid var(--success);
            border-bottom: 4px solid var(--success);
            transform: rotate(45deg) translate(-10px, -10px);
            animation: checkmark 0.8s ease-out forwards;
            opacity: 0;
            transform-origin: center;
        }

        .error-mark {
            position: relative;
            width: 60px;
            height: 60px;
        }

        .error-mark:before, .error-mark:after {
            content: "";
            position: absolute;
            width: 4px;
            height: 60px;
            background-color: var(--error);
            top: 0;
            left: 28px;
        }

        .error-mark:before {
            transform: rotate(45deg);
        }

        .error-mark:after {
            transform: rotate(-45deg);
        }

        @keyframes checkmark {
            0% { width: 0; height: 0; opacity: 0; }
            50% { width: 0; height: 80px; opacity: 1; }
            100% { width: 40px; height: 80px; opacity: 1; }
        }

        .header {
            margin-bottom: 2rem;
        }

        .header h1 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            letter-spacing: 1px;
        }

        .header p {
            color: var(--text);
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .payment-details {
            text-align: left;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .detail-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .detail-item:last-child {
            margin-bottom: 0;
        }

        .detail-label {
            color: var(--text);
            opacity: 0.8;
        }

        .detail-value {
            color: var(--gold);
            font-weight: 500;
        }

        .message {
            margin-bottom: 2rem;
            color: var(--text);
            line-height: 1.5;
        }

        .success-message {
            color: var(--success);
        }

        .error-message {
            color: var(--error);
        }

        .instruction {
            color: var(--text);
            margin-bottom: 1.5rem;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-top: 2rem;
        }

        .btn {
            padding: 1rem 1.5rem;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            color: white;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text);
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        @media (max-width: 768px) {
            .container {
                padding: 2rem;
            }

            .header h1 {
                font-size: 2rem;
            }

            .action-buttons {
                flex-direction: column;
                gap: 0.8rem;
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

        String reservationId = (String) session.getAttribute("reservationId");
        String paymentId = (String) session.getAttribute("paymentId");

        // Check if payment was successful
        Boolean paymentSuccessful = (Boolean) request.getAttribute("paymentSuccessful");
        if (paymentSuccessful == null) {
            // If not set from servlet, try to determine from request parameters
            String status = request.getParameter("status_code");
            paymentSuccessful = "2".equals(status); // 2 is success status in PayHere
        }

        // Get confirmation message
        String confirmationMessage = (String) session.getAttribute("confirmationMessage");
        if (confirmationMessage == null) {
            confirmationMessage = paymentSuccessful
                ? "Your payment was successful. Thank you for your reservation!"
                : "There was an issue with your payment. Please contact support for assistance.";
        }

        // Get error message if any
        String errorMessage = (String) request.getAttribute("errorMessage");

        // Get reservation details
        String restaurantName = (String) session.getAttribute("restaurantName");
        String reservationDate = (String) session.getAttribute("reservationDate");
        String reservationTime = (String) session.getAttribute("reservationTime");
        String guestCount = (String) session.getAttribute("guestCount");
        String amount = (String) session.getAttribute("amount");

        if (restaurantName == null) restaurantName = "Gourmet Reserve Restaurant";
        if (reservationDate == null) reservationDate = "Not available";
        if (reservationTime == null) reservationTime = "Not available";
        if (guestCount == null) guestCount = "Not available";
        if (amount == null) amount = "Not available";
    %>

    <div class="container">
        <div class="header">
            <h1>Payment <%= paymentSuccessful ? "Successful" : "Failed" %></h1>
            <p>Reservation #<%= reservationId != null ? reservationId : "Unknown" %></p>
        </div>

        <div class="status-circle <%= paymentSuccessful ? "success-circle" : "error-circle" %>">
            <% if (paymentSuccessful) { %>
                <div class="checkmark"></div>
            <% } else { %>
                <div class="error-mark"></div>
            <% } %>
        </div>

        <div class="message <%= paymentSuccessful ? "success-message" : "error-message" %>">
            <p><%= confirmationMessage %></p>
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <p class="error-message"><%= errorMessage %></p>
            <% } %>
        </div>

        <div class="payment-details">
            <div class="detail-item">
                <span class="detail-label">Restaurant:</span>
                <span class="detail-value"><%= restaurantName %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Date:</span>
                <span class="detail-value"><%= reservationDate %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Time:</span>
                <span class="detail-value"><%= reservationTime %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Guests:</span>
                <span class="detail-value"><%= guestCount %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Payment ID:</span>
                <span class="detail-value"><%= paymentId != null ? paymentId : "N/A" %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Amount Paid:</span>
                <span class="detail-value">$<%= amount %></span>
            </div>
        </div>

        <% if (paymentSuccessful) { %>
            <div class="instruction">
                <p>A confirmation email has been sent to your registered email address.</p>
                <p>Please arrive 15 minutes before your reservation time.</p>
            </div>
        <% } else { %>
            <div class="instruction">
                <p>Please try again or contact our support team for assistance.</p>
                <p>Email: support@gourmetreserve.com</p>
                <p>Phone: +1-800-GOURMET</p>
            </div>
        <% } %>

        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-primary">Back to Dashboard</a>
            <% if (paymentSuccessful) { %>
                <a href="${pageContext.request.contextPath}/viewReservation?id=<%= reservationId %>" class="btn btn-secondary">View Reservation</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/reservation.jsp" class="btn btn-secondary">Try Again</a>
            <% } %>
        </div>
    </div>
</body>
</html>