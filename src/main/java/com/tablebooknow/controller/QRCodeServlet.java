package com.tablebooknow.controller;

import com.tablebooknow.util.QRCodeGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;

/**
 * Servlet for generating QR codes for reservation check-in
 */
@WebServlet("/QRCodeServlet")
public class QRCodeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String reservationId = request.getParameter("id");

        if (reservationId == null || reservationId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID is required");
            return;
        }

        try {
            // Create the content for the QR code
            // In a real application, you should verify that the user has access to this reservation
            String qrContent = QRCodeGenerator.createQRCodeContent(reservationId, "PAYMENT-ID", userId);

            // Set the content type
            response.setContentType("image/png");

            // Generate QR code
            byte[] qrCodeImage = QRCodeGenerator.generateQRCodeImage(qrContent, 250, 250);

            // Write the image to the response
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(qrCodeImage);
            outputStream.flush();

        } catch (Exception e) {
            System.err.println("Error generating QR code: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code");
        }
    }
}