<%@ include file="admin-header.jsp" %>

<h1 style="color: var(--gold); margin-bottom: 2rem;">Reservation Management</h1>
<div class="card">
    <table class="data-table">
        <thead>
            <tr>
                <th>Reservation ID</th>
                <th>User ID</th>
                <th>Date</th>
                <th>Time</th>
                <th>Table</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
            List<Reservation> allReservations = (List<Reservation>) request.getAttribute("reservations");
            if (allReservations != null && !allReservations.isEmpty()) {
                for (Reservation reservation : allReservations) {
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
                <td><%= reservation.getUserId() %></td>
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
                <td colspan="7" style="text-align: center;">No reservations found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<%@ include file="admin-footer.jsp" %>