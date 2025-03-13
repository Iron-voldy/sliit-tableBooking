<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

        // Make sure this is defined at the top level of your script
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
            console.log("Processing reservations");
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

                            // Initialize reserved array if it doesn't exist
                            if (!tableType.reserved) {
                                tableType.reserved = [];
                            }

                            // Add to the reserved list if not already there
                            if (!tableType.reserved.includes(tableNumber)) {
                                tableType.reserved.push(tableNumber);
                                console.log(`Marked table ${reservation.tableId} as reserved`);
                            }
                        }
                    });
                }
            });

            console.log("Reservation processing complete");
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

        // Replace your entire generateFloorView function with this
        function generateFloorView(floorNumber) {
            console.log("Generating floor view for floor", floorNumber);

            // This is the correct ID format - no dash between floor and number
            const containerId = "floor" + floorNumber + "-tables";
            console.log("Looking for container with ID:", containerId);

            const container = document.getElementById(containerId);

            // Add a check to ensure the element exists
            if (!container) {
                console.error(`Element with ID "${containerId}" not found`);
                // Debug output to see all floor-related IDs
                const allElements = document.querySelectorAll('[id*="floor"]');
                console.log("All floor-related elements:", Array.from(allElements).map(el => el.id));
                return; // Exit the function if the element doesn't exist
            }

            console.log("Found container:", container);
            container.innerHTML = "";

            floorConfig[floorNumber].tables.forEach((tableType) => {
                for (let i = 0; i < tableType.count; i++) {
                    const isReserved = tableType.reserved && tableType.reserved.includes(i);
                    const tableItem = document.createElement("div");
                    const tableId = `${tableType.id}${i + 1}`;

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

            // Generate modal content - avoid complex JSP EL expressions
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
        }

        // Updated showFloor function
        function showFloor(floorNumber) {
            console.log("Showing floor", floorNumber, "Type:", typeof floorNumber);

            rotateBuilding = false;
            gsap.to(scene.rotation, { y: 0, duration: 0.5 });
            gsap.to(scene.position, { x: -30, duration: 1 });

            // The issue might be here - make sure floorNumber is a valid number
            if (typeof floorNumber !== 'number') {
                floorNumber = parseInt(floorNumber);
            }

            if (isNaN(floorNumber)) {
                console.error("Invalid floor number:", floorNumber);
                return;
            }

            console.log("Looking for floor map with ID: floor-" + floorNumber + "-map");

            // Use string concatenation instead of template literals to avoid issues
            const floorMapId = "floor-" + floorNumber + "-map";
            const floorMap = document.getElementById(floorMapId);

            if (!floorMap) {
                console.error("Floor map element not found:", floorMapId);
                return;
            }

            console.log("Found floor map element:", floorMap);
            generateFloorView(floorNumber);

            // Make sure the floor map is visible
            floorMap.style.display = "block";
            floorMap.style.opacity = "1";
        }

        // Updated handleReservation function
        function handleReservation(type, number, floor, tableId) {
            // Create a modal overlay to darken the background
            const overlay = document.createElement("div");
            overlay.classList.add("modal-overlay");
            document.body.appendChild(overlay);

            // Format the time slot display
            const timeSlot = formatTimeSlot(reservationDetails.time, reservationDetails.duration);

            // Create modal
            const modal = document.createElement("div");
            modal.classList.add("booking-modal");

            // Determine seat count based on table type
            let seatCount = "2"; // Default
            if (type == "family") {
                seatCount = "6";
            } else if (type == "luxury") {
                seatCount = "10";
            } else if (type == "regular") {
                seatCount = "4";
            }

            // Generate modal content
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
                            <strong>Booking Type:</strong> ${reservationDetails.bookingType == 'special' ? 'Special Booking' : 'Standard Booking'}
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
        }

        function closeFloorView() {
            gsap.to(scene.position, { x: 0, duration: 1 });
            document.querySelectorAll('.floor-map').forEach(map => {
                map.style.opacity = "0";
                setTimeout(() => {
                    map.style.display = "none";
                }, 500);
            });
            rotateBuilding = true;
        }

        // Event listeners - Making sure we're passing numeric values
        document.getElementById("floor1").addEventListener("click", function() {
            showFloor(1); // Explicitly pass 1 as a number
        });

        document.getElementById("floor2").addEventListener("click", function() {
            showFloor(2); // Explicitly pass 2 as a number
        });

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