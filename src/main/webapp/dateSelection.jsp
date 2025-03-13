<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Dining Time | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dateSelection.css">
</head>
<body>
    <%
        // Check if user is logged in
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
    %>

    <div class="datetime-container">
        <div class="header">
            <h1>Select Your Time</h1>
            <p>Welcome, <%= username %>! Choose your preferred dining date and time</p>
        </div>

        <form class="datetime-form" id="datetimeForm" action="${pageContext.request.contextPath}/reservation/createReservation" method="post">
            <div class="input-group">
                <label class="input-label">Dining Date</label>
                <input type="date" class="datetime-input" id="reservationDate" name="reservationDate" required
                       min="<%= java.time.LocalDate.now() %>"
                       max="<%= java.time.LocalDate.now().plusMonths(2) %>">
            </div>

            <div class="input-group">
                <label class="input-label">Dining Time</label>
                <input type="time" class="datetime-input" id="reservationTime" name="reservationTime" required
                       min="10:00" max="22:00">
            </div>

            <div class="booking-type-container">
                <label class="input-label">Booking Type</label>
                <div class="booking-type-options">
                    <div class="booking-option">
                        <input type="radio" id="normalBooking" name="bookingType" value="normal" checked>
                        <label for="normalBooking">Normal Booking (2 hours)</label>
                    </div>
                    <div class="booking-option">
                        <input type="radio" id="specialBooking" name="bookingType" value="special">
                        <label for="specialBooking">Special Booking</label>
                    </div>
                </div>
            </div>

            <div class="input-group" id="durationContainer" style="display: none;">
                <label class="input-label">Duration (hours)</label>
                <select class="datetime-input" id="reservationDuration" name="reservationDuration">
                    <option value="3">3 hours</option>
                    <option value="4">4 hours</option>
                    <option value="5">5 hours</option>
                    <option value="6">6 hours</option>
                </select>
            </div>

            <button type="submit" class="proceed-btn">Find Available Tables</button>

            <%
                String errorMessage = (String) request.getAttribute("errorMessage");
                if (errorMessage != null) {
            %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
            <% } %>
        </form>
    </div>

    <script>
        // Toggle duration field based on booking type
        document.querySelectorAll('input[name="bookingType"]').forEach(radio => {
            radio.addEventListener('change', function() {
                const durationContainer = document.getElementById('durationContainer');
                if (this.value === 'special') {
                    durationContainer.style.display = 'block';
                } else {
                    durationContainer.style.display = 'none';
                }
            });
        });

        document.getElementById('datetimeForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const date = document.getElementById('reservationDate').value;
            const time = document.getElementById('reservationTime').value;
            const bookingType = document.querySelector('input[name="bookingType"]:checked').value;
            const duration = bookingType === 'special' ?
                document.getElementById('reservationDuration').value : '2';

            // Basic form validation
            if(!date || !time) {
                showError('Please select both date and time');
                return;
            }

            // Current date in YYYY-MM-DD format
            const today = new Date().toISOString().split('T')[0];

            // Selected time in HH:MM format
            const selectedTime = time;
            const [hours, minutes] = selectedTime.split(':');

            // Check if selected date is today
            if(date === today) {
                // Get current time
                const now = new Date();
                const currentHours = now.getHours();
                const currentMinutes = now.getMinutes();

                // Check if selected time is in the past
                if(parseInt(hours) < currentHours || (parseInt(hours) === currentHours && parseInt(minutes) <= currentMinutes)) {
                    showError('Please select a future time');
                    return;
                }
            }

            // Check restaurant closing time (10 PM / 22:00)
            const selectedHour = parseInt(hours);
            const selectedMinutes = parseInt(minutes);
            const durationHours = parseInt(duration);

            // Calculate end time
            const endHour = selectedHour + durationHours;
            const endMinutes = selectedMinutes;

            if (endHour > 22 || (endHour === 22 && endMinutes > 0)) {
                showError(`Your booking would end after our closing time (10:00 PM). Please select an earlier time or reduce duration.`);
                return;
            }

            // If validation passes, store the values in session storage
            sessionStorage.setItem('reservationDate', date);
            sessionStorage.setItem('reservationTime', time);
            sessionStorage.setItem('bookingType', bookingType);
            sessionStorage.setItem('reservationDuration', duration);

            // Submit the form for server-side processing
            this.submit();
        });

        function showError(message) {
            const errorDiv = document.createElement('div');
            errorDiv.style.color = '#ff4444';
            errorDiv.style.marginTop = '1rem';
            errorDiv.style.textAlign = 'center';
            errorDiv.textContent = message;

            const existingError = document.querySelector('.error-message');
            if(existingError) existingError.remove();

            errorDiv.classList.add('error-message');
            document.querySelector('.datetime-form').appendChild(errorDiv);
        }

        // Set min attribute to today
        window.addEventListener('load', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('reservationDate').setAttribute('min', today);
        });
    </script>
</body>
</html>