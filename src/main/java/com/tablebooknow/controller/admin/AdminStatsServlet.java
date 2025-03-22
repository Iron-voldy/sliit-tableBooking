package com.tablebooknow.controller.admin;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.dao.PaymentDAO;
import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Servlet for providing admin dashboard statistics
 */
@WebServlet("/admin/stats/*")
public class AdminStatsServlet extends HttpServlet {
    private UserDAO userDAO;
    private ReservationDAO reservationDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        reservationDAO = new ReservationDAO();
        paymentDAO = new PaymentDAO();
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
            case "/dashboard":
                // Get dashboard statistics
                getDashboardStats(request, response);
                break;
            case "/reservations":
                // Get reservation statistics
                getReservationStats(request, response);
                break;
            case "/revenue":
                // Get revenue statistics
                getRevenueStats(request, response);
                break;
            case "/json":
                // Return stats as JSON (for AJAX requests)
                getStatsAsJson(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                break;
        }
    }

    /**
     * Get overall dashboard statistics
     */
    private void getDashboardStats(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Get user count
            int userCount = userDAO.findAll().size();

            // Get reservation counts
            List<Reservation> allReservations = reservationDAO.findAll();
            int totalReservations = allReservations.size();

            // Count by status
            int pendingReservations = 0;
            int confirmedReservations = 0;
            int cancelledReservations = 0;

            for (Reservation reservation : allReservations) {
                String status = reservation.getStatus();
                if ("pending".equals(status)) {
                    pendingReservations++;
                } else if ("confirmed".equals(status)) {
                    confirmedReservations++;
                } else if ("cancelled".equals(status)) {
                    cancelledReservations++;
                }
            }

            // Get today's reservations
            String today = LocalDate.now().toString();
            List<Reservation> todayReservations = reservationDAO.findByDate(today);

            // Get total revenue
            BigDecimal totalRevenue = BigDecimal.ZERO;
            List<Payment> payments = paymentDAO.findAll();
            for (Payment payment : payments) {
                if ("COMPLETED".equals(payment.getStatus()) && payment.getAmount() != null) {
                    totalRevenue = totalRevenue.add(payment.getAmount());
                }
            }

            // Build JSON
            json.append("\"userCount\":").append(userCount).append(",");
            json.append("\"totalReservations\":").append(totalReservations).append(",");
            json.append("\"pendingReservations\":").append(pendingReservations).append(",");
            json.append("\"confirmedReservations\":").append(confirmedReservations).append(",");
            json.append("\"cancelledReservations\":").append(cancelledReservations).append(",");
            json.append("\"totalRevenue\":").append(totalRevenue);

        } catch (Exception e) {
            json.append("\"error\":\"").append(e.getMessage()).append("\"");
        }

        json.append("}");
        return json.toString();
    }

    /**
     * Reservation statistics as JSON
     */
    private String getReservationStatsJson() throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{");

        try {
            List<Reservation> allReservations = reservationDAO.findAll();

            // Count by status
            int pendingReservations = 0;
            int confirmedReservations = 0;
            int cancelledReservations = 0;

            for (Reservation reservation : allReservations) {
                String status = reservation.getStatus();
                if ("pending".equals(status)) {
                    pendingReservations++;
                } else if ("confirmed".equals(status)) {
                    confirmedReservations++;
                } else if ("cancelled".equals(status)) {
                    cancelledReservations++;
                }
            }

            // Build JSON
            json.append("\"totalReservations\":").append(allReservations.size()).append(",");
            json.append("\"pendingReservations\":").append(pendingReservations).append(",");
            json.append("\"confirmedReservations\":").append(confirmedReservations).append(",");
            json.append("\"cancelledReservations\":").append(cancelledReservations).append(",");

            // Add reservations by date
            json.append("\"byDate\":{");

            // Get dates for the next 7 days
            LocalDate today = LocalDate.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            for (int i = 0; i < 7; i++) {
                if (i > 0) {
                    json.append(",");
                }

                LocalDate date = today.plusDays(i);
                String dateStr = date.format(formatter);
                List<Reservation> dailyReservations = reservationDAO.findByDate(dateStr);

                json.append("\"").append(dateStr).append("\":").append(dailyReservations.size());
            }

            json.append("}");

        } catch (Exception e) {
            json.append("\"error\":\"").append(e.getMessage()).append("\"");
        }

        json.append("}");
        return json.toString();
    }

    /**
     * Revenue statistics as JSON
     */
    private String getRevenueStatsJson() throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{");

        try {
            List<Payment> payments = paymentDAO.findAll();

            // Filter completed payments
            List<Payment> completedPayments = payments.stream()
                    .filter(p -> "COMPLETED".equals(p.getStatus()))
                    .collect(Collectors.toList());

            // Calculate total revenue
            BigDecimal totalRevenue = BigDecimal.ZERO;
            for (Payment payment : completedPayments) {
                if (payment.getAmount() != null) {
                    totalRevenue = totalRevenue.add(payment.getAmount());
                }
            }

            // Build JSON
            json.append("\"totalRevenue\":").append(totalRevenue).append(",");
            json.append("\"completedPayments\":").append(completedPayments.size()).append(",");
            json.append("\"pendingPayments\":").append(payments.size() - completedPayments.size()).append(",");

            // Add monthly revenue
            json.append("\"monthlyRevenue\":{");

            Map<String, BigDecimal> monthlyRevenue = calculateMonthlyRevenue(payments);
            boolean first = true;

            for (Map.Entry<String, BigDecimal> entry : monthlyRevenue.entrySet()) {
                if (!first) {
                    json.append(",");
                }
                first = false;

                json.append("\"").append(entry.getKey()).append("\":").append(entry.getValue());
            }

            json.append("}");

        } catch (Exception e) {
            json.append("\"error\":\"").append(e.getMessage()).append("\"");
        }

        json.append("}");
        return json.toString();
    }

    /**
     * Calculate monthly revenue
     */
    private Map<String, BigDecimal> calculateMonthlyRevenue(List<Payment> payments) {
        Map<String, BigDecimal> monthlyRevenue = new HashMap<>();

        // Initialize with the last 6 months
        LocalDate now = LocalDate.now();
        DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("yyyy-MM");

        for (int i = 5; i >= 0; i--) {
            YearMonth yearMonth = YearMonth.from(now.minusMonths(i));
            String monthKey = yearMonth.format(monthFormatter);
            monthlyRevenue.put(monthKey, BigDecimal.ZERO);
        }

        // Calculate revenue for each month
        for (Payment payment : payments) {
            if ("COMPLETED".equals(payment.getStatus()) && payment.getAmount() != null && payment.getCompletedAt() != null) {
                String monthKey = payment.getCompletedAt().format(monthFormatter);

                // Only count months we're tracking
                if (monthlyRevenue.containsKey(monthKey)) {
                    BigDecimal currentAmount = monthlyRevenue.get(monthKey);
                    monthlyRevenue.put(monthKey, currentAmount.add(payment.getAmount()));
                }
            }
        }

        return monthlyRevenue;
    }

    /**
     * Calculate revenue by table type
     */
    private Map<String, BigDecimal> calculateRevenueByTableType(List<Payment> completedPayments) throws IOException {
        Map<String, BigDecimal> revenueByTableType = new HashMap<>();
        revenueByTableType.put("family", BigDecimal.ZERO);
        revenueByTableType.put("regular", BigDecimal.ZERO);
        revenueByTableType.put("luxury", BigDecimal.ZERO);
        revenueByTableType.put("couple", BigDecimal.ZERO);

        for (Payment payment : completedPayments) {
            if (payment.getAmount() != null && payment.getReservationId() != null) {
                Reservation reservation = reservationDAO.findById(payment.getReservationId());

                if (reservation != null && reservation.getTableId() != null) {
                    String tableId = reservation.getTableId();
                    char typeChar = tableId.charAt(0);

                    if (typeChar == 'f') {
                        BigDecimal current = revenueByTableType.get("family");
                        revenueByTableType.put("family", current.add(payment.getAmount()));
                    } else if (typeChar == 'r') {
                        BigDecimal current = revenueByTableType.get("regular");
                        revenueByTableType.put("regular", current.add(payment.getAmount()));
                    } else if (typeChar == 'l') {
                        BigDecimal current = revenueByTableType.get("luxury");
                        revenueByTableType.put("luxury", current.add(payment.getAmount()));
                    } else if (typeChar == 'c') {
                        BigDecimal current = revenueByTableType.get("couple");
                        revenueByTableType.put("couple", current.add(payment.getAmount()));
                    }
                }
            }
        }

        return revenueByTableType;
    }
}
// Get monthly revenue for chart
Map<String, BigDecimal> monthlyRevenue = calculateMonthlyRevenue(payments);

