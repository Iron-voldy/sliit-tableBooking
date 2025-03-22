<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table Status | Gourmet Reserve Admin</title>
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
            background: var(--dark);
            font-family: 'Roboto', sans-serif;
            color: var(--text);
        }

        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: 100vh;
        }

        .sidebar {
            background: rgba(20, 20, 20, 0.95);
            padding: 2rem;
            border-right: 1px solid rgba(212, 175, 55, 0.3);
        }

        .main-content {
            padding: 2rem;
            background: rgba(30, 30, 30, 0.95);
            overflow-y: auto;
        }

        .nav-item {
            padding: 1rem;
            margin: 0.5rem 0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text);
            text-decoration: none;
            display: block;
        }

        .nav-item:hover {
            background: rgba(212, 175, 55, 0.1);
        }

        .active-section {
            background: rgba(212, 175, 55, 0.2);
            color: var(--gold);
        }

        .card {
            background: rgba(40, 40, 40, 0.6);
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .page-title {
            color: var(--gold);
            font-size: 2rem;
            font-family: 'Playfair Display', serif;
        }

        .action-btn {
            padding: 0.5rem 1rem;
            margin: 0 0.3rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            transition: transform 0.3s ease;
            display: inline-block;
            text-decoration: none;
            text-align: center;
        }

        .action-btn:hover {
            transform: translateY(-2px);
        }

        .back-btn { background: #6c757d; color: white; }

        .section-title {
            color: var(--gold);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .filters {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .filter-control {
            padding: 0.7rem;
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            color: var(--text);
            transition: border-color 0.3s;
        }

        .filter-control:focus {
            outline: none;
            border-color: var(--gold);
        }

        .filter-btn {
            padding: 0.7rem 1rem;
            background: var(--gold);
            color: var(--dark);
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            transition: transform 0.3s;
        }

        .filter-btn:hover {
            transform: translateY(-2px);
        }

        .table-info {
            display: flex;
            flex-wrap: wrap;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .table-visualization {
            width: 150px;
            height: 150px;
            position: relative;
            margin-right: 1.5rem;
        }

        .table-shape {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #4a4a4a;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
        }

        .table-shape.family {
            width: 90px;
            height: 70px;
        }

        .table-shape.regular {
            width: 70px;
            height: 70px;
        }

        .table-shape.luxury {
            width: 100px;
            height: 80px;
        }

        .table-shape.couple {
            width: 60px;
            height: 60px;
        }

        .chair {
            position: absolute;
            width: 15px;
            height: 15px;
            background: #333;
            border-radius: 50%;
        }

        .table-details {
            flex: 1;
            min-width: 300px;
        }

        .detail-item {
            margin-bottom: 1rem;
            display: flex;
            align-items: baseline;
        }

        .detail-label {
            width: 120px;
            font-size: 0.9rem;
            color: #aaa;
        }

        .detail-value {
            font-size: 1.1rem;
            color: var(--text);
        }

        .reservation-timeline {
            margin-top: 2rem;
            width: 100%;
            overflow-x: auto;
        }

        .timeline-container {
            display: flex;
            flex-direction: column;
            min-width: 800px;
            margin-top: 1rem;
        }

        .timeline-hours {
            display: flex;
            margin-bottom: 0.5rem;
        }

        .hour-mark {
            width: 60px;
            text-align: center;
            padding: 0.5rem;
            font-size: 0.9rem;
            color: #aaa;
        }

        .timeline {
            position: relative;
            height: 50px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 6px;
            margin-bottom: 1.5rem;
        }

        .reservation-slot {
            position: absolute;
            height: 100%;
            background: rgba(212, 175, 55, 0.3);
            border-radius: 6px;
            padding: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            cursor: pointer;
            transition: background 0.3s;
            text-overflow: ellipsis;
            white-space: nowrap;
            overflow: hidden;
        }

        .reservation-slot:hover {
            background: rgba(212, 175, 55, 0.5);
        }

        .reservation-slot.pending {
            background: rgba(255, 193, 7, 0.3);
        }

        .reservation-slot.confirmed {
            background: rgba(40, 167, 69, 0.3);
        }

        .reservation-slot.cancelled {
            background: rgba(220, 53, 69, 0.3);
            text-decoration: line-through;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .data-table th, .data-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid rgba(212, 175, 55, 0.1);
        }

        .data-table th {
            background: rgba(212, 175, 55, 0.1);
            color: var(--gold);
        }

        .status-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 30px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .status-pending { background: rgba(255, 193, 7, 0.2); color: #ffc107; }
        .status-confirmed { background: rgba(40, 167, 69, 0.2); color: #28a745; }
        .status-cancelled { background: rgba(220, 53, 69, 0.2); color: #dc3545; }

        .date-display {
            background: rgba(212, 175, 55, 0.1);
            padding: 0.8rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            text-align: center;
            font-size: 1.2rem;
            color: var(--gold);
        }

        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        .alert-success {
            background: rgba(40, 167, 69, 0.2);
            border: 1px solid rgba(40, 167, 69, 0.4);
            color: #28a745;
        }

        .alert-danger {
            background: rgba(220, 53, 69, 0.2);
            border: 1px solid rgba(220, 53, 69, 0.4);
            color: #dc3545;
        }

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .filters {
                flex-direction: column;
            }

            .detail-item {
                flex-direction: column;
            }

            .detail-label {
                width: 100%;
                margin-bottom: 0.3rem;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if admin is logged in
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String adminUsername = (String) session.getAttribute("adminUsername");

        // Get data from request attributes
        String tableId = (String) request.getAttribute("tableId");
        List<Reservation> tableReservations = (List<Reservation>) request.getAttribute("tableReservations");
        String selectedDate = (String) request.getAttribute("selectedDate");
        Map<String, Object> tableConfig = (Map<String, Object>) request.getAttribute("tableConfig");
        String formattedDate = (String) request.getAttribute("formattedDate");

        // Set default date to today if not provided
        if (selectedDate == null) {
            selectedDate = LocalDate.now().toString();
        }

        if (formattedDate == null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM d, yyyy");
            formattedDate = LocalDate.parse(selectedDate).format(formatter);
        }

        // Extract table information
        String tableType = "Unknown";
        int capacity = 0;
        int floor = 0;
        int tableNumber = 0;

        if (tableConfig != null) {
            tableType = (String) tableConfig.get("typeName");
            capacity = (int) tableConfig.get("capacity");
            floor = (int) tableConfig.get("floor");
            tableNumber = (int) tableConfig.get("number");
        } else if (tableId != null) {
            // If tableConfig is not available, try to extract from tableId
            char typeChar = tableId.charAt(0);
            if (typeChar == 'f') tableType = "Family";
            else if (typeChar == 'l') tableType = "Luxury";
            else if (typeChar == 'r') tableType = "Regular";
            else if (typeChar == 'c') tableType = "Couple";

            floor = Character.getNumericValue(tableId.charAt(1));

            // Try to extract table number from ID (format: x#-#)
            String[] parts = tableId.split("-");
            if (parts.length > 1) {
                try {
                    tableNumber = Integer.parseInt(parts[1]);
                } catch (NumberFormatException e) {
                    // Ignore parsing errors
                }
            }

            // Set capacity based on table type
            if ("Family".equals(tableType)) capacity = 6;
            else if ("Luxury".equals(tableType)) capacity = 10;
            else if ("Regular".equals(tableType)) capacity = 4;
            else if ("Couple".equals(tableType)) capacity = 2;
        }
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>

            <div style="display: flex; align-items: center; margin-bottom: 2rem;">
                <div style="width: 30px; height: 30px; background: var(--gold); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 10px; color: var(--dark); font-weight: bold;">
                    <%= adminUsername.charAt(0) %>
                </div>
                <span><%= adminUsername %></span>
            </div>

            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">📊 Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item active-section">🍽️ Table Management</a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item">👥 User Management</a>

            <a href="${pageContext.request.contextPath}/admin/logout" class="nav-item" style="margin-top: 2rem; color: #dc3545;">🚪 Logout</a>
        </div>

        <div class="main-content">
            <!-- Success/Error Message Alerts -->
            <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("successMessage") %>
            </div>
            <% } %>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("errorMessage") %>
            </div>
            <% } %>

            <div class="page-header">
                <h1 class="page-title">Table Status</h1>
                <a href="${pageContext.request.contextPath}/admin/tables?date=<%= selectedDate %>" class="action-btn back-btn">Back to Tables</a>
            </div>

            <div class="card">
                <form action="${pageContext.request.contextPath}/admin/tables/status" method="get" class="filters">
                    <input type="hidden" name="id" value="<%= tableId %>">
                    <input type="date" name="date" class="filter-control" value="<%= selectedDate %>" required>
                    <button type="submit" class="filter-btn">Change Date</button>
                </form>

                <div class="date-display">
                    <%= tableType %> Table <%= tableNumber %> Status for <%= formattedDate %>
                </div>

                <div class="table-info">
                    <div class="table-visualization">
                        <div class="table-shape <%= tableType.toLowerCase() %>">
                        </div>
                        <%
                        // Add chairs based on table type
                        if ("Family".equals(tableType)) { // Family table (6 chairs)
                            for (int j = 0; j < 6; j++) {
                                int angle = j * 60;
                                double radians = Math.toRadians(angle);
                                int x = (int) (60 * Math.cos(radians));
                                int y = (int) (60 * Math.sin(radians));
                        %>
                        <div class="chair" style="left: <%= 75 + x %>px; top: <%= 75 + y %>px;"></div>
                        <%
                            }
                        } else if ("Regular".equals(tableType)) { // Regular table (4 chairs)
                            int[] angles = {0, 90, 180, 270};
                            for (int angle : angles) {
                                double radians = Math.toRadians(angle);
                                int x = (int) (50 * Math.cos(radians));
                                int y = (int) (50 * Math.sin(radians));
                        %>
                        <div class="chair" style="left: <%= 75 + x %>px; top: <%= 75 + y %>px;"></div>
                        <%
                            }
                        } else if ("Luxury".equals(tableType)) { // Luxury table (10 chairs)
                            for (int j = 0; j < 10; j++) {
                                int angle = j * 36;
                                double radians = Math.toRadians(angle);
                                int x = (int) (70 * Math.cos(radians));
                                int y = (int) (70 * Math.sin(radians));
                        %>
                        <div class="chair" style="left: <%= 75 + x %>px; top: <%= 75 + y %>px;"></div>
                        <%
                            }
                        } else if ("Couple".equals(tableType)) { // Couple table (2 chairs)
                            int[] angles = {0, 180};
                            for (int angle : angles) {
                                double radians = Math.toRadians(angle);
                                int x = (int) (45 * Math.cos(radians));
                                int y = (int) (45 * Math.sin(radians));
                        %>
                        <div class="chair" style="left: <%= 75 + x %>px; top: <%= 75 + y %>px;"></div>
                        <%
                            }
                        }
                        %>
                    </div>

                    <div class="table-details">
                        <div class="detail-item">
                            <div class="detail-label">Table ID:</div>
                            <div class="detail-value"><%= tableId %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Table Type:</div>
                            <div class="detail-value"><%= tableType %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Capacity:</div>
                            <div class="detail-value"><%= capacity %> people</div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Floor:</div>
                            <div class="detail-value"><%= floor %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Reservations:</div>
                            <div class="detail-value">
                                <%= tableReservations != null ? tableReservations.size() : 0 %> for today
                            </div>
                        </div>
                    </div>
                </div>

                <h2 class="section-title">Reservations Timeline</h2>

                <div class="reservation-timeline">
                    <div class="timeline-container">
                        <div class="timeline-hours">
                            <% for (int hour = 10; hour <= 22; hour++) { %>
                                <div class="hour-mark"><%= hour %>:00</div>
                            <% } %>
                        </div>

                        <div class="timeline">
                            <%
                            if (tableReservations != null && !tableReservations.isEmpty()) {
                                for (Reservation reservation : tableReservations) {
                                    try {
                                        // Parse time and calculate position
                                        String[] timeParts = reservation.getReservationTime().split(":");
                                        int hours = Integer.parseInt(timeParts[0]);
                                        int minutes = Integer.parseInt(timeParts[1]);

                                        // Calculate position (10:00 = 0%, 22:00 = 100%)
                                        double totalMinutes = (hours * 60) + minutes;
                                        double startPercent = ((totalMinutes - (10 * 60)) / (12 * 60)) * 100;

                                        // Calculate width based on duration
                                        double widthPercent = (reservation.getDuration() * 60) / (12 * 60) * 100;

                                        // Make sure values are within range
                                        startPercent = Math.max(0, Math.min(startPercent, 100));
                                        widthPercent = Math.min(widthPercent, 100 - startPercent);

                                        // Format time for display
                                        String startTime = String.format("%02d:%02d", hours, minutes);
                                        int endHours = hours + reservation.getDuration();
                                        String endTime = String.format("%02d:%02d", endHours, minutes);
                            %>
                            <div class="reservation-slot <%= reservation.getStatus() %>"
                                 style="left: <%= startPercent %>%; width: <%= widthPercent %>%;"
                                 onclick="location.href='${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>'">
                                <%= startTime %> - <%= endTime %>
                            </div>
                            <%
                                    } catch (Exception e) {
                                        // Skip this reservation if there's a parsing error
                                        continue;
                                    }
                                }
                            }
                            %>
                        </div>
                    </div>
                </div>

                <h2 class="section-title">Reservations for <%= tableType %> Table <%= tableNumber %></h2>

                <% if (tableReservations != null && !tableReservations.isEmpty()) { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Reservation ID</th>
                            <th>Time</th>
                            <th>Duration</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        for (Reservation reservation : tableReservations) {
                            String startTime = reservation.getReservationTime();
                            String[] timeParts = startTime.split(":");
                            int hours = Integer.parseInt(timeParts[0]);
                            int minutes = Integer.parseInt(timeParts[1]);
                            int endHours = hours + reservation.getDuration();
                            String endTime = String.format("%02d:%02d", endHours, minutes);
                            String timeSlot = startTime + " - " + endTime;
                        %>
                        <tr>
                            <td><%= reservation.getId().substring(0, 8) %>...</td>
                            <td><%= timeSlot %></td>
                            <td><%= reservation.getDuration() %> hours</td>
                            <td>
                                <span class="status-badge status-<%= reservation.getStatus() %>">
                                    <%= reservation.getStatus().substring(0, 1).toUpperCase() + reservation.getStatus().substring(1) %>
                                </span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>" class="action-btn" style="display: inline-block; padding: 5px 10px; background: #3f51b5; color: white; text-decoration: none; border-radius: 4px; font-size: 0.8rem;">View</a>

                                <% if (!"cancelled".equals(reservation.getStatus())) { %>
                                <form action="${pageContext.request.contextPath}/admin/reservations/cancel" method="post" style="display: inline;">
                                    <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                                    <button type="submit" onclick="return confirm('Are you sure you want to cancel this reservation?')" class="action-btn" style="padding: 5px 10px; background: #dc3545; color: white; text-decoration: none; border-radius: 4px; font-size: 0.8rem; border: none; cursor: pointer;">Cancel</button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <p style="text-align: center; padding: 20px; color: #999; font-style: italic;">No reservations found for this table on <%= formattedDate %></p>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.style.display = 'none', 500);
            });
        }, 5000);
    </script>
</body>
</html>