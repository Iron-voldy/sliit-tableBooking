package com.tablebooknow.controller.payment;

import com.tablebooknow.dao.PaymentCardDAO;
import com.tablebooknow.model.payment.PaymentCard;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for handling payment card operations
 */
@WebServlet("/paymentcard/*")
public class PaymentCardServlet extends HttpServlet {
    private PaymentCardDAO paymentCardDAO;

    @Override
    public void init() throws ServletException {
        System.out.println("Initializing PaymentCardServlet");
        paymentCardDAO = new PaymentCardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("GET request to paymentcard: " + pathInfo);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        if (pathInfo == null || pathInfo.equals("/")) {
            // Default action - Get all cards
            try {
                List<PaymentCard> cards = paymentCardDAO.findByUserId(userId);
                request.setAttribute("paymentCards", cards);
                request.getRequestDispatcher("/paymentDashboard.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error retrieving payment cards: " + e.getMessage());
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error retrieving payment cards: " + e.getMessage());
                request.getRequestDispatcher("/paymentDashboard.jsp").forward(request, response);
            }
            return;
        }

        if (pathInfo.equals("/dashboard")) {
            // Fetch reservation ID and user cards
            String reservationId = request.getParameter("reservationId");
            if (reservationId != null) {
                session.setAttribute("reservationId", reservationId);
            } else {
                reservationId = (String) session.getAttribute("reservationId");
            }

            if (reservationId == null) {
                response.sendRedirect(request.getContextPath() + "/reservation/dateSelection");
                return;
            }

            try {
                List<PaymentCard> cards = paymentCardDAO.findByUserId(userId);
                request.setAttribute("paymentCards", cards);
                request.getRequestDispatcher("/paymentDashboard.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Error retrieving payment cards for dashboard: " + e.getMessage());
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error retrieving payment cards: " + e.getMessage());
                request.getRequestDispatcher("/paymentDashboard.jsp").forward(request, response);
            }
            return;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("POST request to paymentcard: " + pathInfo);

        // Debug all parameters
        System.out.println("All parameters received:");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println(key + ": " + String.join(", ", values));
        });

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        // DIRECT HANDLING FOR SPECIFIC PATHS
        if (pathInfo != null) {
            if (pathInfo.equals("/delete")) {
                System.out.println("Processing delete request with cardId: " + request.getParameter("cardId"));
                deleteCard(request, response, userId);
                return;
            } else if (pathInfo.equals("/setdefault")) {
                System.out.println("Processing set default request with cardId: " + request.getParameter("cardId"));
                setDefaultCard(request, response, userId);
                return;
            } else if (pathInfo.equals("/process")) {
                System.out.println("Processing payment request");
                processPaymentWithCard(request, response, userId);
                return;
            } else if (pathInfo.equals("/update")) {
                System.out.println("Processing update request");
                updateCard(request, response, userId);
                return;
            }
        }

        // Default - Add a new card or use action parameter
        String action = request.getParameter("action");
        if (action != null) {
            if ("update".equals(action)) {
                updateCard(request, response, userId);
                return;
            } else if ("delete".equals(action)) {
                deleteCard(request, response, userId);
                return;
            } else if ("setdefault".equals(action)) {
                setDefaultCard(request, response, userId);
                return;
            }
        }

