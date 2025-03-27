<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Dashboard | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
            --glass: rgba(255, 255, 255, 0.05);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: var(--dark);
            font-family: 'Roboto', sans-serif;
            background-image:
                linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)),
                url('${pageContext.request.contextPath}/assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
        }

        .payment-dashboard {
            width: 90%;
            max-width: 800px;
            background: rgba(26, 26, 26, 0.95);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
            border: 1px solid rgba(212, 175, 55, 0.3);
            display: flex;
            flex-direction: column;
        }

        .dashboard-header {
            padding: 2rem;
            background: linear-gradient(135deg, rgba(128, 0, 32, 0.8), rgba(26, 26, 26, 0.8));
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
            text-align: center;
        }

        .dashboard-title {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .dashboard-subtitle {
            color: var(--text);
            opacity: 0.9;
        }

        .dashboard-content {
            padding: 2rem;
            display: flex;
            flex-direction: column;
            gap: 2rem;
            flex: 1;
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 1.5rem;
            margin-bottom: 1rem;
            border-bottom: 1px solid rgba(212, 175, 55, 0.2);
            padding-bottom: 0.5rem;
        }

        .payment-methods {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1rem;
        }

        .payment-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid rgba(212, 175, 55, 0.2);
            transition: all 0.3s ease;
            position: relative;
            cursor: pointer;
        }

        .payment-card:hover {
            transform: translateY(-5px);
            border-color: var(--gold);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }

        .payment-card.selected {
            border: 2px solid var(--gold);
            background: rgba(212, 175, 55, 0.1);
        }

        .card-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: var(--gold);
            color: var(--dark);
            font-size: 0.7rem;
            padding: 0.3rem 0.6rem;
            border-radius: 10px;
            font-weight: bold;
        }

        .card-type {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }

        .card-icon {
            font-size: 1.8rem;
            margin-right: 0.8rem;
            color: var(--gold);
        }

        .card-name {
            font-weight: 500;
            color: var(--text);
        }

        .card-number {
            font-family: 'Courier New', monospace;
            letter-spacing: 0.1rem;
            margin-bottom: 1rem;
            color: var(--text);
        }

        .card-expiry {
            font-size: 0.9rem;
            color: #aaa;
        }

        .card-actions {
            margin-top: 1rem;
            display: flex;
            gap: 0.5rem;
        }

        .card-btn {
            background: none;
            border: none;
            color: var(--text);
            font-size: 0.9rem;
            cursor: pointer;
            opacity: 0.7;
            transition: all 0.3s;
        }

        .card-btn:hover {
            opacity: 1;
            color: var(--gold);
        }

        .btn-edit {
            color: #3498db;
        }

        .btn-delete {
            color: #e74c3c;
        }

        .new-card-form {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid rgba(212, 175, 55, 0.2);
            transition: height 0.3s;
            display: none;
            overflow: hidden;
        }

        .new-card-form.visible {
            display: block;
            animation: slideDown 0.3s;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-group {
            margin-bottom: 1.2rem;
        }

        .form-label {
            display: block;
            color: var(--gold);
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .form-input {
            width: 100%;
            padding: 0.8rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 8px;
            color: var(--text);
            font-size: 1rem;
            transition: all 0.3s;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--gold);
            box-shadow: 0 0 10px rgba(212, 175, 55, 0.2);
        }

        .form-row {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .form-row .form-group {
            flex: 1;
            min-width: 120px;
        }

        .toggle-form-btn {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(212, 175, 55, 0.3);
            border-radius: 8px;
            padding: 0.8rem 1.2rem;
            color: var(--text);
            font-size: 1rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .toggle-form-btn:hover {
            background: rgba(212, 175, 55, 0.1);
            color: var(--gold);
        }

        .btn-icon {
            font-size: 1.2rem;
        }

        .save-card-btn {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            border: none;
            border-radius: 8px;
            color: white;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 0.5rem;
        }

        .save-card-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(128, 0, 32, 0.3);
        }

        .reservation-summary {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid rgba(212, 175, 55, 0.2);
            margin-bottom: 1.5rem;
        }

        .summary-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .summary-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .summary-label {
            color: #aaa;
        }

        .summary-value {
            color: var(--text);
            font-weight: 500;
        }

        .summary-value.highlight {
            color: var(--gold);
            font-size: 1.2rem;
        }

        .proceed-btn {
            width: 100%;
            padding: 1.2rem;
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            border: none;
            border-radius: 10px;
            color: white;
            font-size: 1.1rem;
            font-weight: 500;
            cursor: pointer;
            transition: transform 0.3s ease;
            margin-top: 2rem;
        }

        .proceed-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(212, 175, 55, 0.3);
        }

        .proceed-btn:disabled {
            background: #555;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 1.5rem;
            color: var(--text);
            text-decoration: none;
            font-size: 0.9rem;
            opacity: 0.8;
            transition: opacity 0.3s;
        }

        .back-link:hover {
            opacity: 1;
            color: var(--gold);
        }

        .error-message {
            color: #ff4444;
            margin-top: 1rem;
            text-align: center;
            background: rgba(255, 68, 68, 0.1);
            padding: 1rem;
            border-radius: 8px;
            animation: shake 0.5s ease-in-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-5px); }
            40%, 80% { transform: translateX(5px); }
        }

        /* Modal styles */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal {
            background: rgba(26, 26, 26, 0.95);
            border-radius: 15px;
            width: 90%;
            max-width: 500px;
            padding: 2rem;
            border: 1px solid rgba(212, 175, 55, 0.3);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .modal-title {
            font-family: 'Playfair Display', serif;
            color: var(--gold);
            font-size: 1.5rem;
        }

        .close-btn {
            background: none;
            border: none;
            color: var(--text);
            font-size: 1.5rem;
            cursor: pointer;
            transition: all 0.3s;
        }

        .close-btn:hover {
            color: var(--gold);
            transform: rotate(90deg);
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            margin-top: 2rem;
        }

        .modal-btn {
            padding: 0.8rem 1.2rem;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .btn-danger {
            background: rgba(231, 76, 60, 0.8);
            color: white;
            border: none;
        }

        .btn-danger:hover {
            background: #e74c3c;
            transform: translateY(-2px);
        }

        /* ANIMATION FOR PAGE LOAD */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animated {
            animation: fadeIn 0.6s ease-out forwards;
        }

        @media (max-width: 768px) {
            .payment-dashboard {
                width: 95%;
            }

            .dashboard-content {
                padding: 1.5rem;
            }

            .payment-methods {
                grid-template-columns: 1fr;
            }

            .form-row {
                flex-direction: column;
                gap: 0;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        String reservationId = (String) session.getAttribute("reservationId");

        // If no reservation ID is in session, check if it's in request parameters
        if (reservationId == null) {
            reservationId = request.getParameter("reservationId");
        }

        // Get reservation details if available
        com.tablebooknow.model.reservation.Reservation reservation = null;
        String tableType = request.getAttribute("tableType") != null ?
                          (String) request.getAttribute("tableType") : "Regular";

        if (request.getAttribute("reservation") != null) {
            reservation = (com.tablebooknow.model.reservation.Reservation) request.getAttribute("reservation");
        }

        // Get error message if any
        String errorMessage = (String) request.getAttribute("errorMessage");

        // Calculate amount based on table type and duration
        double basePrice = 0;
        int duration = 2; // Default

        if (reservation != null) {
            duration = reservation.getDuration();

            if (tableType.equalsIgnoreCase("Family")) {
                basePrice = 12.00;
            } else if (tableType.equalsIgnoreCase("Luxury")) {
                basePrice = 18.00;
            } else if (tableType.equalsIgnoreCase("Regular")) {
                basePrice = 8.00;
            } else if (tableType.equalsIgnoreCase("Couple")) {
                basePrice = 6.00;
            }
        }

        double totalAmount = basePrice * duration;
    %>

    <div class="payment-dashboard animated">
        <div class="dashboard-header">
            <h1 class="dashboard-title">Payment Dashboard</h1>
            <p class="dashboard-subtitle">Manage your payment methods and complete your reservation</p>
        </div>

        <div class="dashboard-content">
            <!-- Reservation Summary -->
            <div>
                <h2 class="section-title">Reservation Summary</h2>
                <div class="reservation-summary">
                    <div class="summary-item">
                        <span class="summary-label">Reservation ID</span>
                        <span class="summary-value"><%= reservationId %></span>
                    </div>
                    <% if (reservation != null) { %>
                        <div class="summary-item">
                            <span class="summary-label">Date</span>
                            <span class="summary-value"><%= reservation.getReservationDate() %></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Time</span>
                            <span class="summary-value"><%= reservation.getReservationTime() %></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Duration</span>
                            <span class="summary-value"><%= duration %> hours</span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Table Type</span>
                            <span class="summary-value"><%= tableType %></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Price per Hour</span>
                            <span class="summary-value">$<%= String.format("%.2f", basePrice) %></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Total Amount</span>
                            <span class="summary-value highlight">$<%= String.format("%.2f", totalAmount) %></span>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Payment Methods Section -->
            <div>
                <h2 class="section-title">Your Payment Methods</h2>
                <button id="toggleFormBtn" class="toggle-form-btn">
                    <i class="fas fa-plus btn-icon"></i> Add New Payment Method
                </button>

                <div id="newCardForm" class="new-card-form">
                    <form id="cardForm">
                        <div class="form-group">
                            <label class="form-label">Card Holder Name</label>
                            <input type="text" class="form-input" id="cardName" placeholder="Enter cardholder name" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Card Number</label>
                            <input type="text" class="form-input" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19" required>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label">Expiry Date</label>
                                <input type="text" class="form-input" id="expiryDate" placeholder="MM/YY" maxlength="5" required>
                            </div>
                            <div class="form-group">
                                <label class="form-label">CVV</label>
                                <input type="text" class="form-input" id="cvv" placeholder="123" maxlength="3" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Card Type</label>
                            <select class="form-input" id="cardType" required>
                                <option value="">Select card type</option>
                                <option value="visa">Visa</option>
                                <option value="mastercard">Mastercard</option>
                                <option value="amex">American Express</option>
                                <option value="discover">Discover</option>
                            </select>
                        </div>

                        <button type="button" class="save-card-btn" id="saveCardBtn">Save Card</button>
                    </form>
                </div>

                <div class="payment-methods" id="paymentCardsContainer">
                    <!-- Sample Card 1 - Will be replaced by dynamic content -->
                    <div class="payment-card" data-card-id="card1">
                        <div class="card-badge">Default</div>
                        <div class="card-type">
                            <i class="fab fa-cc-visa card-icon"></i>
                            <span class="card-name">Visa</span>
                        </div>
                        <div class="card-number">**** **** **** 1234</div>
                        <div class="card-expiry">Expires: 12/25</div>
                        <div class="card-actions">
                            <button class="card-btn btn-edit" onclick="editCard('card1')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="card-btn btn-delete" onclick="showDeleteModal('card1')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>

                    <!-- Sample Card 2 - Will be replaced by dynamic content -->
                    <div class="payment-card" data-card-id="card2">
                        <div class="card-type">
                            <i class="fab fa-cc-mastercard card-icon"></i>
                            <span class="card-name">Mastercard</span>
                        </div>
                        <div class="card-number">**** **** **** 5678</div>
                        <div class="card-expiry">Expires: 10/24</div>
                        <div class="card-actions">
                            <button class="card-btn btn-edit" onclick="editCard('card2')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="card-btn btn-delete" onclick="showDeleteModal('card2')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Error Message Display -->
            <% if (errorMessage != null) { %>
                <div class="error-message">
                    <%= errorMessage %>
                </div>
            <% } %>

            <!-- Proceed to Payment Button -->
            <form action="${pageContext.request.contextPath}/payment/process" method="post" id="paymentForm">
                <input type="hidden" name="reservationId" value="<%= reservationId %>">
                <input type="hidden" name="selectedCardId" id="selectedCardId" value="">
                <button type="submit" class="proceed-btn" id="proceedBtn" disabled>Proceed to Payment</button>
            </form>

            <a href="${pageContext.request.contextPath}/tableSelection.jsp" class="back-link">Back to Table Selection</a>
        </div>
    </div>

    <!-- Delete Card Confirmation Modal -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal">
            <div class="modal-header">
                <h2 class="modal-title">Delete Payment Method</h2>
                <button class="close-btn" onclick="hideDeleteModal()">&times;</button>
            </div>
            <p>Are you sure you want to delete this payment method? This action cannot be undone.</p>
            <div class="modal-footer">
                <button class="modal-btn btn-secondary" onclick="hideDeleteModal()">Cancel</button>
                <button class="modal-btn btn-danger" id="confirmDeleteBtn">Delete</button>
            </div>
        </div>
    </div>

    <script>
        // Card data store
        let cards = [];

        // Function to load cards from server data
        function loadCardsFromServer() {
            const serverCards = ${paymentCards != null ? paymentCardsJson : '[]'};
            cards = serverCards;
            renderCards();
        }

        // Card element templates
        function getCardHTML(card) {
            const cardLast4 = card.number ? card.number.slice(-4) : card.last4Digits || "****";
            let cardIconClass = 'fa-credit-card';

            if (card.type === 'visa' || card.cardType === 'visa') {
                cardIconClass = 'fa-cc-visa';
            } else if (card.type === 'mastercard' || card.cardType === 'mastercard') {
                cardIconClass = 'fa-cc-mastercard';
            } else if (card.type === 'amex' || card.cardType === 'amex') {
                cardIconClass = 'fa-cc-amex';
            } else if (card.type === 'discover' || card.cardType === 'discover') {
                cardIconClass = 'fa-cc-discover';
            }

            // Get card type display name
            const cardType = card.type || card.cardType || 'card';
            const cardTypeName = cardType.charAt(0).toUpperCase() + cardType.slice(1);

            // Get expiry date
            const expiryDate = card.expiryDate || card.expiryDate || 'N/A';

            let html = `
                <div class="payment-card" data-card-id="${card.id}">
                    ${card.isDefault || card.defaultCard ? '<div class="card-badge">Default</div>' : ''}
                    <div class="card-type">
                        <i class="fab ${cardIconClass} card-icon"></i>
                        <span class="card-name">${cardTypeName}</span>
                    </div>
                    <div class="card-number">**** **** **** ${cardLast4}</div>
                    <div class="card-expiry">Expires: ${expiryDate}</div>
                    <div class="card-actions">
                        <button class="card-btn btn-edit" onclick="editCard('${card.id}')">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button class="card-btn btn-delete" onclick="showDeleteModal('${card.id}')">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </div>
                </div>
            `;
            return html;
        }

        // Element references
        const toggleFormBtn = document.getElementById('toggleFormBtn');
        const newCardForm = document.getElementById('newCardForm');
        const cardForm = document.getElementById('cardForm');
        const saveCardBtn = document.getElementById('saveCardBtn');
        const paymentCardsContainer = document.getElementById('paymentCardsContainer');
        const deleteModal = document.getElementById('deleteModal');
        const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
        const proceedBtn = document.getElementById('proceedBtn');
        const selectedCardIdInput = document.getElementById('selectedCardId');

        // Form toggle functionality
        toggleFormBtn.addEventListener('click', function() {
            newCardForm.classList.toggle('visible');
            if (newCardForm.classList.contains('visible')) {
                toggleFormBtn.innerHTML = '<i class="fas fa-minus btn-icon"></i> Close Form';
            } else {
                toggleFormBtn.innerHTML = '<i class="fas fa-plus btn-icon"></i> Add New Payment Method';
                // Reset form fields
                cardForm.reset();
            }
        });

        // Initialize cards display
        function renderCards() {
            paymentCardsContainer.innerHTML = '';

            if (cards.length === 0) {
                paymentCardsContainer.innerHTML = `
                    <div style="grid-column: 1/-1; text-align: center; padding: 2rem; background: rgba(0,0,0,0.2); border-radius: 12px;">
                        <p>No payment methods added yet.</p>
                    </div>
                `;
                proceedBtn.disabled = true;
                return;
            }

            cards.forEach(card => {
                paymentCardsContainer.innerHTML += getCardHTML(card);
            });

            // Enable proceed button if at least one card exists
            proceedBtn.disabled = false;

            // Add click event to select cards
            document.querySelectorAll('.payment-card').forEach(card => {
                card.addEventListener('click', function(e) {
                    // If clicking on buttons, don't select card
                    if (e.target.closest('.card-actions')) {
                        return;
                    }

                    // Remove selected class from all cards
                    document.querySelectorAll('.payment-card').forEach(c => {
                        c.classList.remove('selected');
                    });

                    // Add selected class to this card
                    this.classList.add('selected');

                    // Update hidden input with selected card ID
                    selectedCardIdInput.value = this.dataset.cardId;
                });
            });

            // Select default card initially
            const defaultCard = cards.find(card => card.isDefault || card.defaultCard);
            if (defaultCard) {
                const defaultCardElement = document.querySelector(`.payment-card[data-card-id="${defaultCard.id}"]`);
                if (defaultCardElement) {
                    defaultCardElement.classList.add('selected');
                    selectedCardIdInput.value = defaultCard.id;
                }
            }
        }

        // Save new card
        saveCardBtn.addEventListener('click', function() {
            const cardName = document.getElementById('cardName').value;
            const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
            const expiryDate = document.getElementById('expiryDate').value;
            const cvv = document.getElementById('cvv').value;
            const cardType = document.getElementById('cardType').value;

            // Basic validation
            if (!cardName || !cardNumber || !expiryDate || !cvv || !cardType) {
                alert('Please fill in all fields');
                return;
            }

            // Validate card number format
            if (!/^\d{13,19}$/.test(cardNumber)) {
                alert('Please enter a valid card number');
                return;
            }

            // Validate expiry date
            if (!/^\d{2}\/\d{2}$/.test(expiryDate)) {
                alert('Please enter a valid expiry date (MM/YY)');
                return;
            }

            // Validate CVV
            if (!/^\d{3,4}$/.test(cvv)) {
                alert('Please enter a valid CVV');
                return;
            }

            // Submit to server via AJAX
            const formData = new FormData();
            formData.append('cardholderName', cardName);
            formData.append('cardNumber', cardNumber);
            formData.append('expiryDate', expiryDate);
            formData.append('cvv', cvv);
            formData.append('cardType', cardType);
            formData.append('makeDefault', cards.length === 0 ? 'true' : 'false');

            // Show loading state
            saveCardBtn.innerHTML = 'Saving...';
            saveCardBtn.disabled = true;

            // Send AJAX request
            fetch('${pageContext.request.contextPath}/paymentcard', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(data => {
                // Reload cards from server
                location.reload();
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to save card: ' + error.message);
                saveCardBtn.innerHTML = 'Save Card';
                saveCardBtn.disabled = false;
            });
        });

        // Delete card logic
        let cardToDelete = null;

        function showDeleteModal(cardId) {
            cardToDelete = cardId;
            deleteModal.style.display = 'flex';
        }

        function hideDeleteModal() {
            deleteModal.style.display = 'none';
            cardToDelete = null;
        }

        confirmDeleteBtn.addEventListener('click', function() {
            if (cardToDelete) {
                // Send delete request to server
                fetch('${pageContext.request.contextPath}/paymentcard/delete?cardId=' + cardToDelete, {
                    method: 'POST'
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    // Reload page to get updated cards
                    location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to delete card: ' + error.message);
                });
            }

            // Close the modal
            hideDeleteModal();
        });

        // Edit card functionality
        function editCard(cardId) {
            // Find the card object
            const card = cards.find(c => c.id === cardId);

            if (!card) {
                return;
            }

            // Show the form
            newCardForm.classList.add('visible');
            toggleFormBtn.innerHTML = '<i class="fas fa-minus btn-icon"></i> Close Form';

            // Populate form with card data
            document.getElementById('cardName').value = card.cardholderName || card.name || '';
            document.getElementById('cardNumber').value = card.maskedCardNumber || '**** **** **** ' + card.last4Digits || '';
            document.getElementById('expiryDate').value = card.expiryDate || '';
            document.getElementById('cvv').value = card.cvv || '';
            document.getElementById('cardType').value = card.cardType || card.type || '';

            // Update save button to handle edits
            saveCardBtn.innerHTML = 'Update Card';

            // Set up form submission for update
            const originalOnClick = saveCardBtn.onclick;
            saveCardBtn.onclick = function() {
                const updatedName = document.getElementById('cardName').value;
                const updatedExpiry = document.getElementById('expiryDate').value;
                const updatedCvv = document.getElementById('cvv').value;
                const updatedType = document.getElementById('cardType').value;

                // Basic validation
                if (!updatedName || !updatedExpiry || !updatedCvv || !updatedType) {
                    alert('Please fill in all fields');
                    return;
                }

                // Send update request to server
                const formData = new FormData();
                formData.append('cardId', cardId);
                formData.append('cardholderName', updatedName);
                formData.append('expiryDate', updatedExpiry);
                formData.append('cvv', updatedCvv);
                formData.append('cardType', updatedType);

                // Show loading state
                saveCardBtn.innerHTML = 'Updating...';
                saveCardBtn.disabled = true;

                // Send AJAX request
                fetch('${pageContext.request.contextPath}/paymentcard/update', {
                    method: 'POST',
                    body: new URLSearchParams(formData)
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    // Reload page to get updated cards
                    location.reload();
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to update card: ' + error.message);
                    saveCardBtn.innerHTML = 'Update Card';
                    saveCardBtn.disabled = false;
                });
            };
        }

        // Format card number with spaces
        document.getElementById('cardNumber').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '');
            if (value.length > 16) {
                value = value.substr(0, 16);
            }

            // Format with spaces every 4 digits
            let formattedValue = '';
            for (let i = 0; i < value.length; i++) {
                if (i > 0 && i % 4 === 0) {
                    formattedValue += ' ';
                }
                formattedValue += value[i];
            }

            e.target.value = formattedValue;
        });

        // Format expiry date with slash
        document.getElementById('expiryDate').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 4) {
                value = value.substr(0, 4);
            }

            if (value.length > 2) {
                e.target.value = value.substr(0, 2) + '/' + value.substr(2);
            } else {
                e.target.value = value;
            }
        });

        // Make sure CVV is numeric
        document.getElementById('cvv').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '').substr(0, 3);
        });

        // Initialize cards on page load
        window.addEventListener('DOMContentLoaded', function() {
            loadCardsFromServer();
        });

        // Form submission validation
        document.getElementById('paymentForm').addEventListener('submit', function(e) {
            // Check if a card is selected
            if (!selectedCardIdInput.value) {
                e.preventDefault();
                alert('Please select a payment method');
                return;
            }

            // Add the selected card ID to session
            fetch('${pageContext.request.contextPath}/paymentcard/setdefault?cardId=' + selectedCardIdInput.value, {
                method: 'POST'
            })
            .then(() => {
                // Continue with form submission
                proceedBtn.innerHTML = 'Processing...';
                proceedBtn.disabled = true;
            })
            .catch(error => {
                console.error('Error:', error);
                e.preventDefault();
                alert('Failed to select payment method: ' + error.message);
            });
        });
    </script>
</body>
</html>