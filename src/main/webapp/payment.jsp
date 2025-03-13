<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="com.tablebooknow.util.PaymentGateway" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make Payment | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
            display: flex;
            flex-direction: column;
            background: var(--dark);
            font-family: 'Roboto', sans-serif;
            background-image:
                linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)),
                url('${pageContext.request.contextPath}/assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
            color: var(--text);
        }

        .payment-container {
            background: rgba(26, 26, 26, 0.95);
            padding: 3rem;
            border-radius: 20px;
            width: 90%;
            max-width: 600px;
            margin: 50px auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .header-nav {
            padding: 1.5rem 5%;
            background: rgba(26, 26, 26, 0.95);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
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

        .payment-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .payment-header h1 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }

        .payment-header p {
            color: #ccc;
        }

        .order-summary {
            background: rgba(255,255,255,0.05);
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .order-summary h3 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 1.5rem;
            margin-bottom: 1rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            padding-bottom: 0.5rem;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.8rem;
        }

        .summary-label {
            font-weight: 500;
        }

        .summary-total {
            border-top: 2px solid rgba(255,255,255,0.1);
            margin-top: 1rem;
            padding-top: 1rem;
            font-weight: 700;
            font-size: 1.1rem;
        }

        .summary-total .summary-value {
            color: var(--gold);
        }

        .payment-methods {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .payment-method {
            flex: 1;
            min-width: 100px;
            aspect-ratio: 3/2;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 10px;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s;
        }

        .payment-method:hover {
            border-color: var(--gold);
            transform: translateY(-3px);
        }

        .payment-method.active {
            border-color: var(--gold);
            background: rgba(212, 175, 55, 0.2);
        }

        .payment-method img {
            max-width: 80%;
            max-height: 50%;
            object-fit: contain;
        }

        .btn-pay {
            display: block;
            width: 100%;
            padding: 1.2rem;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            color: white;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-pay:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }

        .or-divider {
            text-align: center;
            position: relative;
            margin: 2rem 0;
        }

        .or-divider:before,
        .or-divider:after {
            content: "";
            display: block;
            height: 1px;
            background: rgba(255,255,255,0.2);
            position: absolute;
            top: 50%;
            width: 45%;
        }

        .or-divider:before {
            left: 0;
        }

        .or-divider:after {
            right: 0;
        }

        .or-divider span {
            display: inline-block;
            background: rgba(26, 26, 26, 0.95);
            padding: 0 1rem;
            position: relative;
            color: #999;
        }

        .btn-cancel {
            display: block;
            width: 100%;
            padding: 1.2rem;
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 10px;
            background: transparent;
            color: #ccc;
            font-size: 1.1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-cancel:hover {
            border-color: #ff6b6b;
            color: #ff6b6b;
        }

        .secure-notice {
            text-align: center;
            margin-top: 2rem;
            color: #999;
            font-size: 0.9rem;
        }

        .secure-notice i {
            color: var(--gold);
            margin-right: 0.5rem;
        }

        .payhere-button {
            display: block;
            width: 100%;
            padding: 1.2rem;
            border: none;
            border-radius: 10px;
            background: #2b78e4; /* PayHere blue */
            color: white;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            margin-bottom: 1rem;
        }

        .payhere-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            background: #2467c8;
        }

        .payment-option {
            margin-bottom: 2rem;
        }

        .payment-option h3 {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 1.3rem;
            margin-bottom: 1rem;
            text-align: center;
        }

        @media (max-width: 768px) {
            .payment-container {
                padding: 2rem;
                width: 95%;
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

        // Get reservation info
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        if (reservation == null) {
            response.sendRedirect(request.getContextPath() + "/reservation/dateSelection");
            return;
        }

        // Get payment amount
        Double paymentAmount = (Double) request.getAttribute("paymentAmount");
        if (paymentAmount == null) {
            paymentAmount = 0.0;
        }

        // Get currency
        String currency = (String) request.getAttribute("currency");
        if (currency == null) {
            currency = "USD";
        }

        // Extract table information
        String tableId = reservation.getTableId();
        String tableType = "Standard";
        int seats = 2;

        if (tableId != null && tableId.length() > 0) {
            char typeCode = tableId.charAt(0);
            switch (typeCode) {
                case 'f':
                    tableType = "Family";
                    seats = 6;
                    break;
                case 'l':
                    tableType = "Luxury";
                    seats = 10;
                    break;
                case 'r':
                    tableType = "Regular";
                    seats = 4;
                    break;
                case 'c':
                    tableType = "Couple";
                    seats = 2;
                    break;
            }
        }

        // Format time as readable string
        String timeString = reservation.getReservationTime();
        String dateString = reservation.getReservationDate();

        // Get floor number from table ID (e.g., "f1-2" -> floor 1)
        String floorNumber = "1";
        if (tableId != null && tableId.length() > 1) {
            floorNumber = String.valueOf(tableId.charAt(1));
        }

        // Get the order ID (same as reservation ID)
        String orderId = reservation.getId();

        // Get customer details
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String email = (String) session.getAttribute("email");
        if (email == null) {
            email = "customer@example.com"; // Default for testing
        }
        String phone = (String) session.getAttribute("phone");
        if (phone == null) {
            phone = "0771234567"; // Default for testing
        }

        // PayHere configuration
        String merchantId = PaymentGateway.getPayhereMerchantId();
        String payhereUrl = PaymentGateway.getPayhereApiUrl();

        // Format amount for PayHere (2 decimal places)
        String formattedAmount = String.format("%.2f", paymentAmount);
    %>

    <!-- Header Navigation -->
    <nav class="header-nav">
        <a href="${pageContext.request.contextPath}/" class="logo">Gourmet Reserve</a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/reservation/dateSelection">Reservations</a>
            <a href="${pageContext.request.contextPath}/user/profile.jsp">Profile</a>
            <a href="${pageContext.request.contextPath}/user/logout">Logout</a>
        </div>
    </nav>

    <div class="payment-container">
        <div class="payment-header">
            <h1>Secure Checkout</h1>
            <p>Complete your reservation with a secure payment</p>
        </div>

        <div class="order-summary">
            <h3>Reservation Summary</h3>
            <div class="summary-row">
                <div class="summary-label">Date:</div>
                <div class="summary-value"><%= dateString %></div>
            </div>
            <div class="summary-row">
                <div class="summary-label">Time:</div>
                <div class="summary-value"><%= timeString %></div>
            </div>
            <div class="summary-row">
                <div class="summary-label">Duration:</div>
                <div class="summary-value"><%= reservation.getDuration() %> hours</div>
            </div>
            <div class="summary-row">
                <div class="summary-label">Table Type:</div>
                <div class="summary-value"><%= tableType %> (Floor <%= floorNumber %>)</div>
            </div>
            <div class="summary-row">
                <div class="summary-label">Seats:</div>
                <div class="summary-value"><%= seats %></div>
            </div>
            <div class="summary-row summary-total">
                <div class="summary-label">Total Amount:</div>
                <div class="summary-value">$<%= String.format("%.2f", paymentAmount) %> <%= currency %></div>
            </div>
        </div>

        <div class="payment-option">
            <h3>Pay with PayHere</h3>
            <!-- PayHere Payment Button -->
            <form method="post" action="<%= payhereUrl %>">
                <input type="hidden" name="merchant_id" value="<%= merchantId %>">
                <input type="hidden" name="return_url" value="${pageContext.request.contextPath}/payment/success">
                <input type="hidden" name="cancel_url" value="${pageContext.request.contextPath}/payment/cancel">
                <input type="hidden" name="notify_url" value="${pageContext.request.contextPath}/payment/notify">

                <input type="hidden" name="order_id" value="<%= orderId %>">
                <input type="hidden" name="items" value="Table Reservation: <%= tableType %> (Floor <%= floorNumber %>)">
                <input type="hidden" name="currency" value="<%= currency %>">
                <input type="hidden" name="amount" value="<%= formattedAmount %>">

                <input type="hidden" name="first_name" value="<%= username %>">
                <input type="hidden" name="last_name" value="">
                <input type="hidden" name="email" value="<%= email %>">
                <input type="hidden" name="phone" value="<%= phone %>">
                <input type="hidden" name="address" value="Table Reservation">
                <input type="hidden" name="city" value="Colombo">
                <input type="hidden" name="country" value="Sri Lanka">

                <input type="hidden" name="delivery_address" value="Not Applicable">
                <input type="hidden" name="delivery_city" value="Not Applicable">
                <input type="hidden" name="delivery_country" value="Not Applicable">

                <input type="hidden" name="custom_1" value="<%= reservation.getId() %>">
                <input type="hidden" name="custom_2" value="<%= tableId %>">

                <button type="submit" class="payhere-button">Pay with PayHere</button>
            </form>

            <div class="or-divider">
                <span>OR</span>
            </div>
        </div>

        <div class="payment-option">
            <h3>Pay with Credit/Debit Card</h3>
            <form class="payment-form" action="${pageContext.request.contextPath}/payment/process" method="post">
                <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                <input type="hidden" name="amount" value="<%= formattedAmount %>">
                <input type="hidden" name="currency" value="<%= currency %>">

                <div id="credit-form">
                    <div class="form-group">
                        <label class="form-label">Card Number</label>
                        <input type="text" name="cardNumber" class="form-control" placeholder="1234 5678 9012 3456" maxlength="19">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Cardholder Name</label>
                        <input type="text" name="cardholderName" class="form-control" placeholder="John Doe">
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Expiry Date</label>
                                <input type="text" name="expiryDate" class="form-control" placeholder="MM/YY">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">CVV</label>
                                <input type="text" name="cvv" class="form-control" placeholder="123" maxlength="3">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-pay">Pay $<%= formattedAmount %></button>
                </div>
            </form>
        </div>

        <a href="${pageContext.request.contextPath}/payment/cancel" class="btn-cancel">Cancel Reservation</a>

        <div class="secure-notice">
            <i class="fas fa-lock"></i> All payment information is encrypted and processed securely.
        </div>
    </div>

    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Format credit card number with spaces
            const cardInput = document.querySelector('input[name="cardNumber"]');
            if (cardInput) {
                cardInput.addEventListener('input', function(e) {
                    let value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');

                    if (value.length > 16) {
                        value = value.substring(0, 16);
                    }

                    // Add space after every 4 digits
                    const formattedValue = value.replace(/(.{4})/g, '$1 ').trim();
                    e.target.value = formattedValue;
                });
            }

            // Format expiry date
            const expiryInput = document.querySelector('input[name="expiryDate"]');
            if (expiryInput) {
                expiryInput.addEventListener('input', function(e) {
                    let value = e.target.value.replace(/\D/g, '');

                    if (value.length > 0) {
                        if (value.length <= 2) {
                            value = value.replace(/^(\d{2})/, '$1');
                        } else {
                            value = value.replace(/^(\d{2})(\d+)/, '$1/$2').substring(0, 5);
                        }

                        e.target.value = value;
                    }
                });
            }
        });
    </script>
</body>
</html>