        // Default action if no specific path or action matched
        addNewCard(request, response, userId);
    }

    private void addNewCard(HttpServletRequest request, HttpServletResponse response, String userId) throws ServletException, IOException {
        try {
            // Get form data
            String cardholderName = request.getParameter("cardholderName");
            String cardNumber = request.getParameter("cardNumber").replace(" ", ""); // Remove spaces
            String expiryDate = request.getParameter("expiryDate");
            String cvv = request.getParameter("cvv");
            String cardType = request.getParameter("cardType");
            boolean makeDefault = "true".equals(request.getParameter("makeDefault"));

            // Basic validation
            if (cardholderName == null || cardNumber == null || expiryDate == null || cvv == null || cardType == null ||
                    cardholderName.isEmpty() || cardNumber.isEmpty() || expiryDate.isEmpty() || cvv.isEmpty() || cardType.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("All fields are required");
                return;
            }

            // Create a new PaymentCard object
            PaymentCard card = new PaymentCard();
            card.setUserId(userId);
            card.setCardholderName(cardholderName);
            card.setCardNumber(cardNumber);
            card.setExpiryDate(expiryDate);
            card.setCvv(cvv);
            card.setCardType(cardType);

            // Check if it should be default
            if (makeDefault) {
                // Set all other cards to non-default first
                List<PaymentCard> existingCards = paymentCardDAO.findByUserId(userId);
                for (PaymentCard existingCard : existingCards) {
                    if (existingCard.isDefaultCard()) {
                        existingCard.setDefaultCard(false);
                        paymentCardDAO.update(existingCard);
                    }
                }
                card.setDefaultCard(true);
            } else {
                // If no other cards, make this default anyway
                if (paymentCardDAO.findByUserId(userId).isEmpty()) {
                    card.setDefaultCard(true);
                } else {
                    card.setDefaultCard(false);
                }
            }

            // Save the card
            paymentCardDAO.create(card);

            // Return success response
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Card added successfully");

        } catch (Exception e) {
            System.err.println("Error adding payment card: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error adding payment card: " + e.getMessage());
        }
    }

    private void updateCard(HttpServletRequest request, HttpServletResponse response, String userId) throws ServletException, IOException {
        try {
            // Get form data
            String cardId = request.getParameter("cardId");
            String cardholderName = request.getParameter("cardholderName");
            String expiryDate = request.getParameter("expiryDate");
            String cvv = request.getParameter("cvv");
            String cardType = request.getParameter("cardType");
            String cardNumber = request.getParameter("cardNumber");
            boolean makeDefault = "true".equals(request.getParameter("makeDefault"));

            System.out.println("Updating card ID: " + cardId);
            System.out.println("Make default: " + makeDefault);

            // Find the card
            PaymentCard card = paymentCardDAO.findById(cardId);

            // Verify the card belongs to the user
            if (card == null || !card.getUserId().equals(userId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card not found or access denied");
                return;
            }

            // Update card details
            if (cardholderName != null && !cardholderName.isEmpty()) {
                card.setCardholderName(cardholderName);
            }

            if (expiryDate != null && !expiryDate.isEmpty()) {
                card.setExpiryDate(expiryDate);
            }

            if (cvv != null && !cvv.isEmpty()) {
                card.setCvv(cvv);
            }

            if (cardType != null && !cardType.isEmpty()) {
                card.setCardType(cardType);
            }

            // Update card number if provided
            if (cardNumber != null && !cardNumber.isEmpty()) {
                card.setCardNumber(cardNumber.replace(" ", ""));
            }

            // Handle default card status
            if (makeDefault && !card.isDefaultCard()) {
                // Set all other cards to non-default first
                List<PaymentCard> existingCards = paymentCardDAO.findByUserId(userId);
                for (PaymentCard existingCard : existingCards) {
                    if (existingCard.isDefaultCard() && !existingCard.getId().equals(card.getId())) {
                        existingCard.setDefaultCard(false);
                        paymentCardDAO.update(existingCard);
                    }
                }
                card.setDefaultCard(true);
            }

            // Save changes
            paymentCardDAO.update(card);

            // Return success response
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Card updated successfully");

        } catch (Exception e) {
            System.err.println("Error updating payment card: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error updating payment card: " + e.getMessage());
        }
    }

    private void deleteCard(HttpServletRequest request, HttpServletResponse response, String userId) throws ServletException, IOException {
        try {
            // Get card ID
            String cardId = request.getParameter("cardId");
            System.out.println("Processing delete for card ID: " + cardId);

            if (cardId == null || cardId.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card ID is required");
                return;
            }

            // Find the card
            PaymentCard card = paymentCardDAO.findById(cardId);
            System.out.println("Found card: " + (card != null ? card.getId() : "null"));

            // Verify the card belongs to the user
            if (card == null || !card.getUserId().equals(userId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card not found or access denied");
                return;
            }

            // Check if this is the default card
            boolean wasDefault = card.isDefaultCard();
            System.out.println("Was default card: " + wasDefault);

            // Delete the card
            boolean deleted = paymentCardDAO.delete(cardId);
            System.out.println("Card deleted: " + deleted);

            if (!deleted) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to delete card");
                return;
            }

            // If we deleted the default card, make another card default
            if (wasDefault) {
                List<PaymentCard> remainingCards = paymentCardDAO.findByUserId(userId);
                if (!remainingCards.isEmpty()) {
                    PaymentCard newDefault = remainingCards.get(0);
                    newDefault.setDefaultCard(true);
                    paymentCardDAO.update(newDefault);
                    System.out.println("Set new default card: " + newDefault.getId());
                }
            }

            // Return success response
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Card deleted successfully");

        } catch (Exception e) {
            System.err.println("Error deleting payment card: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error deleting payment card: " + e.getMessage());
        }
    }

    private void setDefaultCard(HttpServletRequest request, HttpServletResponse response, String userId) throws ServletException, IOException {
        try {
            // Get card ID
            String cardId = request.getParameter("cardId");
            System.out.println("Setting default card: " + cardId);

            if (cardId == null || cardId.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card ID is required");
                return;
            }

            // Find the card
            PaymentCard card = paymentCardDAO.findById(cardId);

            // Verify the card belongs to the user
            if (card == null || !card.getUserId().equals(userId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card not found or access denied");
                return;
            }

            // Set all cards to non-default first
            List<PaymentCard> existingCards = paymentCardDAO.findByUserId(userId);
            for (PaymentCard existingCard : existingCards) {
                if (existingCard.isDefaultCard()) {
                    existingCard.setDefaultCard(false);
                    paymentCardDAO.update(existingCard);
                }
            }

            // Set the selected card as default
            card.setDefaultCard(true);
            paymentCardDAO.update(card);

            // Return success response
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Default payment method updated");

        } catch (Exception e) {
            System.err.println("Error setting default payment card: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error setting default payment card: " + e.getMessage());
        }
    }

    private void processPaymentWithCard(HttpServletRequest request, HttpServletResponse response, String userId) throws ServletException, IOException {
        try {
            // Get card ID and reservation ID
            String cardId = request.getParameter("cardId");
            String reservationId = request.getParameter("reservationId");

            if (reservationId == null) {
                reservationId = (String) request.getSession().getAttribute("reservationId");
            }

            if (reservationId == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Reservation ID is missing");
                return;
            }

            // Find the card
            PaymentCard card = null;
            if (cardId != null && !cardId.isEmpty()) {
                card = paymentCardDAO.findById(cardId);

                // Verify the card belongs to the user
                if (card == null || !card.getUserId().equals(userId)) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("Invalid payment method");
                    return;
                }
            } else {
                // If no card ID specified, try to use the default card
                List<PaymentCard> cards = paymentCardDAO.findByUserId(userId);
                for (PaymentCard c : cards) {
                    if (c.isDefaultCard()) {
                        card = c;
                        break;
                    }
                }

                if (card == null && !cards.isEmpty()) {
                    card = cards.get(0); // Use first card if no default
                }

                if (card == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("No payment method selected or available");
                    return;
                }
            }

            // Store the card ID in session for the payment process
            request.getSession().setAttribute("paymentCardId", card.getId());

            // Also store card info for payment process (masked for security)
            request.getSession().setAttribute("cardholderName", card.getCardholderName());
            request.getSession().setAttribute("cardType", card.getCardType());
            request.getSession().setAttribute("cardLast4", card.getCardNumber().substring(card.getCardNumber().length() - 4));

            // Redirect to the payment processing servlet
            response.sendRedirect(request.getContextPath() + "/payment/process");

        } catch (Exception e) {
            System.err.println("Error processing payment with card: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error processing payment: " + e.getMessage());
        }
    }
}