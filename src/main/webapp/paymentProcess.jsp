<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Processing Payment | Gourmet Reserve</title>
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

        .loader-container {
            background: rgba(26, 26, 26, 0.95);
            padding: 3rem;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: 1px solid rgba(212, 175, 55, 0.2);
            text-align: center;
        }

        .loader-title {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2rem;
            margin-bottom: 1.5rem;
        }

        .loader-text {
            color: var(--text);
            margin-bottom: 2rem;
        }

        .spinner {
            display: inline-block;
            width: 80px;
            height: 80px;
            margin-bottom: 2rem;
        }

        .spinner:after {
            content: " ";
            display: block;
            width: 64px;
            height: 64px;
            margin: 8px;
            border-radius: 50%;
            border: 6px solid var(--gold);
            border-color: var(--gold) transparent var(--gold) transparent;
            animation: spin 1.2s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .hidden-form {
            display: none;
        }

        .debug-info {
            margin-top: 20px;
            padding: 10px;
            background: rgba(0,0,0,0.5);
            border-radius: 5px;
            font-size: 12px;
            color: #aaa;
            text-align: left;
            max-height: 200px;
            overflow-y: auto;
            display: none;
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

        // Get payment parameters from request
        Map<String, String> paymentParams = (Map<String, String>) request.getAttribute("paymentParams");
        String checkoutUrl = (String) request.getAttribute("checkoutUrl");

        if (paymentParams == null || checkoutUrl == null) {
            response.sendRedirect(request.getContextPath() + "/payment.jsp");
            return;
        }

        // For debugging - check simulation mode
        String simulatePayment = request.getParameter("simulatePayment");
        boolean isSimulation = "true".equals(simulatePayment);
    %>

    <div class="loader-container">
        <h1 class="loader-title">Processing Payment</h1>
        <p class="loader-text">Please wait while we redirect you to our secure payment gateway...</p>
        <div class="spinner"></div>

        <% if (isSimulation) { %>
            <p style="color: #ff9900; margin-bottom: 20px;">Using development simulation mode</p>
        <% } %>

        <!-- Hidden form for submitting to PayHere -->
        <form id="paymentForm" action="<%= checkoutUrl %>" method="post" class="hidden-form">
            <% for (Map.Entry<String, String> entry : paymentParams.entrySet()) { %>
                <input type="hidden" name="<%= entry.getKey() %>" value="<%= entry.getValue() %>">
            <% } %>
            <!-- Add a hidden field to indicate if this is a simulation -->
            <% if (isSimulation) { %>
                <input type="hidden" name="simulatePayment" value="true">
            <% } %>
        </form>

        <!-- Debug information - only visible with debug parameter -->
        <%
            String debug = request.getParameter("debug");
            if ("true".equals(debug)) {
        %>
        <div class="debug-info" style="display: block;">
            <h3>Debug Information:</h3>
            <p>Checkout URL: <%= checkoutUrl %></p>
            <p>Payment Parameters:</p>
            <ul>
                <% for (Map.Entry<String, String> entry : paymentParams.entrySet()) { %>
                    <li><strong><%= entry.getKey() %>:</strong> <%= entry.getValue() %></li>
                <% } %>
            </ul>
        </div>
        <% } %>
    </div>

    <script>
        // Auto-submit the form after a short delay
        document.addEventListener('DOMContentLoaded', function() {
            <% if (isSimulation) { %>
                // For simulation mode, redirect to simulated payment success
                setTimeout(function() {
                    window.location.href = "${pageContext.request.contextPath}/payment/success?simulatePayment=true&status_code=2&order_id=" +
                        "<%= paymentParams.get("order_id") %>";
                }, 1500);
            <% } else { %>
                // For real PayHere integration
                setTimeout(function() {
                    document.getElementById('paymentForm').submit();
                }, 1500);
            <% } %>
        });
    </script>
</body>
</html>