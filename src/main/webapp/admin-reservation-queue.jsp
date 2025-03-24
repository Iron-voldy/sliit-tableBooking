<%@ include file="admin-header.jsp" %>

<h1 style="color: var(--gold); margin-bottom: 2rem;">Reservation Queue Management</h1>

<%
    List<Reservation> pendingReservations = (List<Reservation>) request.getAttribute("pendingReservations");
    Reservation nextPending = (Reservation) request.getAttribute("nextPending");
    String sorted = (String) request.getAttribute("sorted");
    boolean isSorted = "true".equals(sorted);
%>

<div class="card" style="margin-bottom: 2rem;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
        <h2>Queue Controls</h2>
        <div style="display: flex; gap: 1rem;">
            <a href="${pageContext.request.contextPath}/admin/reservations/queue?sort=time" class="action-btn edit-btn"
               style="<%= isSorted ? "background-color: #4CAF50;" : "" %>">
                Sort by Time
            </a>
            <form method="post" action="${pageContext.request.contextPath}/admin/reservations/queue/refresh">
                <button type="submit" class="action-btn edit-btn">Refresh Queue</button>
            </form>
        </div>
    </div>

    <% if (nextPending != null) { %>
    <div style="margin-bottom: 2rem; padding: 1.5rem; background: rgba(0, 0, 0, 0.2); border-radius: 10px;">
        <h3 style="color: var(--gold); margin-bottom: 1rem;">Next in Queue</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem;">
            <div>
                <p><strong>Reservation ID:</strong> <%= nextPending.getId() %></p>
                <p><strong>Date:</strong> <%= nextPending.getReservationDate() %></p>
                <p><strong>Time:</strong> <%= nextPending.getReservationTime() %></p>
            </div>
            <div>
                <p><strong>Table:</strong> <%= nextPending.getTableId() %></p>
                <p><strong>Duration:</strong> <%= nextPending.getDuration() %> hours</p>
                <p><strong>Type:</strong> <%= nextPending.getBookingType() %></p>
            </div>
        </div>
        <div style="margin-top: 1rem;">
            <form method="post" action="${pageContext.request.contextPath}/admin/reservations/queue/process" style="display: inline-block; margin-right: 1rem;">
                <button type="submit" class="action-btn edit-btn" style="background-color: #4CAF50;">Process & Confirm</button>
            </form>
            <a href="${pageContext.request.contextPath}/admin/reservations/view?id=<%= nextPending.getId() %>" class="action-btn edit-btn">View Details</a>
        </div>
    </div>
    <% } else { %>
    <div style="text-align: center; padding: 2rem; background: rgba(0, 0, 0, 0.2); border-radius: 10px; margin-bottom: 2rem;">
        <p>No pending reservations in the queue</p>
    </div>
    <% } %>
</div>

<div class="card">
    <h2 style="margin-bottom: 1.5rem;">Pending Reservations Queue</h2>

    <% if (pendingReservations != null && !pendingReservations.isEmpty()) { %>
    <table class="data-table">
        <thead>
            <tr>
                <th>Queue Position</th>
                <th>Reservation ID</th>
                <th>Date</th>
                <th>Time</th>
                <th>Table</th>
                <th>User ID</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
            int position = 1;
            for (Reservation reservation : pendingReservations) {
            %>
            <tr>
                <td><%= position++ %></td>
                <td><%= reservation.getId() %></td>
                <td><%= reservation.getReservationDate() %></td>
                <td><%= reservation.getReservationTime() %></td>
                <td><%= reservation.getTableId() %></td>
                <td><%= reservation.getUserId() %></td>
                <td>
                    <div style="display: flex; gap: 0.5rem;">
                        <a href="${pageContext.request.contextPath}/admin/reservations/view?id=<%= reservation.getId() %>" class="action-btn edit-btn">View</a>

                        <form method="post" action="${pageContext.request.contextPath}/admin/reservations/queue/prioritize">
                            <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                            <button type="submit" class="action-btn edit-btn" style="background-color: #FFC107;">Prioritize</button>
                        </form>

                        <form method="post" action="${pageContext.request.contextPath}/admin/reservations/cancel">
                            <input type="hidden" name="reservationId" value="<%= reservation.getId() %>">
                            <button type="submit" class="action-btn delete-btn" onclick="return confirm('Are you sure you want to cancel this reservation?')">Cancel</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% } else { %>
    <div style="text-align: center; padding: 2rem;">
        <p>No pending reservations found</p>
    </div>
    <% } %>
</div>

<%@ include file="admin-footer.jsp" %>