<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table Management | Gourmet Reserve Admin</title>
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

        .table-overview {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .table-card {
            background: rgba(30, 30, 30, 0.8);
            border-radius: 10px;
            padding: 1.5rem;
            text-align: center;
            position: relative;
            transition: transform 0.3s, box-shadow 0.3s;
            overflow: hidden;
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .table-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3);
        }

        .table-card.reserved {
            border-color: rgba(220, 53, 69, 0.5);
        }

        .table-card.available {
            border-color: rgba(40, 167, 69, 0.5);
        }

        .status-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 30px;
            font-size: 0.7rem;
            font-weight: 500;
            text-transform: uppercase;
        }

        .status-reserved {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
        }

        .status-available {
            background: rgba(40, 167, 69, 0.2);
            color: #28a745;
        }

        .table-visualization {
            width: 120px;
            height: 120px;
            margin: 0 auto 1.5rem;
            position: relative;
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

        .table-name {
            font-size: 1.2rem;
            font-weight: 500;
            color: var(--gold);
            margin-bottom: 0.5rem;
        }

        .table-details {
            font-size: 0.9rem;
            color: #bbb;
            margin-bottom: 1rem;
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

        .date-display {
            background: rgba(212, 175, 55, 0.1);
            padding: 0.8rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            text-align: center;
            font-size: 1.2rem;
            color: var(--gold);
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
        List<String> reservedTables = (List<String>) request.getAttribute("reservedTables");
        Map<String, Map<String, Object>> tableTypes = (Map<String, Map<String, Object>>) request.getAttribute("tableTypes");
        String selectedDate = (String) request.getAttribute("selectedDate");
        String formattedDate = (String) request.getAttribute("formattedDate");

        // Set default date to today if not provided
        if (selectedDate == null) {
            selectedDate = LocalDate.now().toString();
        }

        if (formattedDate == null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM d, yyyy");
            formattedDate = LocalDate.parse(selectedDate).format(formatter);
        }

        if (reservedTables == null) {
            reservedTables = new java.util.ArrayList<>();
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
                <h1 class="page-title">Table Management</h1>
            </div>

            <div class="card">
                <form action="${pageContext.request.contextPath}/admin/tables/filter" method="get" class="filters">
                    <input type="date" name="date" class="filter-control" value="<%= selectedDate %>" required>
                    <button type="submit" class="filter-btn">Filter Tables</button>
                </form>

                <div class="date-display">
                    Table Availability for <%= formattedDate %>
                </div>

                <!-- Floor 1 Section -->
                <div class="table-section">
                    <h2 class="section-title">Floor 1 Tables</h2>
                    <div class="table-overview">
                        <%
                        String[] floor1Types = {"f1", "r1", "c1"};
                        for (String typeCode : floor1Types) {
                            if (tableTypes != null && tableTypes.containsKey(typeCode)) {
                                Map<String, Object> typeConfig = tableTypes.get(typeCode);
                                String name = (String) typeConfig.get("name");
                                int count = (int) typeConfig.get("count");
                                int capacity = (int) typeConfig.get("capacity");

                                for (int i = 1; i <= count; i++) {
                                    String tableId = typeCode + "-" + i;
                                    boolean isReserved = reservedTables.contains(tableId);
                        %>
                        <div class="table-card <%= isReserved ? "reserved" : "available" %>">
                            <span class="status-badge <%= isReserved ? "status-reserved" : "status-available" %>">
                                <%= isReserved ? "Reserved" : "Available" %>
                            </span>

                            <div class="table-visualization">
                                <div class="table-shape <%= typeCode.charAt(0) == 'f' ? "family" :
                                                          typeCode.charAt(0) == 'r' ? "regular" :
                                                          typeCode.charAt(0) == 'l' ? "luxury" : "couple" %>">
                                </div>
                                <%
                                // Add chairs based on table type
                                if (typeCode.charAt(0) == 'f') { // Family table (6 chairs)
                                    for (int j = 0; j < 6; j++) {
                                        int angle = j * 60;
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (60 * Math.cos(radians));
                                        int y = (int) (60 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                } else if (typeCode.charAt(0) == 'r') { // Regular table (4 chairs)
                                    int[] angles = {0, 90, 180, 270};
                                    for (int angle : angles) {
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (50 * Math.cos(radians));
                                        int y = (int) (50 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                } else if (typeCode.charAt(0) == 'c') { // Couple table (2 chairs)
                                    int[] angles = {0, 180};
                                    for (int angle : angles) {
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (45 * Math.cos(radians));
                                        int y = (int) (45 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                }
                                %>
                            </div>

                            <div class="table-name">
                                <%= name %> Table <%= i %>
                            </div>

                            <div class="table-details">
                                ID: <%= tableId %><br>
                                Capacity: <%= capacity %> people<br>
                                Floor: 1
                            </div>

                            <a href="${pageContext.request.contextPath}/admin/tables/status?id=<%= tableId %>&date=<%= selectedDate %>" class="action-btn" style="display: inline-block; padding: 8px 15px; background: var(--gold); color: var(--dark); text-decoration: none; border-radius: 6px; font-size: 0.9rem; cursor: pointer; transition: transform 0.3s;">Check Status</a>
                        </div>
                        <%
                                }
                            }
                        }
                        %>
                    </div>
                </div>

                <!-- Floor 2 Section -->
                <div class="table-section">
                    <h2 class="section-title">Floor 2 Tables</h2>
                    <div class="table-overview">
                        <%
                        String[] floor2Types = {"f2", "l2", "c2"};
                        for (String typeCode : floor2Types) {
                            if (tableTypes != null && tableTypes.containsKey(typeCode)) {
                                Map<String, Object> typeConfig = tableTypes.get(typeCode);
                                String name = (String) typeConfig.get("name");
                                int count = (int) typeConfig.get("count");
                                int capacity = (int) typeConfig.get("capacity");

                                for (int i = 1; i <= count; i++) {
                                    String tableId = typeCode + "-" + i;
                                    boolean isReserved = reservedTables.contains(tableId);
                        %>
                        <div class="table-card <%= isReserved ? "reserved" : "available" %>">
                            <span class="status-badge <%= isReserved ? "status-reserved" : "status-available" %>">
                                <%= isReserved ? "Reserved" : "Available" %>
                            </span>

                            <div class="table-visualization">
                                <div class="table-shape <%= typeCode.charAt(0) == 'f' ? "family" :
                                                          typeCode.charAt(0) == 'r' ? "regular" :
                                                          typeCode.charAt(0) == 'l' ? "luxury" : "couple" %>">
                                </div>
                                <%
                                // Add chairs based on table type
                                if (typeCode.charAt(0) == 'f') { // Family table (6 chairs)
                                    for (int j = 0; j < 6; j++) {
                                        int angle = j * 60;
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (60 * Math.cos(radians));
                                        int y = (int) (60 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                } else if (typeCode.charAt(0) == 'l') { // Luxury table (10 chairs)
                                    for (int j = 0; j < 10; j++) {
                                        int angle = j * 36;
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (70 * Math.cos(radians));
                                        int y = (int) (70 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                } else if (typeCode.charAt(0) == 'c') { // Couple table (2 chairs)
                                    int[] angles = {0, 180};
                                    for (int angle : angles) {
                                        double radians = Math.toRadians(angle);
                                        int x = (int) (45 * Math.cos(radians));
                                        int y = (int) (45 * Math.sin(radians));
                                %>
                                <div class="chair" style="left: <%= 60 + x %>px; top: <%= 60 + y %>px;"></div>
                                <%
                                    }
                                }
                                %>
                            </div>

                            <div class="table-name">
                                <%= name %> Table <%= i %>
                            </div>

                            <div class="table-details">
                                ID: <%= tableId %><br>
                                Capacity: <%= capacity %> people<br>
                                Floor: 2
                            </div>

                            <a href="${pageContext.request.contextPath}/admin/tables/status?id=<%= tableId %>&date=<%= selectedDate %>" class="action-btn" style="display: inline-block; padding: 8px 15px; background: var(--gold); color: var(--dark); text-decoration: none; border-radius: 6px; font-size: 0.9rem; cursor: pointer; transition: transform 0.3s;">Check Status</a>
                        </div>
                        <%
                                }
                            }
                        }
                        %>
                    </div>
                </div>
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