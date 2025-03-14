<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Table Selection | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tableSelection.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
</head>
<body>
    <%
        // Check if user is logged in
        if (session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get data from previous page (date selection)
        String reservationDate = (String) session.getAttribute("reservationDate");
        String reservationTime = (String) session.getAttribute("reservationTime");
        String bookingType = (String) session.getAttribute("bookingType");
        String reservationDuration = (String) session.getAttribute("reservationDuration");

        // Default duration is 2 hours for normal booking
        if (reservationDuration == null && "normal".equals(bookingType)) {
            reservationDuration = "2";
        } else if (reservationDuration == null) {
            reservationDuration = "2"; // Default fallback
        }

        if (reservationDate == null || reservationTime == null) {
            response.sendRedirect(request.getContextPath() + "/dateSelection.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");

        // Get reserved tables from request attribute
        List<String> reservedTables = (List<String>) request.getAttribute("reservedTables");
        if (reservedTables == null) {
            reservedTables = new ArrayList<>();
        }
    %>

    <!-- Header Navigation -->
    <nav class="header-nav">
        <a href="${pageContext.request.contextPath}/" class="logo">Gourmet Reserve</a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/reservation/dateSelection">Reservations</a>
            <a href="${pageContext.request.contextPath}/user/profile.jsp">Profile</a>
            <a href="${pageContext.request.contextPath}/user/logout">Logout</a>
        </div>
    </nav>

    <div class="controls">
        <h4 class="reservation-info">
            <% if ("special".equals(bookingType)) { %>
                Special Booking for <%= reservationDate %> at <%= reservationTime %> (<%= reservationDuration %> hours)
            <% } else { %>
                Booking for <%= reservationDate %> at <%= reservationTime %> (2 hours)
            <% } %>
        </h4>
        <button class="btn btn-primary mb-2" id="floor1">1st Floor</button>
        <button class="btn btn-primary" id="floor2">2nd Floor</button>
    </div>

    <!-- Floor Maps -->

    <div class="floor-map" id="floor-1-map">
        <div class="d-flex justify-content-between mb-4">
            <h3>First Floor Layout</h3>
            <button class="btn btn-danger" onclick="closeFloorView()">Close</button>
        </div>
        <div class="table-grid" id="floor1-tables"></div>
    </div>

    <div class="floor-map" id="floor-2-map">
        <div class="d-flex justify-content-between mb-4">
            <h3>Second Floor Layout</h3>
            <button class="btn btn-danger" onclick="closeFloorView()">Close</button>
        </div>
        <div class="table-grid" id="floor2-tables"></div>
    </div>

    <div id="three-container"></div>

    <!-- Error Message Display -->
    <%
        String errorMessage = (String) request.getAttribute("errorMessage");
        if (errorMessage != null) {
    %>
    <div class="error-toast">
        <%= errorMessage %>
    </div>
    <% } %>

    <script>
// Store reservation details from JSP
// Store reservation details from JSP
const reservationDetails = {
    date: "<%= reservationDate %>",
    time: "<%= reservationTime %>",
    username: "<%= username %>",
    bookingType: "<%= bookingType %>",
    duration: parseInt("<%= reservationDuration %>")
};

// Initialize reserved tables from server data
const serverReservedTables = [
    <% for (int i = 0; i < reservedTables.size(); i++) { %>
        "<%= reservedTables.get(i) %>"<%= i < reservedTables.size() - 1 ? "," : "" %>
    <% } %>
];

console.log("Received reserved tables from server:", serverReservedTables);

// Queue implementation for table reservation
class ReservationQueue {
    constructor() {
        this.queue = [];
    }

    enqueue(reservation) {
        this.queue.push(reservation);
    }

    dequeue() {
        if (this.isEmpty()) {
            return null;
        }
        return this.queue.shift();
    }

    isEmpty() {
        return this.queue.length == 0;
    }

    size() {
        return this.queue.length;
    }

    getQueue() {
        return [...this.queue];
    }
}

// Merge sort implementation for sorting reservations
function mergeSort(arr, compareFunction) {
    if (arr.length <= 1) {
        return arr;
    }

    const mid = Math.floor(arr.length / 2);
    const left = arr.slice(0, mid);
    const right = arr.slice(mid);

    return merge(
        mergeSort(left, compareFunction),
        mergeSort(right, compareFunction),
        compareFunction
    );
}

function merge(left, right, compareFunction) {
    let result = [];
    let leftIndex = 0;
    let rightIndex = 0;

    while (leftIndex < left.length && rightIndex < right.length) {
        if (compareFunction(left[leftIndex], right[rightIndex]) <= 0) {
            result.push(left[leftIndex]);
            leftIndex++;
        } else {
            result.push(right[rightIndex]);
            rightIndex++;
        }
    }

    return result.concat(left.slice(leftIndex)).concat(right.slice(rightIndex));
}

// Function to convert time string to minutes for comparison
function timeToMinutes(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(num => parseInt(num));
    return hours * 60 + minutes;
}

// Function to check for time slot conflicts
function hasTimeConflict(reservation1, reservation2) {
    // Convert times to minutes for easier comparison
    const start1 = timeToMinutes(reservation1.time);
    const end1 = start1 + (reservation1.duration * 60);

    const start2 = timeToMinutes(reservation2.time);
    const end2 = start2 + (reservation2.duration * 60);

    // Check if the time slots overlap
    return (start1 < end2 && start2 < end1);
}

let scene, camera, renderer, building;
let rotateBuilding = true;
let reservationQueue = new ReservationQueue();

// Initialize the floor configuration with table information
const floorConfig = {
    1: {
        tables: [
            { type: "family", chairs: 6, count: 4, reserved: [], id: "f1-" },
            { type: "regular", chairs: 4, count: 10, reserved: [], id: "r1-" },
            { type: "couple", chairs: 2, count: 4, reserved: [], id: "c1-" },
        ],
    },
    2: {
        tables: [
            { type: "family", chairs: 6, count: 6, reserved: [], id: "f2-" },
            { type: "luxury", chairs: 10, count: 4, reserved: [], id: "l2-" },
            { type: "couple", chairs: 2, count: 6, reserved: [], id: "c2-" },
        ],
    },
};

// Process the server-provided reserved tables
function processReservedTables() {
    console.log("Processing reserved tables");

    // Iterate through all tables in floor configuration
    for (const floor in floorConfig) {
        const floorTables = floorConfig[floor].tables;

        floorTables.forEach(tableType => {
            // Initialize reserved array if it doesn't exist
            if (!tableType.reserved) {
                tableType.reserved = [];
            } else {
                // Clear existing reservations to avoid duplicates
                tableType.reserved = [];
            }

            // Check each table of this type
            for (let i = 0; i < tableType.count; i++) {
                const tableId = tableType.id + (i + 1);

                // Check if this table is in the serverReservedTables array
                if (serverReservedTables.includes(tableId)) {
                    // Add to the reserved list
                    tableType.reserved.push(i);
                    console.log(`Marked table ${tableId} as reserved`);
                }
            }
        });
    }

    console.log("Reserved tables processing complete");
}

// Process the reserved tables from server
processReservedTables();

function init() {
    // Scene setup
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(
        75,
        window.innerWidth / window.innerHeight,
        0.1,
        1000
    );
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    document
        .getElementById("three-container")
        .appendChild(renderer.domElement);

    // Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(10, 20, 15);
    scene.add(directionalLight);

    // Create realistic restaurant
    createRestaurantBuilding();

    camera.position.set(0, 15, 30);
    camera.lookAt(0, 0, 0);

    animate();
}

function generateFloorView(floorNumber) {
    console.log("generateFloorView received floorNumber:", floorNumber);

    // Ensure floorNumber is a number and not NaN
    floorNumber = Number(floorNumber);

    if (isNaN(floorNumber)) {
        console.error("floorNumber is NaN!");
        return;
    }

    // Now construct the container ID with the validated floorNumber
    const containerId = "floor" + floorNumber + "-tables";
    console.log("Looking for container with ID:", containerId);

    const container = document.getElementById(containerId);

    // Check if container exists with proper debugging
    if (!container) {
        console.error(`Element with ID "${containerId}" not found`);
        return;
    }

    console.log("Container found, proceeding with table generation");

    // Clear the container before adding new elements
    container.innerHTML = "";

    // Add custom styles for table display
    const styleElement = document.createElement('style');
    styleElement.textContent = `
        .table-item {
            background: #333;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            border: 2px solid #555;
            position: relative;
            overflow: hidden;
        }

        .table-item:not(.reserved):hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(212, 175, 55, 0.4);
            border-color: #D4AF37;
        }

        .table-item.reserved {
            background: #8B0000;
            border-color: #ff6666;
        }

        .table-header {
            margin-top: 25px; /* Add space at the top to avoid overlap with status label */
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .table-header .table-name {
            font-size: 1.2rem;
            font-weight: bold;
            color: #D4AF37;
            margin-bottom: 5px;
        }

        .status-label {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: bold;
            z-index: 1; /* Ensure it's above other elements */
        }

        .status-available {
            background: #28a745;
            color: white;
        }

        .status-reserved {
            background: #dc3545;
            color: white;
        }

        .table-content {
            margin-bottom: 15px;
        }

        .chairs-display {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            margin: 15px 0;
        }

        .table-visual {
            position: relative;
            width: 120px;
            height: 90px;
            margin: 0 auto;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-bottom: 20px;
        }

        .table-shape {
            width: 100%;
            height: 70%;
            background: #4a4a4a;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            font-weight: bold;
        }

        .family-table {
            background: linear-gradient(135deg, #4a4a4a, #636363);
        }

        .regular-table {
            background: linear-gradient(135deg, #4a4a4a, #5a5a5a);
        }

        .couple-table {
            background: linear-gradient(135deg, #4a4a4a, #505050);
            width: 80%;
        }

        .luxury-table {
            background: linear-gradient(135deg, #4a4a4a, #6a6a6a);
            height: 80%;
        }

        .chair {
            width: 20px;
            height: 20px;
            background: #333;
            border: 2px solid #555;
            border-radius: 50%;
            position: absolute;
        }

        .chair-top {
            top: -10px;
        }

        .chair-bottom {
            bottom: -10px;
        }

        .chair-left {
            left: -10px;
        }

        .chair-right {
            right: -10px;
        }

        .table-details {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
        }

        .detail-item {
            text-align: center;
        }

        .detail-label {
            font-size: 0.8rem;
            color: #bbb;
            margin-bottom: 3px;
        }

        .detail-value {
            font-size: 1rem;
            color: white;
            font-weight: bold;
        }

        .book-now-btn {
            width: 100%;
            padding: 10px;
            background: linear-gradient(135deg, #D4AF37, #AA8C2C);
            border: none;
            border-radius: 8px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        .book-now-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(212, 175, 55, 0.3);
        }

        .reserved-notice {
            width: 100%;
            padding: 10px;
            background: rgba(220, 53, 69, 0.2);
            border: 1px solid rgba(220, 53, 69, 0.5);
            border-radius: 8px;
            color: #ff6666;
            font-weight: bold;
        }
    `;
    document.head.appendChild(styleElement);

    // Check if floor config exists
    if (!floorConfig[floorNumber] || !floorConfig[floorNumber].tables) {
        console.error(`No configuration found for floor ${floorNumber}`);
        return;
    }

    floorConfig[floorNumber].tables.forEach((tableType) => {
        for (let i = 0; i < tableType.count; i++) {
            const isReserved = tableType.reserved && tableType.reserved.includes(i);
            const tableItem = document.createElement("div");
            const tableId = tableType.id + (i + 1);

            tableItem.className = `table-item ${isReserved ? "reserved" : ""}`;

            // Determine pricing based on table type
            let price;
            switch(tableType.type) {
                case "family":
                    price = "$120";
                    break;
                case "luxury":
                    price = "$180";
                    break;
                case "regular":
                    price = "$80";
                    break;
                case "couple":
                    price = "$60";
                    break;
                default:
                    price = "$100";
            }

            // Create table visual with appropriate number of chairs
            let chairsHtml = '';

            // Position chairs around table based on table type
            if (tableType.type === "family") {
                // 6 chairs for family tables
                chairsHtml +=
                    '<div class="chair chair-top" style="left: 20px;"></div>' +
                    '<div class="chair chair-top" style="left: 60px;"></div>' +
                    '<div class="chair chair-left" style="top: 30px;"></div>' +
                    '<div class="chair chair-right" style="top: 30px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 20px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 60px;"></div>';
            } else if (tableType.type === "luxury") {
                // 10 chairs for luxury tables
                chairsHtml +=
                    '<div class="chair chair-top" style="left: 15px;"></div>' +
                    '<div class="chair chair-top" style="left: 45px;"></div>' +
                    '<div class="chair chair-top" style="left: 75px;"></div>' +
                    '<div class="chair chair-left" style="top: 20px;"></div>' +
                    '<div class="chair chair-left" style="top: 50px;"></div>' +
                    '<div class="chair chair-right" style="top: 20px;"></div>' +
                    '<div class="chair chair-right" style="top: 50px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 15px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 45px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 75px;"></div>';
            } else if (tableType.type === "regular") {
                // 4 chairs for regular tables
                chairsHtml +=
                    '<div class="chair chair-top" style="left: 40px;"></div>' +
                    '<div class="chair chair-right" style="top: 30px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 40px;"></div>' +
                    '<div class="chair chair-left" style="top: 30px;"></div>';
            } else {
                // 2 chairs for couple tables
                chairsHtml +=
                    '<div class="chair chair-top" style="left: 40px;"></div>' +
                    '<div class="chair chair-bottom" style="left: 40px;"></div>';
            }

            // Create the table HTML without using template literals (backticks)
            let tableInnerHTML =
                '<div class="status-label ' + (isReserved ? 'status-reserved' : 'status-available') + '">' +
                    (isReserved ? 'Reserved' : 'Available') +
                '</div>' +

                '<div class="table-header">' +
                    '<div class="table-name">' + tableType.type.toUpperCase() + ' ' + (i + 1) + '</div>' +
                    '<div class="table-type">Floor ' + floorNumber + '</div>' +
                '</div>' +

                '<div class="table-visual">' +
                    chairsHtml +
                    '<div class="table-shape ' + tableType.type + '-table">' + tableType.chairs + ' seats</div>' +
                '</div>' +

                '<div class="table-details">' +
                    '<div class="detail-item">' +
                        '<div class="detail-label">Capacity</div>' +
                        '<div class="detail-value">' + tableType.chairs + '</div>' +
                    '</div>' +
                    '<div class="detail-item">' +
                        '<div class="detail-label">Type</div>' +
                        '<div class="detail-value">' + tableType.type.charAt(0).toUpperCase() + tableType.type.slice(1) + '</div>' +
                    '</div>' +
                    '<div class="detail-item">' +
                        '<div class="detail-label">Price</div>' +
                        '<div class="detail-value">' + price + '</div>' +
                    '</div>' +
                '</div>';

            // Add different content based on reservation status without using ternary operators with backticks
            if (isReserved) {
                tableInnerHTML += '<div class="reserved-notice">This table is currently reserved</div>';
            } else {
                tableInnerHTML += '<button class="book-now-btn" data-table-id="' + tableId + '">Book Now</button>';
            }

            // Set the table item HTML
            tableItem.innerHTML = tableInnerHTML;

            // Only add event listener if the table is not reserved
            if (!isReserved) {
                const bookButton = tableItem.querySelector(".book-now-btn");
                if (bookButton) {
                    bookButton.addEventListener("click", function() {
                        handleReservation(tableType.type, i + 1, floorNumber, tableId);
                    });
                }
            }

            container.appendChild(tableItem);
            console.log('Added ' + tableType.type + ' table ' + (i+1) + ' to floor ' + floorNumber);
        }
    });
}

function showFloor(floorNumber) {
    console.log("Showing floor", floorNumber);

    rotateBuilding = false;
    gsap.to(scene.rotation, { y: 0, duration: 0.5 });
    gsap.to(scene.position, { x: -30, duration: 1 });

    // Ensure floorNumber is a number
    floorNumber = Number(floorNumber);

    // Use the correct ID format for the floor map
    const floorMapId = "floor-" + floorNumber + "-map";
    const floorMap = document.getElementById(floorMapId);

    console.log("Looking for floor map with ID:", floorMapId);

    if (!floorMap) {
        console.error("Floor map element not found:", floorMapId);
        return;
    }

    console.log("Found floor map element:", floorMap);

    // First, make sure we have the latest reserved tables
    refreshReservedTables(() => {
        // Generate floor view after getting latest data
        generateFloorView(floorNumber);

        // Make sure the floor map is visible
        floorMap.style.display = "block";
        floorMap.style.opacity = "1";
    });
}

// Function to refresh the reserved tables from the server
function refreshReservedTables(callback) {
    // Make AJAX call to get updated reserved tables - only tables with COMPLETED payments
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "${pageContext.request.contextPath}/reservation/getReservedTables?date=" +
        reservationDetails.date + "&time=" + reservationDetails.time +
        "&duration=" + reservationDetails.duration + "&paymentStatus=COMPLETED", true);

    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    const response = JSON.parse(xhr.responseText);
                    if (response.reservedTables) {
                        // Update serverReservedTables - clear existing data first
                        serverReservedTables.length = 0; // Clear existing array

                        // Add new data - only tables with completed payments
                        response.reservedTables.forEach(tableId => {
                            serverReservedTables.push(tableId);
                        });

                        console.log("Updated reserved tables (completed payments only):", serverReservedTables);

                        // Reset reserved tables in floorConfig - clear all existing reservations
                        for (const floor in floorConfig) {
                            floorConfig[floor].tables.forEach(tableType => {
                                // Clear all existing reservations to start fresh
                                tableType.reserved = [];
                            });
                        }

                        // Process the updated reserved tables
                        processReservedTables();
                    }
                } catch (e) {
                    console.error("Error parsing server response:", e);
                    console.error("Response text:", xhr.responseText);
                }
            } else {
                console.error("Error fetching reserved tables. Status:", xhr.status);
            }

            // Call the callback function if provided
            if (typeof callback === 'function') {
                callback();
            }
        }
    };

    xhr.send();
}

