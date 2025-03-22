<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.tablebooknow.model.reservation.Reservation" %>
<%@ page import="com.tablebooknow.model.user.User" %>
<%@ page import="com.tablebooknow.model.payment.Payment" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details | Gourmet Reserve Admin</title>
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

        .edit-btn { background: var(--gold); color: var(--dark); }
        .cancel-btn { background: #dc3545; color: white; }
        .confirm-btn { background: #28a745; color: white; }
        .back-btn { background: #6c757d; color: white; }

        .reservation-section {
            margin-bottom: 2rem;
        }

        .section-title {
            color: var(--gold);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .detail-item {
            margin-bottom: 1.5rem;
        }

        .detail-label {
            font-size: 0.9rem;
            color: #aaa;
            margin-bottom: 0.3rem;
        }

        .detail-value {
            font-size: 1.1rem;
            color: var(--text);
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

        .payment-status {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 1rem;
        }

        .payment-status-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
        }

        .payment-completed { background: #28a745; }
        .payment-pending { background: #ffc107; }
        .payment-failed { background: #dc3545; }

        .special-requests {
            background: rgba(0, 0, 0, 0.2);
            padding: 1rem;
            border-radius: 8px;
            margin-top: 0.5rem;
            max-height: 150px;
            overflow-y: auto;
            font-style: italic;
        }

        .empty-message {
            color: #aaa;
            font-style: italic;
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

            .detail-grid {
                grid-template-columns: 1fr;
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

        // Get reservation details from request
        Reservation reservation = (Reservation) request.getAttribute("reservation");
        User user = (User) request.getAttribute("user");
        List<Payment> payments = (List<Payment>) request.getAttribute("payments");

        if (reservation == null) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        // Extract table type from table ID
        String tableType = "Unknown";
        if (reservation.getTableId() != null && !reservation.getTableId().isEmpty()) {
            char typeChar = reservation.getTableId().charAt(0);
            if (typeChar == 'f') tableType = "Family";
            else if (typeChar == 'l') tableType = "Luxury";
            else if (typeChar == 'r') tableType = "Regular";
            else if (typeChar == 'c') tableType = "Couple";
        }

        // Determine payment status
        String paymentStatus = "No Payment";
        BigDecimal paidAmount = BigDecimal.ZERO;

        if (payments != null && !payments.isEmpty()) {
            for (Payment payment : payments) {
                if ("COMPLETED".equals(payment.getStatus())) {
                    paymentStatus = "Paid";
                    if (payment.getAmount() != null) {
                        paidAmount = payment.getAmount();
                    }
                    break;
                } else if ("PENDING".equals(payment.getStatus())) {
                    paymentStatus = "Payment Pending";
                }
            }
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
            <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-item active-section">📅 Reservations</a>
            <a href="${pageContext.request.contextPath}/admin/tables" class="nav-item">🍽️ Table Management</a>
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
                <h1 class="page-title">Reservation Details</h1>
                <a href="${pageContext.request.contextPath}/admin/reservations" class="action-btn back-btn">Back to List</a>
            </div>

            <div class="card">
                <div class="reservation-section">
                    <h2 class="section-title">Reservation Information</h2>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <div class="detail-label">Reservation ID</div>
                            <div class="detail-value"><%= reservation.getId() %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Status</div>
                            <div class="detail-value">
                                <span class="status-badge status-<%= reservation.getStatus() %>">
                                    <%= reservation.getStatus().substring(0, 1).toUpperCase() + reservation.getStatus().substring(1) %>
                                </span>
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Date</div>
                            <div class="detail-value"><%= reservation.getReservationDate() %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Time</div>
                            <div class="detail-value"><%= reservation.getReservationTime() %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Duration</div>
                            <div class="detail-value"><%= reservation.getDuration() %> hours</div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Table ID</div>
                            <div class="detail-value"><%= reservation.getTableId() %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Table Type</div>
                            <div class="detail-value"><%= tableType %></div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Booking Type</div>
                            <div class="detail-value"><%= reservation.getBookingType() %></div>
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">Special Requests</div>
                        <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().isEmpty()) { %>
                            <div class="special-requests"><%= reservation.getSpecialRequests() %></div>
                        <% } else { %>
                            <div class="special-requests empty-message">No special requests</div>
                        <% } %>
                    </div>
                </div>

                <div class="reservation-section">
                    <h2 class="section-title">Customer Information</h2>
                    <div class="detail-grid">
                        <% if (user != null) { %>
                            <div class="detail-item">
                                <div class="detail-label">User ID</div>
                                <div class="detail-value"><%= user.getId() %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Username</div>
                                <div class="detail-value"><%= user.getUsername() %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Email</div>
                                <div class="detail-value"><%= user.getEmail() != null ? user.getEmail() : "Not provided" %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Phone</div>
                                <div class="detail-value"><%= user.getPhone() != null ? user.getPhone() : "Not provided" %></div>
                            </div>
                        <% } else { %>
                            <div class="detail-item">
                                <div class="detail-value empty-message">User information not available</div>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div class="reservation-section">
                    <h2 class="section-title">Payment Information</h2>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <div class="detail-label">Payment Status</div>
                            <div class="detail-value">
                                <div class="payment-status">
                                    <% if ("Paid".equals(paymentStatus)) { %>
                                        <div class="payment-status-icon payment-completed"></div>
                                        <span>Payment Completed</span>
                                    <% } else if ("Payment Pending".equals(paymentStatus)) { %>
                                        <div class="payment-status-icon payment-pending"></div>
                                        <span>Payment Pending</span>
                                    <% } else { %>
                                        <div class="payment-status-icon" style="background: #aaa;"></div>
                                        <span>No Payment</span>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <% if (!"No Payment".equals(paymentStatus)) { %>
                            <div class="detail-item">
                                <div class="detail-label">Amount</div>
                                <div class="detail-value">$<%= paidAmount %></div>
                            </div>
                        <% } %>

                        <% if (payments != null && !payments.isEmpty()) { %>
                            <div class="detail-item">
                                <div class="detail-label">Payment Details</div>
                                <div class="detail-value">
                                    <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                                        <thead>
                                            <tr>
                                                <th style="text-align: left; padding: 8px; border-bottom: 1px solid #444;">ID</th>
                                                <th style="text-align: left; padding: 8px; border-bottom: 1px solid #444;">Date</th>
                                                <th style="text-align: left; padding: 8px; border-bottom: 1px solid #444;">Amount</th>
                                                <th style="text-align: left; padding: 8px; border-bottom: 1px solid #444;">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Payment payment : payments) { %>
                                                <tr>
                                                    <td style="padding: 8px; border-bottom: 1px solid #333;"><%= payment.getId().substring(0, 8) %>...</td>
                                                    <td style="padding: 8px; border-bottom: 1px solid #333;"><%= payment.getCompletedAt() != null ? payment.getCompletedAt().toString().substring(0, 10) : "N/A" %></td>
                                                    <td style="padding: 8px; border-bottom: 1px solid #333;">$<%= payment.getAmount() != null ? payment.getAmount() : "0.00" %></td>
                                                    <td style="padding: 8px; border-bottom: 1px solid #333;"><%= payment.getStatus() %></td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>

                <div style="margin-top: 2rem; display: flex; gap: 1rem;">
                    <a href="${pageContext.request.contextPath}/admin/reservations/edit?id=<%= reservation.getId() %>" class="action-btn edit-btn">Edit Reservation</a>

                    <% if (!"confirmed".equals(reservation.getStatus()) && !"cancelled".equals(reservation.getStatus())) { %>
                        <form action="${pageContext.request.contextPath}/admin/reservations/confirm" method="post" style="display: inline;">
                            <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                            <button type="submit" class="action-btn confirm-btn">Confirm Reservation</button>
                        </form>
                    <% } %>

                    <% if (!"cancelled".equals(reservation.getStatus())) { %>
                        <form action="${pageContext.request.contextPath}/admin/reservations/cancel" method="post" style="display: inline;">
                            <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                            <button type="submit" class="action-btn cancel-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel Reservation</button>
                        </form>
                    <% } %>
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