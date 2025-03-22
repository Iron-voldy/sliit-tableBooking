<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.tablebooknow.model.admin.Admin" %>
<%@ page import="com.tablebooknow.model.user.User" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile | Gourmet Reserve</title>
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

        .profile-header {
            display: flex;
            align-items: center;
            margin-bottom: 2rem;
        }

        .profile-picture {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: var(--gold);
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 2.5rem;
            color: var(--dark);
            font-weight: bold;
            margin-right: 1.5rem;
        }

        .profile-info h1 {
            color: var(--gold);
            font-family: 'Playfair Display', serif;
            margin-bottom: 0.5rem;
        }

        .profile-info p {
            opacity: 0.8;
        }

        .tabs {
            display: flex;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.2);
        }

        .tab {
            padding: 0.8rem 1.5rem;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.3s;
        }

        .tab.active {
            border-bottom: 2px solid var(--gold);
            color: var(--gold);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            color: var(--gold);
        }

        .form-input {
            width: 100%;
            padding: 0.8rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 8px;
            color: var(--text);
            font-size: 1rem;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--gold);
        }

        .btn {
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            border: none;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-block;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .btn-primary {
            background: var(--gold);
            color: var(--dark);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text);
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .info-section {
            background: rgba(255, 255, 255, 0.05);
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .info-row {
            display: flex;
            margin-bottom: 1rem;
        }

        .info-label {
            flex: 0 0 150px;
            color: var(--gold);
        }

        .info-value {
            flex: 1;
        }

        .role-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            background: rgba(212, 175, 55, 0.2);
            color: var(--gold);
            border: 1px solid rgba(212, 175, 55, 0.4);
        }

        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 8px;
        }

        .alert-success {
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid rgba(76, 175, 80, 0.4);
            color: #4CAF50;
        }

        .alert-error {
            background: rgba(244, 67, 54, 0.2);
            border: 1px solid rgba(244, 67, 54, 0.4);
            color: #F44336;
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
        String adminRole = (String) session.getAttribute("adminRole");

        // Get admin object from request attribute
        Object adminObject = request.getAttribute("admin");
        String fullName = "";
        String email = "";
        boolean isUserAdmin = false;

        if (adminObject instanceof Admin) {
            Admin admin = (Admin) adminObject;
            fullName = admin.getFullName();
            email = admin.getEmail();
        } else if (adminObject instanceof User) {
            User user = (User) adminObject;
            fullName = user.getUsername();
            email = user.getEmail();
            isUserAdmin = true;
        }

        if (fullName == null || fullName.isEmpty()) {
            fullName = adminUsername;
        }

        // Get menu from session
        Map<String, Map<String, String>> adminMenu =
            (Map<String, Map<String, String>>) session.getAttribute("adminMenu");
    %>

    <div class="dashboard-container">
        <div class="sidebar">
            <h2 style="color: var(--gold); margin-bottom: 2rem;">Admin Panel</h2>

            <div class="user-info" style="margin-bottom: 2rem;">
                <div class="user-avatar" style="width: 30px; height: 30px; background: var(--gold); border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; color: var(--dark); font-weight: bold; margin-right: 10px;"><%= adminUsername.charAt(0) %></div>
                <span><%= adminUsername %></span>
            </div>

            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">📊 Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item">🍽️ Table Management</a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item">👥 User Management</a>
            <a href="${pageContext.request.contextPath}/admin/profile" class="nav-item active-section">👤 My Profile</a>

            <% if ("superadmin".equals(adminRole)) { %>
                <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item">⚙️ System Settings</a>
            <% } %>

            <form action="${pageContext.request.contextPath}/admin/logout" method="get">
                <button type="submit" style="margin-top: 2rem; width: 100%; padding: 0.8rem; background: rgba(244, 67, 54, 0.2); color: #F44336; border: 1px solid rgba(244, 67, 54, 0.4); border-radius: 8px; cursor: pointer;">Logout</button>
            </form>
        </div>

        <div class="main-content">
            <!-- Success/Error Message Alerts -->
            <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("successMessage") %>
            </div>
            <% } %>

            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <%= request.getAttribute("errorMessage") %>
            </div>
            <% } %>

            <div class="card">
                <div class="profile-header">
                    <div class="profile-picture">
                        <%= adminUsername.charAt(0) %>
                    </div>
                    <div class="profile-info">
                        <h1><%= fullName %></h1>
                        <p><span class="role-badge"><%= adminRole.substring(0, 1).toUpperCase() + adminRole.substring(1) %></span></p>
                    </div>
                </div>

                <div class="tabs">
                    <div class="tab active" data-tab="info">Account Information</div>
                    <div class="tab" data-tab="password">Change Password</div>
                </div>

                <!-- Account Information Tab -->
                <div class="tab-content active" id="info-tab">
                    <div class="info-section">
                        <h3 style="color: var(--gold); margin-bottom: 1rem;">Personal Information</h3>

                        <div class="info-row">
                            <div class="info-label">Username:</div>
                            <div class="info-value"><%= adminUsername %></div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Full Name:</div>
                            <div class="info-value"><%= fullName %></div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Email:</div>
                            <div class="info-value"><%= email %></div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Role:</div>
                            <div class="info-value"><%= adminRole.substring(0, 1).toUpperCase() + adminRole.substring(1) %></div>
                        </div>

                        <div class="info-row">
                            <div class="info-label">Account Type:</div>
                            <div class="info-value"><%= isUserAdmin ? "User Administrator" : "System Administrator" %></div>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/admin/updateProfile" method="post">
                        <h3 style="color: var(--gold); margin-bottom: 1rem;">Edit Profile</h3>

                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="fullName" class="form-input" value="<%= fullName %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-input" value="<%= email %>" required>
                        </div>

                        <button type="submit" class="btn btn-primary">Update Profile</button>
                    </form>
                </div>

                <!-- Change Password Tab -->
                <div class="tab-content" id="password-tab">
                    <form action="${pageContext.request.contextPath}/admin/changePassword" method="post">
                        <h3 style="color: var(--gold); margin-bottom: 1rem;">Change Password</h3>

                        <div class="form-group">
                            <label class="form-label">Current Password</label>
                            <input type="password" name="currentPassword" class="form-input" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">New Password</label>
                            <input type="password" name="newPassword" class="form-input" required minlength="8">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="form-input" required minlength="8">
                        </div>

                        <button type="submit" class="btn btn-primary">Change Password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Tab switching functionality
        function switchToTab(tabId) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });

            // Deactivate all tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });

            // Activate the selected tab and content
            document.getElementById(tabId + '-tab').classList.add('active');
            document.querySelector(`.tab[data-tab="${tabId}"]`).classList.add('active');
        }

        // Add event listeners to tabs
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function() {
                switchToTab(this.getAttribute('data-tab'));
            });
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(() => {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>