function formatTimeSlot(time, duration) {
    const [hours, minutes] = time.split(':');
    const startTime = `${hours}:${minutes}`;

    // Calculate end time
    let endHours = parseInt(hours) + parseInt(duration);
    const endMinutes = minutes;

    // Format with leading zeros and handle AM/PM
    const formattedStartTime = formatTimeDisplay(parseInt(hours), parseInt(minutes));
    const formattedEndTime = formatTimeDisplay(endHours, parseInt(endMinutes));

    return `${formattedStartTime} - ${formattedEndTime}`;
}

function formatTimeDisplay(hours, minutes) {
    const period = hours >= 12 ? 'PM' : 'AM';
    const displayHours = hours % 12 || 12; // Convert 0 to 12 for 12 AM
    const displayMinutes = minutes.toString().padStart(2, '0');
    return `${displayHours}:${displayMinutes} ${period}`;
}

// Update the handleReservation function to correctly send form data
function handleReservation(type, number, floor, tableId) {
    // Check if table is still available (one more time)
    refreshReservedTables(() => {
        // After refresh, check if table is now reserved
        let isNowReserved = false;
        for (const floor in floorConfig) {
            const floorTables = floorConfig[floor].tables;

            floorTables.forEach(tableType => {
                if (tableType.id + number === tableId && tableType.reserved.includes(number - 1)) {
                    isNowReserved = true;
                }
            });
        }

        if (isNowReserved) {
            // Table has been reserved by someone else in the meantime
            alert("Sorry, this table has just been reserved by another customer. Please choose a different table.");
            // Refresh the current floor view
            generateFloorView(floor);
            return;
        }

        // Create a modal overlay
        const overlay = document.createElement("div");
        overlay.classList.add("modal-overlay");
        document.body.appendChild(overlay);

        // Format the time slot display
        const timeSlot = formatTimeSlot(reservationDetails.time, reservationDetails.duration);

        // Create modal
        const modal = document.createElement("div");
        modal.classList.add("booking-modal");

        // Determine seat count based on table type
        let seatCount = "2";
        if (type === "family") {
            seatCount = "6";
        } else if (type === "luxury") {
            seatCount = "10";
        } else if (type === "regular") {
            seatCount = "4";
        }

        // Get booking type description
        const bookingTypeText = reservationDetails.bookingType == 'special' ?
                               'Special Booking' : 'Standard Booking';

        // Generate modal content with properly set hidden input values
        modal.innerHTML = `
            <div class="modal-header">
                <h2>Confirm Your Reservation</h2>
                <p>Experience fine dining at its best</p>
            </div>
            <button class="close-btn">×</button>
            <form id="bookingForm" action="${pageContext.request.contextPath}/reservation/confirmReservation" method="post">
                <input type="hidden" name="tableId" value="${tableId}">
                <div class="reservation-summary">
                    <div class="summary-item">
                        <strong>Date:</strong> ${reservationDetails.date}
                    </div>
                    <div class="summary-item">
                        <strong>Time Slot:</strong> ${timeSlot}
                    </div>
                    <div class="summary-item">
                        <strong>Booking Type:</strong> ${bookingTypeText}
                    </div>
                    <div class="summary-item">
                        <strong>Table:</strong> ${type.toUpperCase()} ${number} (Floor ${floor})
                    </div>
                    <div class="summary-item">
                        <strong>Seats:</strong> ${seatCount}
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Special Requests</label>
                    <textarea name="specialRequests" class="special-requests" placeholder="Dietary needs, accessibility requirements, etc..."></textarea>
                </div>

                <button type="submit" class="submit-btn">Confirm Reservation</button>
            </form>
        `;

        document.body.appendChild(modal);
        modal.style.display = "block";

        // Submit form with proper AJAX handling
        const bookingForm = modal.querySelector("#bookingForm");
        bookingForm.addEventListener("submit", function(e) {
            e.preventDefault();

            // Debug: log the form data
            const formData = new FormData(bookingForm);
            console.log("Form data being submitted:");
            for (let pair of formData.entries()) {
                console.log(pair[0] + ": " + pair[1]);
            }

            // Ensure tableId is properly included
            if (!formData.get('tableId')) {
                console.error("tableId is missing from form data");
                formData.set('tableId', tableId);
            }

            // Send form data via AJAX
            const xhr = new XMLHttpRequest();
            xhr.open("POST", bookingForm.action, true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    console.log("Response status:", xhr.status);
                    console.log("Response text:", xhr.responseText);

                    if (xhr.status === 200) {
                        try {
                            // Redirect to payment initiation
                            window.location.href = "${pageContext.request.contextPath}/payment/initiate";
                        } catch (e) {
                            console.error("Error handling reservation response:", e);
                            alert("An error occurred while processing your reservation. Please try again.");
                        }
                    } else {
                        alert("Error creating reservation. Please try again.");
                    }
                }
            };

            // Convert FormData to URL-encoded string
            const urlEncodedData = new URLSearchParams(formData).toString();
            console.log("Sending data:", urlEncodedData);

            xhr.send(urlEncodedData);
        });

        // Close button functionality
        const closeButton = modal.querySelector(".close-btn");
        closeButton.addEventListener("click", () => {
            modal.remove();
            overlay.remove();
        });

        // Close when clicking outside
        overlay.addEventListener("click", () => {
            modal.remove();
            overlay.remove();
        });
    });
}