// Put all stats in the request
            request.setAttribute("userCount", userCount);
            request.setAttribute("totalReservations", totalReservations);
            request.setAttribute("pendingReservations", pendingReservations);
            request.setAttribute("confirmedReservations", confirmedReservations);
            request.setAttribute("cancelledReservations", cancelledReservations);
            request.setAttribute("todayReservations", todayReservations);
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("monthlyRevenue", monthlyRevenue);

// Forward to dashboard
            request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
        } catch (Exception e) {
        request.setAttribute("errorMessage", "Error loading dashboard statistics: " + e.getMessage());
        request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
        }
                }

/**
 * Get statistics for reservations only
 */
private void getReservationStats(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    try {
        List<Reservation> allReservations = reservationDAO.findAll();

        // Count by status
        int pendingReservations = 0;
        int confirmedReservations = 0;
        int cancelledReservations = 0;

        for (Reservation reservation : allReservations) {
            String status = reservation.getStatus();
            if ("pending".equals(status)) {
                pendingReservations++;
            } else if ("confirmed".equals(status)) {
                confirmedReservations++;
            } else if ("cancelled".equals(status)) {
                cancelledReservations++;
            }
        }

        // Get reservations by date
        Map<String, Integer> reservationsByDate = new HashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // Get dates for the next 7 days
        LocalDate today = LocalDate.now();
        for (int i = 0; i < 7; i++) {
            LocalDate date = today.plusDays(i);
            String dateStr = date.format(formatter);
            List<Reservation> dailyReservations = reservationDAO.findByDate(dateStr);
            reservationsByDate.put(dateStr, dailyReservations.size());
        }

        // Get reservations by table type
        Map<String, Integer> reservationsByTableType = new HashMap<>();
        reservationsByTableType.put("family", 0);
        reservationsByTableType.put("regular", 0);
        reservationsByTableType.put("luxury", 0);
        reservationsByTableType.put("couple", 0);

        for (Reservation reservation : allReservations) {
            String tableId = reservation.getTableId();
            if (tableId != null && !tableId.isEmpty()) {
                char typeChar = tableId.charAt(0);
                if (typeChar == 'f') {
                    reservationsByTableType.put("family", reservationsByTableType.get("family") + 1);
                } else if (typeChar == 'r') {
                    reservationsByTableType.put("regular", reservationsByTableType.get("regular") + 1);
                } else if (typeChar == 'l') {
                    reservationsByTableType.put("luxury", reservationsByTableType.get("luxury") + 1);
                } else if (typeChar == 'c') {
                    reservationsByTableType.put("couple", reservationsByTableType.get("couple") + 1);
                }
            }
        }

        request.setAttribute("totalReservations", allReservations.size());
        request.setAttribute("pendingReservations", pendingReservations);
        request.setAttribute("confirmedReservations", confirmedReservations);
        request.setAttribute("cancelledReservations", cancelledReservations);
        request.setAttribute("reservationsByDate", reservationsByDate);
        request.setAttribute("reservationsByTableType", reservationsByTableType);

        request.getRequestDispatcher("/WEB-INF/admin/reservation-stats.jsp").forward(request, response);
    } catch (Exception e) {
        request.setAttribute("errorMessage", "Error loading reservation statistics: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }
}

/**
 * Get statistics for revenue
 */
private void getRevenueStats(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    try {
        List<Payment> payments = paymentDAO.findAll();

        // Filter completed payments
        List<Payment> completedPayments = payments.stream()
                .filter(p -> "COMPLETED".equals(p.getStatus()))
                .collect(Collectors.toList());

        // Calculate total revenue
        BigDecimal totalRevenue = BigDecimal.ZERO;
        for (Payment payment : completedPayments) {
            if (payment.getAmount() != null) {
                totalRevenue = totalRevenue.add(payment.getAmount());
            }
        }

        // Calculate monthly revenue
        Map<String, BigDecimal> monthlyRevenue = calculateMonthlyRevenue(payments);

        // Calculate revenue by table type
        Map<String, BigDecimal> revenueByTableType = calculateRevenueByTableType(completedPayments);

        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("completedPayments", completedPayments.size());
        request.setAttribute("pendingPayments", payments.size() - completedPayments.size());
        request.setAttribute("monthlyRevenue", monthlyRevenue);
        request.setAttribute("revenueByTableType", revenueByTableType);

        request.getRequestDispatcher("/WEB-INF/admin/revenue-stats.jsp").forward(request, response);
    } catch (Exception e) {
        request.setAttribute("errorMessage", "Error loading revenue statistics: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }
}

/**
 * Return statistics as JSON for AJAX requests
 */
private void getStatsAsJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String statsType = request.getParameter("type");
    if (statsType == null) {
        statsType = "dashboard";
    }

    PrintWriter out = response.getWriter();

    try {
        switch (statsType) {
            case "dashboard":
                out.print(getDashboardStatsJson());
                break;
            case "reservations":
                out.print(getReservationStatsJson());
                break;
            case "revenue":
                out.print(getRevenueStatsJson());
                break;
            default:
                out.print("{\"error\": \"Unknown stats type\"}");
                break;
        }
    } catch (Exception e) {
        out.print("{\"error\": \"" + e.getMessage() + "\"}");
    }
}

/**
 * Dashboard statistics as JSON
 */
private String getDashboardStatsJson() throws IOException {
    StringBuilder json = new StringBuilder();
    json.append("{");

    try {
        // Get user count
        int userCount = userDAO.findAll().size();

        // Get reservation counts
        List<Reservation> allReservations = reservationDAO.findAll();
        int totalReservations = allReservations.size();

        // Count by status
        int pendingReservations = 0;
        int confirmedReservations = 0;
        int cancelledReservations = 0;

        for (Reservation reservation : allReservations) {
            String status = reservation.getStatus();
            if ("pending".equals(status)) {
                pendingReservations++;
            } else if ("confirmed".equals(status)) {
                confirmedReservations++;
            } else if ("cancelled".equals(status)) {
                cancelledReservations++;
            }
        }

        // Get total revenue
        BigDecimal totalRevenue = BigDecimal.ZERO;
        List<Payment> payments = paymentDAO.findAll();
        for (Payment payment : payments) {
            if ("COMPLETED".equals(payment.getStatus()) && payment.getAmount() != null) {
                totalRevenue = totalRevenue.add(payment.getAmount());
            }
        }