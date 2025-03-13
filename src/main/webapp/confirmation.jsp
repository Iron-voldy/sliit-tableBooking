<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Confirmed | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/confirmation.css">
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

        if (confirmationMessage == null) {
            confirmationMessage = "Your reservation has been confirmed!";
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

            <% if (reservationId != null) { %>
            <div class="reservation-id">
                <span>Reservation ID:</span>
                <strong><%= reservationId %></strong>
            </div>
            <% } %>

            <p class="instruction">A confirmation email has been sent to your registered email address with your reservation details and a QR code for check-in.</p>

            <div class="qr-code-placeholder">
                <div class="qr-code-inner">QR</div>
                <p>Scan this QR code when you arrive</p>
            </div>
        </div>

        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/user/reservations" class="btn btn-secondary">View My Reservations</a>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
        </div>
    </div>

    <script>
        // Clear reservation data from session after display
        window.addEventListener('beforeunload', function() {
            <%
                // Clear the confirmation data
                session.removeAttribute("confirmationMessage");
                session.removeAttribute("reservationId");
            %>
        });
    </script>
</body>
</html>