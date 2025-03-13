<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Table Selection | Gourmet Reserve</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
      :root {
        --dark-bg: #1a1a1a;
        --table-color: #4a4a4a;
        --reserved-color: #8B0000;
        --hover-color: #3498db;
        --gold: #D4AF37;
      }

      body {
        margin: 0;
        overflow: hidden;
        font-family: 'Roboto', sans-serif;
      }

      #three-container {
        width: 100%;
        height: 100vh;
        position: fixed;
      }

      .controls {
        position: fixed;
        top: 100px;
        left: 20px;
        z-index: 2;
        background: rgba(26, 26, 26, 0.8);
        padding: 15px;
        border-radius: 10px;
        backdrop-filter: blur(5px);
        border: 1px solid rgba(212, 175, 55, 0.2);
      }

      .controls .btn {
        background: linear-gradient(135deg, var(--gold), #800020);
        border: none;
        margin-right: 5px;
      }

      .reservation-info {
        color: var(--gold);
        margin-bottom: 15px;
        font-family: 'Playfair Display', serif;
      }

      .floor-map {
        position: fixed;
        width: 80%;
        height: 80%;
        top: 10%;
        left: 10%;
        background: rgba(45, 45, 45, 0.95);
        border-radius: 10px;
        display: none;
        z-index: 3;
        padding: 20px;
        overflow-y: auto;
        color: #e0e0e0;
      }

      .table-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px;
        padding: 20px;
      }

      .table-item {
        background: var(--table-color);
        border-radius: 8px;
        padding: 15px;
        text-align: center;
        transition: all 0.3s;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      }

      .table-item.reserved {
        background: var(--reserved-color);
        cursor: not-allowed;
      }

      .table-item:not(.reserved):hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 15px rgba(212, 175, 55, 0.3);
        border: 1px solid var(--gold);
      }

      .chair {
        width: 20px;
        height: 20px;
        background: #333;
        border-radius: 3px;
        display: inline-block;
        margin: 2px;
      }

      /* Background overlay */
      .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.8);
        z-index: 9998;
      }

      /* Modal container */
      .booking-modal {
        background: #2c2c2c;
        color: #fff;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 90%;
        max-width: 600px;
        padding: 2rem;
        border-radius: 12px;
        z-index: 9999;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6);
        display: none;
        overflow-y: auto;
        max-height: 90vh;
      }

      .modal-header {
        text-align: center;
        margin-bottom: 1.5rem;
      }

      .modal-header h2 {
        font-size: 2rem;
        color: #ffcc00;
        margin-bottom: 0.5rem;
        font-family: 'Playfair Display', serif;
      }

      .modal-header p {
        color: #ccc;
        font-size: 1rem;
      }

      .close-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        background: #ff4d4d;
        color: white;
        border: none;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        cursor: pointer;
        font-size: 1.2rem;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 0;
      }

      .close-btn:hover {
        background: #e74c3c;
      }

      .header-nav {
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
        color: #e0e0e0;
        text-decoration: none;
        font-family: 'Roboto', sans-serif;
        font-weight: 400;
        transition: color 0.3s ease;
      }

      .nav-links a:hover {
        color: var(--gold);
      }

      /* Form layout */
      .form-group {
        position: relative;
        margin-bottom: 1.5rem;
      }

      .form-label {
        display: block;
        margin-bottom: 0.8rem;
        color: #fff;
        font-weight: 500;
      }

      .special-requests {
        width: 100%;
        height: 100px;
        padding: 1rem;
        background: #333;
        border: 1px solid #555;
        border-radius: 8px;
        font-size: 1rem;
        color: #fff;
        resize: vertical;
      }

      .special-requests:focus {
        outline: none;
        border-color: var(--gold);
      }

      .submit-btn {
        width: 100%;
        padding: 1.2rem;
        background: var(--gold);
        border: none;
        border-radius: 8px;
        color: #333;
        font-size: 1.1rem;
        font-weight: 600;
        cursor: pointer;
        transition: transform 0.3s ease;
      }

      .submit-btn:hover {
        transform: translateY(-2px);
        background: #e6b800;
        box-shadow: 0 5px 15px rgba(212, 175, 55, 0.3);
      }

      /* Reservation summary */
      .reservation-summary {
        background: rgba(255, 255, 255, 0.1);
        border-radius: 8px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        border: 1px solid rgba(212, 175, 55, 0.3);
      }

      .summary-item {
        margin-bottom: 0.8rem;
        font-size: 1.1rem;
      }

      .summary-item strong {
        color: var(--gold);
        margin-right: 0.5rem;
      }

      /* Error toast */
      .error-toast {
        position: fixed;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(231, 76, 60, 0.9);
        color: white;
        padding: 15px 25px;
        border-radius: 8px;
        z-index: 1001;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        animation: fadeInUp 0.3s ease-out;
        opacity: 1;
        transition: opacity 0.5s ease;
      }

      @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translate(-50%, 20px);
        }
        to {
            opacity: 1;
            transform: translate(-50%, 0);
        }
      }

      /* Responsive design */
      @media (max-width: 768px) {
        .floor-map {
            width: 95%;
            left: 2.5%;
        }

        .booking-modal {
            width: 95%;
            padding: 1.5rem;
        }

        .nav-links {
            gap: 1rem;
        }

        .logo {
            font-size: 1.5rem;
        }
      }
    </style>
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
            response.sendRedirect(request.getContextPath() + "/reservation/dateSelection.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
    %>

    <!-- Header Navigation -->
    <nav class="header-nav">
        <a href="${pageContext.request.contextPath}/" class="logo">Gourmet Reserve</a>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/reservation">Reservations</a>
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
        const reservationDetails = {
            date: "<%= reservationDate %>",
            time: "<%= reservationTime %>",
            username: "<%= username %>",
            bookingType: "<%= bookingType %>",
            duration: parseInt("<%= reservationDuration %>")
        };

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

        // Mock existing reservations data - in a real app, this would come from the backend
        const existingReservations = [
            { tableId: "f1-1", date: "<%= reservationDate %>", time: "12:00", duration: 2 },
            { tableId: "r1-1", date: "<%= reservationDate %>", time: "14:00", duration: 2 },
            { tableId: "r1-2", date: "<%= reservationDate %>", time: "18:00", duration: 2 },
            { tableId: "c1-2", date: "<%= reservationDate %>", time: "19:00", duration: 2 },
            { tableId: "f2-1", date: "<%= reservationDate %>", time: "17:00", duration: 3 },
            { tableId: "l2-1", date: "<%= reservationDate %>", time: "13:00", duration: 4 }
        ];

        // Sort existing reservations by time using merge sort
        const sortedReservations = mergeSort(existingReservations, (a, b) => {
            return timeToMinutes(a.time) - timeToMinutes(b.time);
        });

        // Add sorted reservations to the queue
        sortedReservations.forEach(reservation => {
            reservationQueue.enqueue(reservation);
        });

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

        // Process the reservation queue and mark reserved tables
        function processReservations() {
            const currentReservation = {
                time: reservationDetails.time,
                duration: reservationDetails.duration
            };

            // Check each existing reservation against our floor config
            existingReservations.forEach(reservation => {
                // Find the table type in our config
                for (const floor in floorConfig) {
                    const floorTables = floorConfig[floor].tables;

                    floorTables.forEach(tableType => {
                        const tableIdPrefix = tableType.id;

                        // Check if this reservation is for a table of this type
                        if (reservation.tableId.startsWith(tableIdPrefix)) {
                            // Extract the table number from the ID (e.g., "f1-2" -> 2)
                            const tableNumber = parseInt(reservation.tableId.split('-')[1]) - 1;

                            // If it doesn't conflict with the current reservation time, we don't need to mark it
                            if (!hasTimeConflict(reservation, currentReservation)) {
                                return;
                            }

                            // Add to the reserved list if not already there
                            if (!tableType.reserved.includes(tableNumber)) {
                                tableType.reserved.push(tableNumber);
                            }
                        }
                    });
                }
            });
        }

        // Process the reservations before initializing
        processReservations();

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
            const container = document.getElementById(`floor${floorNumber}-tables`);

            // Add a check to ensure the element exists
            if (!container) {
                console.error(`Element with ID "floor${floorNumber}-tables" not found`);
                return; // Exit the function if the element doesn't exist
            }

            container.innerHTML = "";

            floorConfig[floorNumber].tables.forEach((tableType) => {
                for (let i = 0; i < tableType.count; i++) {
                    const isReserved = tableType.reserved.includes(i);
                    const tableItem = document.createElement("div");
                    const tableId = tableType.id + (i + 1);

                    tableItem.className = `table-item ${isReserved ? "reserved" : ""}`;

                    // Generate chair divs with JavaScript
                    let chairsHtml = '';
                    for (let j = 0; j < tableType.chairs; j++) {
                        chairsHtml += '<div class="chair"></div>';
                    }

                    // Generate reservation button or reserved label
                    let statusHtml = '';
                    if (!isReserved) {
                        statusHtml = '<button class="btn btn-sm btn-primary mt-2">Book Now</button>';
                    } else {
                        statusHtml = '<div class="text-warning mt-2">Reserved</div>';
                    }

                    tableItem.innerHTML = `
                        <div class="fw-bold mb-2">${tableType.type.toUpperCase()} ${i + 1}</div>
                        <div class="mb-2">${tableType.chairs} Seats</div>
                        <div class="chairs-container">
                            ${chairsHtml}
                        </div>
                        ${statusHtml}
                    `;

                    if (!isReserved) {
                        tableItem
                            .querySelector("button")
                            .addEventListener("click", () => {
                                handleReservation(tableType.type, i + 1, floorNumber, tableId);
                            });
                    }

                    container.appendChild(tableItem);
                }
            });
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

        function handleReservation(type, number, floor, tableId) {
            // Create a modal overlay to darken the background
            const overlay = document.createElement("div");
            overlay.classList.add("modal-overlay");

            // Format the time slot display
            const timeSlot = formatTimeSlot(reservationDetails.time, reservationDetails.duration);

            // Create modal
            const modal = document.createElement("div");
            modal.classList.add("booking-modal");

            // Generate modal content with vanilla JavaScript (no JSP/EL)
            let modalContent = `
                <div class="modal-header">
                    <h2>Confirm Your Reservation</h2>
                    <p>Experience fine dining at its best</p>
                </div>
                <button class="close-btn">×</button>
                <form id="bookingForm" action="${pageContext.request.contextPath}/reservation/confirmReservation" method="post">
                    <input type="hidden" name="tableId" value="${tableId}">
                    <input type="hidden" name="floorNumber" value="${floor}">
                    <input type="hidden" name="bookingType" value="${reservationDetails.bookingType}">
                    <input type="hidden" name="reservationDuration" value="${reservationDetails.duration}">

                    <div class="reservation-summary">
                        <div class="summary-item">
                            <strong>Date:</strong> ${reservationDetails.date}
                        </div>
                        <div class="summary-item">
                            <strong>Time Slot:</strong> ${timeSlot}
                        </div>
                        <div class="summary-item">
                            <strong>Booking Type:</strong> ${reservationDetails.bookingType == 'special' ? 'Special Booking' : 'Standard Booking'}
                        </div>
                        <div class="summary-item">
                            <strong>Table:</strong> ${type.toUpperCase()} ${number} (Floor ${floor})
                        </div>
                        <div class="summary-item">
                            <strong>Seats:</strong> `;

            // Determine seat count based on table type
            if (type == "family") {
                modalContent += "6";
            } else if (type == "luxury") {
                modalContent += "10";
            } else if (type == "regular") {
                modalContent += "4";
            } else {
                modalContent += "2";
            }

            modalContent += `
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Special Requests</label>
                        <textarea name="specialRequests" class="special-requests" placeholder="Dietary needs, accessibility requirements, etc..."></textarea>
                    </div>

                    <button type="submit" class="submit-btn">Confirm Reservation</button>
                </form>
            `;

            modal.innerHTML = modalContent;

            // Append the overlay and modal to the body
            document.body.appendChild(overlay);
            document.body.appendChild(modal);

            // Show the modal
            modal.style.display = "block";
            overlay.style.display = "block";

            // Close the modal when clicking the close button
            const closeButton = modal.querySelector(".close-btn");
            closeButton.addEventListener("click", () => {
                modal.remove();
                overlay.remove();
            });

            // Close the modal when clicking outside of it
            window.addEventListener("click", (event) => {
                if (event.target == overlay) {
                    modal.remove();
                    overlay.remove();
                }
            });
        }

        function showFloor(floorNumber) {
            // Add debug statement to see what floorNumber actually is
            console.log("Floor number:", floorNumber, "Type:", typeof floorNumber);

            rotateBuilding = false;
            gsap.to(scene.rotation, { y: 0, duration: 0.5 });
            gsap.to(scene.position, { x: -30, duration: 1 });

            // Handle case where floorNumber might be empty or undefined
            if (!floorNumber) {
                console.error("Invalid floor number provided");
                return;
            }

            // Make sure floorNumber is treated as a number
            floorNumber = Number(floorNumber);

            // Use the exact format that matches your HTML
            const floorMap = document.getElementById(`floor-${floorNumber}-map`);


            generateFloorView(floorNumber);
            gsap.to(floorMap, { display: "block", opacity: 1, duration: 0.5 });
        }

        function closeFloorView() {
            gsap.to(scene.position, { x: 0, duration: 1 });
            gsap.to(".floor-map", { opacity: 0, display: "none", duration: 0.5 });
            rotateBuilding = true;
        }

        // Event listeners
        document
            .getElementById("floor1")
            .addEventListener("click", () => showFloor(1)); // Make sure 1 is being passed

        document
            .getElementById("floor2")
            .addEventListener("click", () => showFloor(2)); // Make sure 2 is being passed

        window.addEventListener("resize", onWindowResize);

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
                    const isReserved = existingReservations.some(r =>
                        r.tableId == tableId &&
                        hasTimeConflict(r, {
                            time: reservationDetails.time,
                            duration: reservationDetails.duration
                        })
                    );

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
    </script>
</body>
</html>