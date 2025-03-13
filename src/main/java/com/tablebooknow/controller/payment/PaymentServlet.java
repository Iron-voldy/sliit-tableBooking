package com.tablebooknow.controller.payment;

import com.tablebooknow.dao.PaymentDAO;
import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.dao.UserDAO;
import com.tablebooknow.model.payment.Payment;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.model.user.User;
import com.tablebooknow.service.PaymentGateway;
import com.tablebooknow.util.ReservationQueue;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * Servlet for handling payment processing for table reservations
 */
@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {
    private PaymentDAO paymentDAO;
    private ReservationDAO reservationDAO;
    private UserDAO userDAO;
    private PaymentGateway paymentGateway;
    private ReservationQueue reservationQueue;

    @Override
    public void init() throws ServletException {
        System.out.println("Initializing PaymentServlet");
        paymentDAO = new PaymentDAO();
        reservationDAO = new ReservationDAO();
        userDAO = new UserDAO();
        paymentGateway = new PaymentGateway();
        reservationQueue = new ReservationQueue();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("GET request to payment: " + pathInfo);

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            // Default payment page
            response.sendRedirect(request.getContextPath() + "/payment.jsp");
            return;
        }

        switch (pathInfo) {
            case "/initiate":
                initiatePayment(request, response);
                break;
            case "/success":
                handlePaymentSuccess(request, response);
                break;
            case "/cancel":
                handlePaymentCancel(request, response);
                break;
            case "/notify":
                handlePaymentNotification(request, response);
                break;
            default:
                System.out.println("Unknown path: " + pathInfo);
                response.sendRedirect(request.getContextPath() + "/payment.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("POST request to payment: " + pathInfo);

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (pathInfo == null || pathInfo.equals("/")) {
            // Default path for processing payment form
            processPaymentForm(request, response);
            return;
        }

        switch (pathInfo) {
            case "/process":
                processPaymentForm(request, response);
                break;
            case "/notify":
                // PayHere will send POST notifications to this endpoint
                handlePaymentNotification(request, response);
                break;
            default:
                System.out.println("Unknown path: " + pathInfo);
                response.sendRedirect(request.getContextPath() + "/payment.jsp");
                break;
        }
    }

    /**
     * Process the submitted payment form and redirect to PayHere
     */
    private void processPaymentForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Processing payment form");

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");

        // Get reservation from session
        String reservationId = (String) session.getAttribute("reservationId");
        if (reservationId == null) {
            reservationId = request.getParameter("reservationId");
        }

        if (reservationId == null) {
            System.out.println("No reservation ID found, redirecting to date selection");
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        try {
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation == null) {
                request.setAttribute("errorMessage", "Reservation not found");
                request.getRequestDispatcher("/payment.jsp").forward(request, response);
                return;
            }

            User user = userDAO.findById(userId);
            if (user == null) {
                request.setAttribute("errorMessage", "User not found");
                request.getRequestDispatcher("/payment.jsp").forward(request, response);
                return;
            }

            // Extract table type from table ID
            String tableId = reservation.getTableId();
            String tableType = "regular"; // Default
            if (tableId != null && !tableId.isEmpty()) {
                char typeChar = tableId.charAt(0);
                if (typeChar == 'f') tableType = "family";
                else if (typeChar == 'l') tableType = "luxury";
                else if (typeChar == 'c') tableType = "couple";
                else if (typeChar == 'r') tableType = "regular";
            }

            // Calculate payment amount based on table type and duration
            int duration = reservation.getDuration();
            BigDecimal amount = paymentGateway.calculateAmount(tableType, duration);

            // Create payment record
            Payment payment = new Payment();
            payment.setUserId(userId);
            payment.setReservationId(reservationId);
            payment.setAmount(amount);
            payment.setCurrency("LKR"); // Sri Lankan Rupees
            payment.setStatus("PENDING");
            payment.setPaymentGateway("PayHere");

            // Save payment to get an ID
            paymentDAO.create(payment);

            // Store the payment ID in session for reference
            session.setAttribute("paymentId", payment.getId());

            // Generate URLs for PayHere
            String baseUrl = request.getRequestURL().toString();
            baseUrl = baseUrl.substring(0, baseUrl.lastIndexOf("/payment/"));

            String returnUrl = baseUrl + "/payment/success";
            String cancelUrl = baseUrl + "/payment/cancel";
            String notifyUrl = baseUrl + "/payment/notify";

            // Generate form parameters for PayHere
            Map<String, String> params = paymentGateway.generateFormParameters(
                    payment, reservation, user, returnUrl, cancelUrl, notifyUrl
            );

            // Store the parameters for the JSP to create the form
            request.setAttribute("paymentParams", params);
            request.setAttribute("checkoutUrl", paymentGateway.getCheckoutUrl());

            // Forward to payment processing JSP
            request.getRequestDispatcher("/paymentProcess.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error processing payment: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing payment: " + e.getMessage());
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
        }
    }

    /**
     * Initiate a payment for a reservation
     */
    private void initiatePayment(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Initiating payment");

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");

        String reservationId = request.getParameter("reservationId");
        if (reservationId == null) {
            reservationId = (String) session.getAttribute("reservationId");
        }

        if (reservationId == null) {
            System.out.println("No reservation ID found, redirecting to date selection");
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        // Store reservation ID in session
        session.setAttribute("reservationId", reservationId);

        // Include reservation details for the payment page
        try {
            Reservation reservation = reservationDAO.findById(reservationId);
            if (reservation != null) {
                request.setAttribute("reservation", reservation);

                // Extract table information for display
                if (reservation.getTableId() != null) {
                    String tableId = reservation.getTableId();
                    char typeChar = tableId.charAt(0);
                    String tableType = "Regular";
                    if (typeChar == 'f') tableType = "Family";
                    else if (typeChar == 'l') tableType = "Luxury";
                    else if (typeChar == 'c') tableType = "Couple";
                    request.setAttribute("tableType", tableType);
                }
            }
        } catch (Exception e) {
            System.err.println("Error loading reservation: " + e.getMessage());
            // Continue to payment page anyway
        }

        // Forward to payment page
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    /**
     * Handle successful payment callback from PayHere
     */
    private void handlePaymentSuccess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Payment success callback received");

        HttpSession session = request.getSession();
        String paymentId = (String) session.getAttribute("paymentId");
        String reservationId = (String) session.getAttribute("reservationId");

        String status = request.getParameter("status_code");
        String paymentGatewayId = request.getParameter("payment_id");
        String orderId = request.getParameter("order_id");

        System.out.println("Payment status: " + status);
        System.out.println("PayHere payment ID: " + paymentGatewayId);
        System.out.println("Order ID: " + orderId);

        // Validate payment
        boolean isValid = false;

        // If payment callback doesn't include payment ID, use the one from session
        if (orderId == null && paymentId != null) {
            orderId = paymentId;
        }

        try {
            if (orderId != null) {
                Payment payment = paymentDAO.findById(orderId);
                if (payment != null) {
                    // Update payment status
                    payment.setStatus("COMPLETED");
                    payment.setTransactionId(paymentGatewayId);
                    payment.setCompletedAt(LocalDateTime.now());

                    paymentDAO.update(payment);

                    // Find the reservation
                    Reservation reservation = reservationDAO.findById(payment.getReservationId());
                    if (reservation != null) {
                        // Update reservation status
                        reservation.setStatus("confirmed");
                        reservationDAO.update(reservation);

                        // Add to reservation queue
                        reservationQueue.enqueue(reservation);

                        isValid = true;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error processing payment success: " + e.getMessage());
            e.printStackTrace();
        }

        if (isValid) {
            session.setAttribute("confirmationMessage", "Payment successful! Your table reservation is now confirmed.");
            response.sendRedirect(request.getContextPath() + "/confirmation.jsp");
        } else {
            request.setAttribute("errorMessage", "We couldn't verify your payment. Please contact support.");
            request.getRequestDispatcher("/payment.jsp").forward(request, response);
        }
    }

    /**
     * Handle cancelled payment from PayHere
     */
    private void handlePaymentCancel(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Payment cancel callback received");

        HttpSession session = request.getSession();
        String paymentId = (String) session.getAttribute("paymentId");

        try {
            if (paymentId != null) {
                Payment payment = paymentDAO.findById(paymentId);
                if (payment != null) {
                    // Update payment status
                    payment.setStatus("CANCELLED");
                    paymentDAO.update(payment);
                }
            }
        } catch (Exception e) {
            System.err.println("Error processing payment cancellation: " + e.getMessage());
        }

        request.setAttribute("errorMessage", "Payment was cancelled. Please try again.");
        request.getRequestDispatcher("/payment.jsp").forward(request, response);
    }

    /**
     * Handle payment notification from PayHere (server to server)
     */
    private void handlePaymentNotification(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("Payment notification received");

        String merchantId = request.getParameter("merchant_id");
        String orderId = request.getParameter("order_id");
        String paymentId = request.getParameter("payment_id");
        String payhere_amount = request.getParameter("payhere_amount");
        String payhere_currency = request.getParameter("payhere_currency");
        String status_code = request.getParameter("status_code");

        System.out.println("Notification details - Order: " + orderId + ", Status: " + status_code);

        // Log all parameters for debugging
        System.out.println("All notification parameters:");
        request.getParameterMap().forEach((key, values) -> {
            for (String value : values) {
                System.out.println("  " + key + ": " + value);
            }
        });

        // Validate notification
        boolean isValid = paymentGateway.validateNotification(
                merchantId, orderId, paymentId, payhere_amount, payhere_currency, status_code
        );

        if (isValid && "2".equals(status_code)) { // 2 is success status in PayHere
            try {
                Payment payment = paymentDAO.findById(orderId);
                if (payment != null) {
                    // Update payment status
                    payment.setStatus("COMPLETED");
                    payment.setTransactionId(paymentId);
                    payment.setCompletedAt(LocalDateTime.now());

                    paymentDAO.update(payment);

                    // Find and update the reservation
                    Reservation reservation = reservationDAO.findById(payment.getReservationId());
                    if (reservation != null) {
                        reservation.setStatus("confirmed");
                        reservationDAO.update(reservation);

                        // Add to reservation queue
                        reservationQueue.enqueue(reservation);
                    }

                    // Send success response
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Payment processed successfully");
                    return;
                }
            } catch (Exception e) {
                System.err.println("Error processing payment notification: " + e.getMessage());
                e.printStackTrace();
            }
        }

        // Send error response
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write("Invalid payment notification");
    }
}