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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            System.out.println("User not logged in, redirecting to login page");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        if (pathInfo == null || pathInfo.equals("/")) {
            // Default - Add a new card
            addNewCard(request, response, userId);
            return;
        }

        if (pathInfo.equals("/update")) {
            updateCard(request, response, userId);
            return;
        }

        if (pathInfo.equals("/delete")) {
            deleteCard(request, response, userId);
            return;
        }

        if (pathInfo.equals("/setdefault")) {
            setDefaultCard(request, response, userId);
            return;
        }

        if (pathInfo.equals("/process")) {
            processPaymentWithCard(request, response, userId);
            return;
        }

        // Unknown path - redirect to dashboard
        response.sendRedirect(request.getContextPath() + "/paymentcard/dashboard");
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
                request.setAttribute("errorMessage", "All fields are required");
                request.getRequestDispatcher("/paymentDashboard.jsp").forward(request, response);
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
            boolean makeDefault = "true".equals(request.getParameter("makeDefault"));

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

            // Find the card
            PaymentCard card = paymentCardDAO.findById(cardId);

            // Verify the card belongs to the user
            if (card == null || !card.getUserId().equals(userId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Card not found or access denied");
                return;
            }

            // Check if this is the default card
            boolean wasDefault = card.isDefaultCard();

            // Delete the card
            paymentCardDAO.delete(cardId);

            // If we deleted the default card, make another card default
            if (wasDefault) {
                List<PaymentCard> remainingCards = paymentCardDAO.findByUserId(userId);
                if (!remainingCards.isEmpty()) {
                    PaymentCard newDefault = remainingCards.get(0);
                    newDefault.setDefaultCard(true);
                    paymentCardDAO.update(newDefault);
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
