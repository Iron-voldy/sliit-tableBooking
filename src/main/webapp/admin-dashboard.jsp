<%@ include file="admin-header.jsp" %>

<%
    // Get attributes specific to dashboard
    List<Reservation> upcomingReservations = (List<Reservation>) request.getAttribute("upcomingReservations");

    // Stats
    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalReservations = (Integer) request.getAttribute("totalReservations");
    Integer pendingReservations = (Integer) request.getAttribute("pendingReservations");
    Integer confirmedReservations = (Integer) request.getAttribute("confirmedReservations");

    // Format values or set defaults if null
    if (totalUsers == null) totalUsers = 0;
    if (totalReservations == null) totalReservations = 0;
    if (pendingReservations == null) pendingReservations = 0;
    if (confirmedReservations == null) confirmedReservations = 0;
%>

<h1 style="color: var(--gold); margin-bottom: 2rem;">Dashboard Overview</h1>

<!-- Statistics Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-number"><%= totalUsers %></div>
        <div class="stat-label">Total Users</div>
    </div>
    <div class="stat-card">
        <div class="stat-number"><%= totalReservations %></div>
        <div class="stat-label">Total Reservations</div>
    </div>
    <div class="stat-card">
        <div class="stat-number"><%= pendingReservations %></div>
        <div class="stat-label">Pending Reservations</div>
    </div>
    <div class="stat-card">
        <div class="stat-number"><%= confirmedReservations %></div>
        <div class="stat-label">Confirmed Reservations</div>
    </div>
</div>

<!-- Upcoming Reservations -->
<div class="card">
    <h2 style="margin-bottom: 1rem; color: var(--gold);">Today's Reservations</h2>
    <table class="data-table">
        <thead>
            <tr>
                <th>Reservation ID</th>
                <th>Date</th>
                <th>Time</th>
                <th>Table</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
            if (upcomingReservations != null && !upcomingReservations.isEmpty()) {
                for (Reservation reservation : upcomingReservations) {
                    // Determine status color
                    String statusColor = "#fff";
                    if ("confirmed".equals(reservation.getStatus())) {
                        statusColor = "#4CAF50"; // Green for confirmed
                    } else if ("pending".equals(reservation.getStatus())) {
                        statusColor = "#FFC107"; // Yellow for pending
                    } else if ("cancelled".equals(reservation.getStatus())) {
                        statusColor = "#F44336"; // Red for cancelled
                    }
            %>
            <tr>
                <td><%= reservation.getId() %></td>
                <td><%= reservation.getReservationDate() %></td>
                <td><%= reservation.getReservationTime() %></td>
                <td><%= reservation.getTableId() %></td>
                <td><span style="color: <%= statusColor %>;"><%= reservation.getStatus() %></span></td>
                <td>
                    <button class="action-btn edit-btn" onclick="location.href='${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>'">View</button>
                    <form style="display: inline;" method="post" action="${pageContext.request.contextPath}/admin/reservations/cancel">
                        <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                        <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel</button>
                    </form>
                </td>
            </tr>
            <%
                }
            } else {
            %>
            <tr>
                <td colspan="6" style="text-align: center;">No upcoming reservations found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<%@ include file="admin-footer.jsp" %>