function closeFloorView() {
    gsap.to(scene.position, { x: 0, duration: 1 });
    document.querySelectorAll('.floor-map').forEach(map => {
        gsap.to(map, {
            opacity: 0,
            duration: 0.5,
            onComplete: function() {
                map.style.display = "none";
            }
        });
    });
    rotateBuilding = true;
}

// Event listeners for floor buttons
document.getElementById("floor1").addEventListener("click", function() {
    showFloor(1);
});

document.getElementById("floor2").addEventListener("click", function() {
    showFloor(2);
});

window.addEventListener("resize", onWindowResize);

function createFloorTables(building, yPos, floorNumber) {
    const floorGroup = new THREE.Group();

    // Floor base
    const floorGeometry = new THREE.BoxGeometry(19.8, 0.2, 29.8);
    const floorMaterial = new THREE.MeshPhongMaterial({ color: 0x303030 });
    const floor = new THREE.Mesh(floorGeometry, floorMaterial);
    floor.position.y = yPos;
    floorGroup.add(floor);

    // Add tables
    const tableConfig = {
        1: { family: 4, regular: 10, couple: 4 },
        2: { family: 6, luxury: 4, couple: 6 },
    }[floorNumber];

    Object.entries(tableConfig).forEach(([type, count]) => {
        for (let i = 0; i < count; i++) {
            const table = createTableMesh(type);

            // Check if this table is reserved
            const tableId = `${type.charAt(0)}${floorNumber}-${i+1}`;
            const isReserved = serverReservedTables.includes(tableId);

            // Color tables based on reservation status
            if (isReserved) {
                table.material.color.set(0x8B0000); // Dark red for reserved tables
            }

            table.position.set(
                -8 + (i % 5) * 4,
                yPos + 0.3,
                -12 + Math.floor(i / 5) * 4
            );
            floorGroup.add(table);
        }
    });

    building.add(floorGroup);
}

