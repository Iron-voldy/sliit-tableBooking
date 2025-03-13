package com.tablebooknow.controller.payment;

import com.tablebooknow.dao.ReservationDAO;
import com.tablebooknow.model.reservation.Reservation;
import com.tablebooknow.util.PaymentGateway;
import com.tablebooknow.util.ReservationQueue;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Enumeration;

@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {
    private ReservationDAO reservationDAO;
    private ReservationQueue reservationQueue;

    @Override
    public void init() throws ServletException {
        System.out.println("Initializing PaymentServlet");
        reservationDAO = new ReservationDAO();
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
            response.sendRedirect(request.getContextPath() + "/reservation/dateSelection");
            return;
        }

        switch (pathInfo) {
            case "/gateway":
                showPaymentGateway(request, response);
                break;
            case "/success":
                handlePaymentSuccess(request, response);
                break;
            case "/cancel":
                handlePaymentCancel(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        System.out.println("POST request to payment: " + pathInfo