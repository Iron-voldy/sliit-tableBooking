<%@ include file="admin-header.jsp" %>

<h1 style="color: var(--gold); margin-bottom: 2rem;">Table Management</h1>
<div class="table-grid">
    <!-- Family Tables -->
    <% for (int i = 1; i <= 4; i++) { %>
        <div class="table-card status-available">
            <h3>Family Table <%= i %></h3>
            <p>6 Seats</p>
            <p>ID: f1-<%= i %></p>
            <p>Status: Available</p>
            <button class="action-btn edit-btn" style="margin-top: 1rem;" onclick="location.href='${pageContext.request.contextPath}/admin/tables/status?id=f1-<%= i %>'">Check Status</button>
        </div>
    <% } %>

    <!-- Regular Tables -->
    <% for (int i = 1; i <= 6; i++) { %>
        <div class="table-card status-available">
            <h3>Regular Table <%= i %></h3>
            <p>4 Seats</p>
            <p>ID: r1-<%= i %></p>
            <p>Status: Available</p>
            <button class="action-btn edit-btn" style="margin-top: 1rem;" onclick="location.href='${pageContext.request.contextPath}/admin/tables/status?id=r1-<%= i %>'">Check Status</button>
        </div>
    <% } %>
</div>

<%@ include file="admin-footer.jsp" %>