function createTableMesh(type) {
    const size = {
        family: { width: 1.5, depth: 1.5, height: 0.1 },
        luxury: { width: 2.5, depth: 2.5, height: 0.1 },
        regular: { width: 1.2, depth: 1.2, height: 0.1 },
        couple: { width: 1, depth: 1, height: 0.1 },
    }[type];

    const tableGeometry = new THREE.BoxGeometry(
        size.width,
        size.height,
        size.depth
    );
    const tableMaterial = new THREE.MeshPhongMaterial({ color: 0x4a4a4a });
    const table = new THREE.Mesh(tableGeometry, tableMaterial);

    // Table legs
    const legGeometry = new THREE.CylinderGeometry(0.1, 0.1, 0.4);
    const legMaterial = new THREE.MeshPhongMaterial({ color: 0x333333 });

    [
        [-1, -1],
        [1, -1],
        [-1, 1],
        [1, 1],
    ].forEach(([xMod, zMod]) => {
        const leg = new THREE.Mesh(legGeometry, legMaterial);
        leg.position.set(
            xMod * (size.width / 2 - 0.2),
            -0.25,
            zMod * (size.depth / 2 - 0.2)
        );
        table.add(leg);
    });

    return table;
}

function animate() {
    requestAnimationFrame(animate);
    if (rotateBuilding) scene.rotation.y += 0.002;
    renderer.render(scene, camera);
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Initialize the 3D scene
init();

// Refresh reserved tables every 30 seconds to keep the view updated
setInterval(function() {
    if (!rotateBuilding) { // Only refresh if user is viewing a floor
        refreshReservedTables(() => {
            // After refreshing, update the current floor view if it's open
            const visibleFloorMap = document.querySelector('.floor-map[style*="display: block"]');
            if (visibleFloorMap) {
                const floorNumber = visibleFloorMap.id.split('-')[1];
                if (floorNumber) {
                    generateFloorView(parseInt(floorNumber));
                }
            }
        });
    }
}, 30000);

// Show error toast if exists and then fade it out
const errorToast = document.querySelector('.error-toast');
if (errorToast) {
    setTimeout(() => {
        errorToast.style.opacity = '0';
        setTimeout(() => {
            errorToast.style.display = 'none';
        }, 500);
    }, 3000);
}

function createRestaurantBuilding() {
    // Main building
    const mainBuilding = new THREE.Group();

    // Building structure
    const geometry = new THREE.BoxGeometry(20, 10, 30);
    const textureLoader = new THREE.TextureLoader();

    // Use placeholder texture if the image fails to load
    const wallTexture = new THREE.MeshPhongMaterial({ color: 0xD2B48C });
    textureLoader.load(
        "https://threejsfundamentals.org/threejs/resources/images/wall.jpg",
        function(texture) {
            wallTexture.map = texture;
            wallTexture.needsUpdate = true;
        }
    );

    const buildingMesh = new THREE.Mesh(geometry, wallTexture);

    // Roof
    const roofGeometry = new THREE.ConeGeometry(22, 6, 4);
    const roofMaterial = new THREE.MeshPhongMaterial({
        color: 0x8b4513, // Dark wood color
        shininess: 100,
    });
    const roof = new THREE.Mesh(roofGeometry, roofMaterial);
    roof.rotation.y = Math.PI / 4;
    roof.position.y = 7.8;

    // Windows
    const windowGeometry = new THREE.BoxGeometry(3, 4, 0.5);
    const windowMaterial = new THREE.MeshPhongMaterial({
        color: 0x87ceeb,
        transparent: true,
        opacity: 0.7,
    });

    for (let i = -7; i <= 7; i += 8) {
        for (let j = -6; j <= 6; j += 12) {
            const window = new THREE.Mesh(windowGeometry, windowMaterial);
            window.position.set(j, 1, i > 0 ? 14.9 : -14.9);
            buildingMesh.add(window);
        }
    }

    // Entrance
    const entranceGeometry = new THREE.BoxGeometry(6, 4, 4);
    const entranceMaterial = new THREE.MeshPhongMaterial({
        color: 0xcd8500,
    });
    const entrance = new THREE.Mesh(entranceGeometry, entranceMaterial);
    entrance.position.z = 15.1;
    entrance.position.y = -1.5;

    // Signboard
    const signGeometry = new THREE.BoxGeometry(8, 1, 0.2);
    const signMaterial = new THREE.MeshPhongMaterial({ color: 0xffd700 });
    const sign = new THREE.Mesh(signGeometry, signMaterial);
    sign.position.set(0, 7, 15.1);

    // Parking lot
    const parkingLot = new THREE.Mesh(
        new THREE.PlaneGeometry(40, 50),
        new THREE.MeshPhongMaterial({ color: 0x444444 })
    );
    parkingLot.rotation.x = -Math.PI / 2;
    parkingLot.position.y = -5.1;

    // Assemble building
    mainBuilding.add(buildingMesh);
    mainBuilding.add(roof);
    mainBuilding.add(entrance);
    mainBuilding.add(sign);
    mainBuilding.add(parkingLot);

    // Add tables
    createFloorTables(mainBuilding, -4, 1);
    createFloorTables(mainBuilding, 4, 2);

    scene.add(mainBuilding);
    building = mainBuilding;
}
                        </script>
                    </body>
                    </html>