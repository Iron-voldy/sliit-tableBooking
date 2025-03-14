<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Confirmed | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
            --success: #28a745;
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

        .confirmation-container {
            background: rgba(26, 26, 26, 0.95);
            padding: 3rem;
            border-radius: 20px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: 1px solid rgba(212, 175, 55, 0.2);
            animation: fadeIn 0.5s ease-out;
            text-align: center;
            color: var(--text);
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .checkmark-circle {
            width: 100px;
            height: 100px;
            background: rgba(40, 167, 69, 0.1);
            border-radius: 50%;
            border: 2px solid var(--success);
            margin: 0 auto 2rem;
            display: flex;
            justify-content: center;
            align-items: center;
            animation: scaleUp 0.5s ease-out forwards;
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

        @keyframes checkmark {
            0% { width: 0; height: 0; opacity: 0; }
            50% { width: 0; height: 80px; opacity: 1; }
            100% { width: 40px; height: 80px; opacity: 1; }
        }

        .confirmation-header {
            margin-bottom: 2rem;
        }

        .confirmation-header h1 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            letter-spacing: 1px;
        }

        .confirmation-header p {
            color: var(--text);
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .confirmation-details {
            margin-bottom: 2.5rem;
            line-height: 1.6;
        }

        .confirmation-message {
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            color: var(--success);
            font-weight: 500;
        }

        .reservation-id {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        .reservation-id span {
            color: var(--text);
            opacity: 0.8;
        }

        .reservation-id strong {
            font-family: 'Courier New', monospace;
            font-size: 1.1rem;
            color: var(--gold);
            letter-spacing: 1px;
        }

        .instruction {
            margin-bottom: 1.5rem;
            font-size: 1rem;
            opacity: 0.9;
        }

        .qr-code-container {
            width: 200px;
            height: 240px;
            margin: 0 auto 1.5rem;
            text-align: center;
        }

        .qr-code {
            width: 200px;
            height: 200px;
            background: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Courier New', monospace;
            font-weight: bold;
            font-size: 2rem;
            color: #000;
            margin-bottom: 10px;
            border: 1px solid #ddd;
            position: relative;
        }

        /* Fake QR code styling */
        .qr-code::before {
            content: "";
            position: absolute;
            top: 25px;
            left: 25px;
            width: 150px;
            height: 150px;
            background-image:
                linear-gradient(to right, #000 1px, transparent 1px),
                linear-gradient(to bottom, #000 1px, transparent 1px);
            background-size: 10px 10px;
            opacity: 0.2;
            z-index: 1;
        }

        .qr-code::after {
            content: "";
            position: absolute;
            width: 30px;
            height: 30px;
            border: 5px solid #000;
            top: 20px;
            left: 20px;
            z-index: 2;
        }

        .qr-corner-tr, .qr-corner-bl {
            position: absolute;
            width: 30px;
            height: 30px;
            border: 5px solid #000;
            z-index: 2;
        }

        .qr-corner-tr {
            top: 20px;
            right: 20px;
        }

        .qr-corner-bl {
            bottom: 20px;
            left: 20px;
        }

        .qr-code-container p {
            font-size: 0.9rem;
            opacity: 0.8;
        }

        .reservation-details {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            text-align: left;
        }

        .detail-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.8rem;
        }

        .detail-label {
            color: var(--text);
            opacity: 0.8;
        }

        .detail-value {
            color: var(--gold);
            font-weight: 500;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 1rem;
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
            .confirmation-container {
                padding: 2rem;
            }

            .confirmation-header h1 {
                font-size: 2rem;
            }

            .action-buttons {
                flex-direction: column;
                gap: 0.8rem;
            }
        }

        @media print {
            body {
                background: white;
            }
            .confirmation-container {
                box-shadow: none;
                border: none;
                background: white;
                color: black;
            }
            .btn {
                display: none;
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
        String confirmationMessage = (String) session.getAttribute("confirmationMessage");
        String reservationId = (String) session.getAttribute("reservationId");
        String reservationDate = (String) session.getAttribute("reservationDate");
        String reservationTime = (String) session.getAttribute("reservationTime");
        String tableId = (String) session.getAttribute("tableId");
        String tableType = "Regular";

        // Extract table type from table ID if available
        if (tableId != null && !tableId.isEmpty()) {
            char typeChar = tableId.charAt(0);
            if (typeChar == 'f') tableType = "Family";
            else if (typeChar == 'l') tableType = "Luxury";
            else if (typeChar == 'c') tableType = "Couple";
            else if (typeChar == 'r') tableType = "Regular";
        }

        if (confirmationMessage == null) {
            confirmationMessage = "Your reservation has been confirmed!";
        }

        // Generate a reservation code for display - in real app this would be a real QR code
        String qrCodeContent = "RESERVATION:" + reservationId;
        if (reservationId == null) {
            reservationId = "Unknown";
            qrCodeContent = "ERROR:NO_RESERVATION_ID";
        }
    %>

    <div class="confirmation-container">
        <div class="checkmark-circle">
            <div class="checkmark"></div>
        </div>

        <div class="confirmation-header">
            <h1>Reservation Confirmed!</h1>
            <p>Thank you for choosing Gourmet Reserve</p>
        </div>

        <div class="confirmation-details">
            <p class="confirmation-message"><%= confirmationMessage %></p>

            <div class="reservation-id">
                <span>Reservation ID:</span>
                <strong><%= reservationId %></strong>
            </div>

            <div class="reservation-details">
                <div class="detail-item">
                    <span class="detail-label">Date:</span>
                    <span class="detail-value"><%= reservationDate != null ? reservationDate : "Not specified" %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Time:</span>
                    <span class="detail-value"><%= reservationTime != null ? reservationTime : "Not specified" %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Table Type:</span>
                    <span class="detail-value"><%= tableType %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Table ID:</span>
                    <span class="detail-value"><%= tableId != null ? tableId : "Not assigned" %></span>
                </div>
            </div>

            <p class="instruction">A confirmation email has been sent to your registered email address with your reservation details and a QR code for check-in.</p>

            <div class="qr-code-container">
                <div class="qr-code">
                    QR
                    <div class="qr-corner-tr"></div>
                    <div class="qr-corner-bl"></div>
                </div>
                <p>Scan this QR code when you arrive</p>
                <p style="font-size: 0.8rem; color: #777;">Code: <%= reservationId %></p>
            </div>
        </div>

        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/user/reservations" class="btn btn-secondary">View My Reservations</a>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
            <a href="#" class="btn btn-secondary" id="printBtn">Print QR Code</a>
        </div>
    </div>

    <script>
        // Print functionality
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('printBtn').addEventListener('click', function(e) {
                e.preventDefault();
                window.print();
            });
        });
    </script>
</body>
</html>