package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.model.reservation.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet for handling admin table management functions
 */
@WebServlet("/admin/tables/*")
public class TableManagerServlet extends HttpServlet {
    private ReservationDAO reservationDAO;

    @Override
    public void init() throws ServletException {
        reservationDAO = new ReservationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if admin is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/";
        }

        switch (pathInfo) {
            case "/":
                // View table status
                viewTables(request, response);
                break;
            case "/status":
                // View status of a specific table
                viewTableStatus(request, response);
                break;
            case "/filter":
                // Filter table status by date
                filterTablesByDate(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/tables/");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if admin is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/";
        }

        // We don't have any POST operations for tables yet, but could add in the future
        response.sendRedirect(request.getContextPath() + "/admin/tables/");
    }

    /**
     * View all tables and their statuses
     */
    private void viewTables(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get date parameter or use today's date
            String date = request.getParameter("date");
            if (date == null || date.trim().isEmpty()) {
                date = LocalDate.now().toString();
            }

            // Get reserved tables for the date
            List<String> reservedTables = reservationDAO.getReservedTables(date, null, 0);

            // Create table configuration data
            Map<String, Map<String, Object>> tableTypes = createTableConfiguration();

            request.setAttribute("reservedTables", reservedTables);
            request.setAttribute("tableTypes", tableTypes);
            request.setAttribute("selectedDate", date);

            // Format date for display
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate selectedDate = LocalDate.parse(date, formatter);
            request.setAttribute("formattedDate", selectedDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));

            request.getRequestDispatcher("/WEB-INF/admin/tables.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading tables: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/admin/tables.jsp").forward(request, response);
        }
    }

    /**
     * View status of a specific table
     */
    private void viewTableStatus(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tableId = request.getParameter("id");
        String date = request.getParameter("date");

        if (tableId == null || tableId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/tables/");
            return;
        }

        if (date == null || date.trim().isEmpty()) {
            date = LocalDate.now().toString();
        }

        try {
            // Get reservations for this table on the specified date
            List<Reservation> tableReservations = reservationDAO.findByTableAndDate(tableId, date);

            // Sort by time
            tableReservations.sort((r1, r2) -> r1.getReservationTime().compareTo(r2.getReservationTime()));

            // Get table configuration
            Map<String, Object> tableConfig = getTableConfig(tableId);

            request.setAttribute("tableId", tableId);
            request.setAttribute("tableReservations", tableReservations);
            request.setAttribute("selectedDate", date);
            request.setAttribute("tableConfig", tableConfig);

            // Format date for display
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate selectedDate = LocalDate.parse(date, formatter);
            request.setAttribute("formattedDate", selectedDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));

            request.getRequestDispatcher("/WEB-INF/admin/table-status.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading table status: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/tables/");
        }
    }

    /**
     * Filter table status by date
     */
    private void filterTablesByDate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String date = request.getParameter("date");

        if (date == null || date.trim().isEmpty()) {
            date = LocalDate.now().toString();
        }

        try {
            // Get reserved tables for the date
            List<String> reservedTables = reservationDAO.getReservedTables(date, null, 0);

            // Create table configuration data
            Map<String, Map<String, Object>> tableTypes = createTableConfiguration();

            request.setAttribute("reservedTables", reservedTables);
            request.setAttribute("tableTypes", tableTypes);
            request.setAttribute("selectedDate", date);

            // Format date for display
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate selectedDate = LocalDate.parse(date, formatter);
            request.setAttribute("formattedDate", selectedDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));

            request.getRequestDispatcher("/WEB-INF/admin/tables.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error filtering tables: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/tables/");
        }
    }

    /**
     * Create table configuration data
     */
    private Map<String, Map<String, Object>> createTableConfiguration() {
        Map<String, Map<String, Object>> tables = new HashMap<>();

        // Floor 1 tables
        addTableType(tables, "f1", "Family", 4, 6);
        addTableType(tables, "r1", "Regular", 10, 4);
        addTableType(tables, "c1", "Couple", 4, 2);

        // Floor 2 tables
        addTableType(tables, "f2", "Family", 6, 6);
        addTableType(tables, "l2", "Luxury", 4, 10);
        addTableType(tables, "c2", "Couple", 6, 2);

        return tables;
    }

    /**
     * Add a table type to the configuration
     */
    private void addTableType(Map<String, Map<String, Object>> tables, String code, String name, int count, int capacity) {
        Map<String, Object> config = new HashMap<>();
        config.put("name", name);
        config.put("count", count);
        config.put("capacity", capacity);
        config.put("floor", code.charAt(1));
        tables.put(code, config);
    }

    /**
     * Get configuration for a specific table
     */
    private Map<String, Object> getTableConfig(String tableId) {
        Map<String, Object> config = new HashMap<>();

        if (tableId == null || tableId.length() < 3) {
            return config;
        }

        // Extract table type code (e.g., "f1" from "f1-3")
        String typeCode = tableId.substring(0, 2);
        int tableNumber = Integer.parseInt(tableId.substring(3));

        String typeName;
        int capacity;

        char typeChar = typeCode.charAt(0);
        char floorChar = typeCode.charAt(1);
        int floor = Character.getNumericValue(floorChar);

        switch (typeChar) {
            case 'f':
                typeName = "Family";
                capacity = 6;
                break;
            case 'r':
                typeName = "Regular";
                capacity = 4;
                break;
            case 'l':
                typeName = "Luxury";
                capacity = 10;
                break;
            case 'c':
                typeName = "Couple";
                capacity = 2;
                break;
            default:
                typeName = "Unknown";
                capacity = 0;
                break;
        }

        config.put("id", tableId);
        config.put("typeCode", typeCode);
        config.put("typeName", typeName);
        config.put("capacity", capacity);
        config.put("floor", floor);
        config.put("number", tableNumber);

        return config;
    }
}