<%@ include file="admin-header.jsp" %>

<h1 style="color: var(--gold); margin-bottom: 2rem;">User Management</h1>
<div class="card">
    <table class="data-table">
        <thead>
            <tr>
                <th>User ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Admin</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
            List<User> users = (List<User>) request.getAttribute("users");
            if (users != null && !users.isEmpty()) {
                for (User user : users) {
            %>
            <tr>
                <td><%= user.getId() %></td>
                <td><%= user.getUsername() %></td>
                <td><%= user.getEmail() %></td>
                <td>
                    <form id="adminForm_<%= user.getId() %>" method="post" action="${pageContext.request.contextPath}/admin/users/updateAdmin">
                        <input type="hidden" name="userId" value="<%= user.getId() %>">
                        <input type="checkbox" name="isAdmin" <%= user.isAdmin() ? "checked" : "" %>
                               onchange="document.getElementById('adminForm_<%= user.getId() %>').submit()">
                    </form>
                </td>
                <td>
                    <button class="action-btn edit-btn" onclick="location.href='${pageContext.request.contextPath}/admin/users/edit?id=<%= user.getId() %>'">Edit</button>
                </td>
            </tr>
            <%
                }
            } else {
            %>
            <tr>
                <td colspan="5" style="text-align: center;">No users found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<%@ include file="admin-footer.jsp" %>