<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gourmet Reserve - Exquisite Dining Experience</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;600;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --gold: #D4AF37;
            --burgundy: #800020;
            --dark: #1a1a1a;
            --text: #e0e0e0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            font-family: 'Roboto', sans-serif;
            color: var(--text);
            background-color: var(--dark);
            overflow-x: hidden;
        }

        /* Header Styles */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            padding: 1.5rem 5%;
            background: rgba(26, 26, 26, 0.95);
            backdrop-filter: blur(10px);
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(212, 175, 55, 0.3);
        }

        .logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.8rem;
            color: var(--gold);
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
        }

        .nav-links a {
            color: var(--text);
            text-decoration: none;
            font-family: 'Roboto', sans-serif;
            font-weight: 400;
            transition: color 0.3s ease;
        }

        .nav-links a:hover {
            color: var(--gold);
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            background-image:
                linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7)),
                url('assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            padding: 0 5%;
        }

        .hero-content {
            max-width: 700px;
            animation: fadeIn 1s ease-out;
        }

        .hero-title {
            font-family: 'Playfair Display', serif;
            font-size: 3.5rem;
            color: var(--gold);
            margin-bottom: 1.5rem;
            line-height: 1.2;
        }

        .hero-subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            font-weight: 300;
            opacity: 0.9;
        }

        .cta-btn {
            display: inline-block;
            padding: 1rem 2rem;
            background: linear-gradient(135deg, var(--gold), var(--burgundy));
            color: white;
            text-decoration: none;
            font-weight: 500;
            border-radius: 5px;
            transition: all 0.3s ease;
        }

        .cta-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        /* Features Section */
        .features {
            padding: 6rem 5%;
            background: rgba(26, 26, 26, 0.95);
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            color: var(--gold);
            text-align: center;
            margin-bottom: 3rem;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 3rem;
        }

        .feature-card {
            background: rgba(255, 255, 255, 0.05);
            padding: 2rem;
            border-radius: 10px;
            border: 1px solid rgba(212, 175, 55, 0.1);
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            border-color: rgba(212, 175, 55, 0.3);
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--gold);
            margin-bottom: 1rem;
        }

        .feature-title {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: var(--gold);
        }

        .feature-text {
            opacity: 0.8;
            line-height: 1.6;
        }

        /* Table Showcase */
        .table-showcase {
            padding: 6rem 5%;
            background: linear-gradient(rgba(0,0,0,0.9), rgba(0,0,0,0.9)), url('assets/img/restaurant-bg.jpg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
        }

        .tables-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 3rem;
        }

        .table-card {
            background: rgba(26, 26, 26, 0.95);
            border-radius: 15px;
            overflow: hidden;
            border: 1px solid rgba(212, 175, 55, 0.2);
            transition: all 0.3s ease;
        }

        .table-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 30px rgba(0,0,0,0.5);
            border-color: var(--gold);
        }

        .table-img {
            height: 200px;
            background: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: 'Playfair Display', serif;
            font-size: 2rem;
            color: var(--gold);
        }

        .table-card-content {
            padding: 2rem;
        }

        .table-card-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.8rem;
            color: var(--gold);
            margin-bottom: 1rem;
        }

        .table-card-text {
            margin-bottom: 1.5rem;
            line-height: 1.6;
            opacity: 0.8;
        }

        .table-price {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--gold);
            margin-bottom: 1.5rem;
        }

        /* Footer */
        footer {
            background: rgba(26, 26, 26, 0.98);
            padding: 4rem 5%;
            border-top: 1px solid rgba(212, 175, 55, 0.2);
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            margin-bottom: 3rem;
        }

        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 2rem;
            color: var(--gold);
            margin-bottom: 1rem;
        }

        .footer-description {
            opacity: 0.7;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .footer-title {
            color: var(--gold);
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
        }

        .footer-links {
            list-style: none;
        }

        .footer-link {
            margin-bottom: 0.8rem;
        }

        .footer-link a {
            color: var(--text);
            text-decoration: none;
            opacity: 0.7;
            transition: all 0.3s ease;
        }

        .footer-link a:hover {
            opacity: 1;
            color: var(--gold);
        }

        .footer-bottom {
            text-align: center;
            padding-top: 3rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            opacity: 0.7;
            font-size: 0.9rem;
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }

            .hero-subtitle {
                font-size: 1.2rem;
            }

            .nav-links {
                gap: 1rem;
                font-size: 0.9rem;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        boolean isLoggedIn = session.getAttribute("userId") != null;
        String username = (String) session.getAttribute("username");
    %>

    <!-- Header -->
    <header class="header">
        <a href="${pageContext.request.contextPath}/" class="logo">Gourmet Reserve</a>
        <nav class="nav-links">
            <% if (isLoggedIn) { %>
                <a href="${pageContext.request.contextPath}/reservation/dateSelection">Make Reservation</a>
                <a href="${pageContext.request.contextPath}/user/reservations">My Reservations</a>
                <a href="${pageContext.request.contextPath}/user/profile">Profile</a>
                <a href="${pageContext.request.contextPath}/user/logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login.jsp">Login / Register</a>
            <% } %>
        </nav>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1 class="hero-title">Experience Exquisite Dining at Gourmet Reserve</h1>
            <p class="hero-subtitle">Book your perfect table and indulge in a culinary journey crafted by world-class chefs.</p>
            <% if (isLoggedIn) { %>
                <a href="${pageContext.request.contextPath}/reservation/dateSelection" class="cta-btn">Book a Table</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login.jsp" class="cta-btn">Login to Reserve</a>
            <% } %>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <h2 class="section-title">Why Choose Us</h2>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">🍽️</div>
                <h3 class="feature-title">Premium Tables</h3>
                <p class="feature-text">Choose from a variety of table options designed to suit any occasion, from intimate dinners to family gatherings.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📱</div>
                <h3 class="feature-title">Easy Reservations</h3>
                <p class="feature-text">Our intuitive booking system makes it effortless to reserve your perfect table in just a few clicks.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔒</div>
                <h3 class="feature-title">Secure Payments</h3>
                <p class="feature-text">Rest assured with our secure payment system, ensuring your personal information is always protected.</p>
            </div>
        </div>
    </section>

    <!-- Table Showcase -->
    <section class="table-showcase">
        <h2 class="section-title">Our Tables</h2>
        <div class="tables-grid">
            <div class="table-card">
                <div class="table-img">Family Table</div>
                <div class="table-card-content">
                    <h3 class="table-card-title">Family Tables</h3>
                    <p class="table-card-text">Spacious tables perfect for family gatherings and celebrations. Comfortably seats up to 6 people.</p>
                    <div class="table-price">$12/hour</div>
                    <% if (isLoggedIn) { %>
                        <a href="${pageContext.request.contextPath}/reservation/dateSelection" class="cta-btn">Reserve Now</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="cta-btn">Login to Reserve</a>
                    <% } %>
                </div>
            </div>
            <div class="table-card">
                <div class="table-img">Luxury Table</div>
                <div class="table-card-content">
                    <h3 class="table-card-title">Luxury Tables</h3>
                    <p class="table-card-text">Our premium offering with the finest amenities and service for those special occasions. Seats up to 10 people.</p>
                    <div class="table-price">$18/hour</div>
                    <% if (isLoggedIn) { %>
                        <a href="${pageContext.request.contextPath}/reservation/dateSelection" class="cta-btn">Reserve Now</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="cta-btn">Login to Reserve</a>
                    <% } %>
                </div>
            </div>
            <div class="table-card">
                <div class="table-img">Couple Table</div>
                <div class="table-card-content">
                    <h3 class="table-card-title">Couple Tables</h3>
                    <p class="table-card-text">Intimate and cozy tables perfect for romantic dinners. Comfortably seats 2 people.</p>
                    <div class="table-price">$6/hour</div>
                    <% if (isLoggedIn) { %>
                        <a href="${pageContext.request.contextPath}/reservation/dateSelection" class="cta-btn">Reserve Now</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="cta-btn">Login to Reserve</a>
                    <% } %>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div>
                <div class="footer-logo">Gourmet Reserve</div>
                <p class="footer-description">Experience the finest dining with our premium table reservation service.</p>
            </div>
            <div>
                <h3 class="footer-title">Quick Links</h3>
                <ul class="footer-links">
                    <li class="footer-link"><a href="${pageContext.request.contextPath}/">Home</a></li>
                    <% if (isLoggedIn) { %>
                        <li class="footer-link"><a href="${pageContext.request.contextPath}/reservation/dateSelection">Make Reservation</a></li>
                        <li class="footer-link"><a href="${pageContext.request.contextPath}/user/reservations">My Reservations</a></li>
                        <li class="footer-link"><a href="${pageContext.request.contextPath}/user/profile">Profile</a></li>
                    <% } else { %>
                        <li class="footer-link"><a href="${pageContext.request.contextPath}/login.jsp">Login / Register</a></li>
                    <% } %>
                </ul>
            </div>
            <div>
                <h3 class="footer-title">Contact Us</h3>
                <ul class="footer-links">
                    <li class="footer-link">Email: info@gourmetreserve.com</li>
                    <li class="footer-link">Phone: +1 (123) 456-7890</li>
                    <li class="footer-link">Address: 123 Gourmet Avenue, Culinary District</li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2023 Gourmet Reserve. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>