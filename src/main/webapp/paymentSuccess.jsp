<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful | Gourmet Reserve</title>
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

        .success-container {
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

        .success-header {
            margin-bottom: 2rem;
        }

        .success-header h1 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            letter-spacing: 1px;
        }

        .success-header p {
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
            .success-container {
                padding: 2rem;
            }

            .success-header h1 {
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
        String paymentStatus = request.getParameter("status_code");

        if (paymentStatus == null) {
            paymentStatus = "2"; // Default to success
        }

        boolean paymentSuccessful = "2".equals(paymentStatus); // 2 is success status in PayHere
    %>

    <div class="success-container">
        <div class="checkmark-circle">
            <div class="checkmark"></div>
        </div>

        <div class="success-header">
            <h1>Payment Successful!</h1>
            <p>Your table reservation is now confirmed</p>
        </div>

        <div class="payment-details">
            <div class="detail-item">
                <span class="detail-label">Payment ID:</span>
                <span class="detail-value"><%= paymentId != null ? paymentId : "N/A" %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Reservation ID:</span>
                <span class="detail-value"><%= reservationId != null ? reservationId : "N/A" %></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Status:</span>
                <span class="detail-value">Completed</span>
            </div>
        </div>

        <p>Thank you for your payment. Your table reservation has been confirmed. A confirmation email has been sent to your registered email address.</p>

        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/user/reservations" class="btn btn-secondary">View My Reservations</a>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
        </div>
    </div>

    <script>
        // Clear payment data from session after display
        window.addEventListener('beforeunload', function() {
            <%
                // Clear the payment data
                session.removeAttribute("paymentId");
            %>
        });
    </script>
</body>
</html>