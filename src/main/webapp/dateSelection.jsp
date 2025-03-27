<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Dining Time | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dateSelection.css">
    <style>
    /* Copy the contents of dateSelection.css directly here */
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

    /* Rest of the CSS content */
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

        // Debug info
        System.out.println("User authenticated: " + username);
        System.out.println("Context path: " + request.getContextPath());
    %>

    <div class="datetime-container">
        <div class="header">
            <h1>Select Your Time</h1>
            <p>Welcome, <%= username %>! Choose your preferred dining date and time</p>
        </div>

        <!-- Important: Ensure the form action is correct and using direct form submission -->
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

            <!-- Let's add a simple submit button that bypasses JS validation for debugging -->
            <button type="submit" class="proceed-btn" id="submitBtn">Find Available Tables</button>
            <div id="debug-info" style="margin-top: 20px; color: white; font-size: 12px;"></div>

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
        // Add a debug helper function
        function debugLog(message) {
            console.log(message);
            const debugElement = document.getElementById('debug-info');
            if (debugElement) {
                debugElement.innerHTML += message + '<br>';
            }
        }

        debugLog('Page loaded. Context path: ${pageContext.request.contextPath}');

        // Toggle duration field based on booking type
        document.querySelectorAll('input[name="bookingType"]').forEach(radio => {
            radio.addEventListener('change', function() {
                const durationContainer = document.getElementById('durationContainer');
                if (this.value === 'special') {
                    durationContainer.style.display = 'block';
                } else {
                    durationContainer.style.display = 'none';
                }
                debugLog('Booking type changed to: ' + this.value);
            });
        });

        // Add direct form submission option
        document.getElementById('submitBtn').addEventListener('click', function(e) {
            debugLog('Submit button clicked');

            const form = document.getElementById('datetimeForm');
            const date = document.getElementById('reservationDate').value;
            const time = document.getElementById('reservationTime').value;

            debugLog('Date: ' + date + ', Time: ' + time);

            if(!date || !time) {
                debugLog('Missing date or time - adding fallback values');

                // If values are missing, add defaults for debugging purposes
                if(!date) document.getElementById('reservationDate').value = '<%= java.time.LocalDate.now() %>';
                if(!time) document.getElementById('reservationTime').value = '12:00';

                // Let the form submit naturally
                return true;
            }

            debugLog('Form valid - submitting');
            // Let the form submit naturally
            return true;
        });

        // Modified form submission handling
        document.getElementById('datetimeForm').addEventListener('submit', function(e) {
            debugLog('Form submit event triggered');

            const date = document.getElementById('reservationDate').value;
            const time = document.getElementById('reservationTime').value;
            const bookingType = document.querySelector('input[name="bookingType"]:checked').value;
            const duration = bookingType === 'special' ?
                document.getElementById('reservationDuration').value : '2';

            debugLog('Form data: date=' + date + ', time=' + time + ', type=' + bookingType + ', duration=' + duration);

            // Store values in session storage for debugging
            sessionStorage.setItem('reservationDate', date);
            sessionStorage.setItem('reservationTime', time);
            sessionStorage.setItem('bookingType', bookingType);
            sessionStorage.setItem('reservationDuration', duration);

            debugLog('Data stored in sessionStorage');

            // If we have all required fields, allow form submission
            if(date && time) {
                debugLog('Form is being submitted');
                return true;
            }

            // Basic form validation
            if(!date || !time) {
                e.preventDefault();
                showError('Please select both date and time');
                debugLog('Form validation failed: missing date or time');
                return false;
            }

            // Allow the form to submit
            debugLog('Form validation passed');
            return true;
        });

        function showError(message) {
            debugLog('Error: ' + message);

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
            debugLog('Page fully loaded, min date set to: ' + today);

            // Add default values for testing
            if(!document.getElementById('reservationDate').value) {
                document.getElementById('reservationDate').value = today;
                debugLog('Default date set to today');
            }

            if(!document.getElementById('reservationTime').value) {
                document.getElementById('reservationTime').value = '12:00';
                debugLog('Default time set to 12:00');
            }
        });
    </script>
</body>
</html>