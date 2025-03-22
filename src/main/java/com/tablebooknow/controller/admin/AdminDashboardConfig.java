package com.tablebooknow.controller.admin;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Configuration class for the admin dashboard.
 * Contains static methods to retrieve menu items and other configuration settings.
 */
public class AdminDashboardConfig {

    /**
     * Get the admin menu structure for navigation.
     *
     * @return List of menu items with their properties
     */
    public static List<Map<String, Object>> getAdminMenu() {
        List<Map<String, Object>> menu = new ArrayList<>();

        // Dashboard menu item
        Map<String, Object> dashboardItem = new HashMap<>();
        dashboardItem.put("id", "dashboard");
        dashboardItem.put("name", "Dashboard");
        dashboardItem.put("icon", "📊");
        dashboardItem.put("url", "/admin/dashboard");
        dashboardItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(dashboardItem);

        // Reservations menu item
        Map<String, Object> reservationsItem = new HashMap<>();
        reservationsItem.put("id", "reservations");
        reservationsItem.put("name", "Reservations");
        reservationsItem.put("icon", "📅");
        reservationsItem.put("url", "/admin/reservations/");
        reservationsItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(reservationsItem);

        // Tables menu item
        Map<String, Object> tablesItem = new HashMap<>();
        tablesItem.put("id", "tables");
        tablesItem.put("name", "Table Management");
        tablesItem.put("icon", "🍽️");
        tablesItem.put("url", "/admin/tables/");
        tablesItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(tablesItem);

        // Users menu item
        Map<String, Object> usersItem = new HashMap<>();
        usersItem.put("id", "users");
        usersItem.put("name", "User Management");
        usersItem.put("icon", "👥");
        usersItem.put("url", "/admin/users/");
        usersItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(usersItem);

        // Statistics menu item
        Map<String, Object> statsItem = new HashMap<>();
        statsItem.put("id", "stats");
        statsItem.put("name", "Statistics");
        statsItem.put("icon", "📈");
        statsItem.put("url", "/admin/stats/dashboard");
        statsItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(statsItem);

        // Settings menu item (only for superadmin)
        Map<String, Object> settingsItem = new HashMap<>();
        settingsItem.put("id", "settings");
        settingsItem.put("name", "Settings");
        settingsItem.put("icon", "⚙️");
        settingsItem.put("url", "/admin/settings");
        settingsItem.put("roles", new String[]{"superadmin"});
        menu.add(settingsItem);

        // Profile menu item
        Map<String, Object> profileItem = new HashMap<>();
        profileItem.put("id", "profile");
        profileItem.put("name", "Profile");
        profileItem.put("icon", "👤");
        profileItem.put("url", "/admin/profile");
        profileItem.put("roles", new String[]{"admin", "superadmin"});
        menu.add(profileItem);

        return menu;
    }

    /**
     * Get dashboard widgets configuration.
     * This defines what widgets/cards appear on the dashboard.
     *
     * @return List of widget configurations
     */
    public static List<Map<String, Object>> getDashboardWidgets() {
        List<Map<String, Object>> widgets = new ArrayList<>();

        // User stats widget
        Map<String, Object> userStatsWidget = new HashMap<>();
        userStatsWidget.put("id", "user-stats");
        userStatsWidget.put("name", "User Statistics");
        userStatsWidget.put("type", "count");
        userStatsWidget.put("icon", "👥");
        userStatsWidget.put("roles", new String[]{"admin", "superadmin"});
        widgets.add(userStatsWidget);

        // Reservation stats widget
        Map<String, Object> reservationStatsWidget = new HashMap<>();
        reservationStatsWidget.put("id", "reservation-stats");
        reservationStatsWidget.put("name", "Reservation Statistics");
        reservationStatsWidget.put("type", "count");
        reservationStatsWidget.put("icon", "📅");
        reservationStatsWidget.put("roles", new String[]{"admin", "superadmin"});
        widgets.add(reservationStatsWidget);

        // Revenue stats widget
        Map<String, Object> revenueStatsWidget = new HashMap<>();
        revenueStatsWidget.put("id", "revenue-stats");
        revenueStatsWidget.put("name", "Revenue Statistics");
        revenueStatsWidget.put("type", "money");
        revenueStatsWidget.put("icon", "💰");
        revenueStatsWidget.put("roles", new String[]{"admin", "superadmin"});
        widgets.add(revenueStatsWidget);

        // Upcoming reservations widget
        Map<String, Object> upcomingReservationsWidget = new HashMap<>();
        upcomingReservationsWidget.put("id", "upcoming-reservations");
        upcomingReservationsWidget.put("name", "Upcoming Reservations");
        upcomingReservationsWidget.put("type", "list");
        upcomingReservationsWidget.put("icon", "📋");
        upcomingReservationsWidget.put("roles", new String[]{"admin", "superadmin"});
        widgets.add(upcomingReservationsWidget);

        return widgets;
    }

    /**
     * Get system settings configuration.
     * This defines what settings are available in the admin panel.
     * Only accessible to superadmin role.
     *
     * @return Map of settings categories and their options
     */
    public static Map<String, List<Map<String, Object>>> getSystemSettings() {
        Map<String, List<Map<String, Object>>> settings = new HashMap<>();

        // General settings
        List<Map<String, Object>> generalSettings = new ArrayList<>();

        Map<String, Object> restaurantName = new HashMap<>();
        restaurantName.put("id", "restaurant-name");
        restaurantName.put("name", "Restaurant Name");
        restaurantName.put("type", "text");
        restaurantName.put("default", "Gourmet Reserve");
        generalSettings.add(restaurantName);

        Map<String, Object> openingTime = new HashMap<>();
        openingTime.put("id", "opening-time");
        openingTime.put("name", "Opening Time");
        openingTime.put("type", "time");
        openingTime.put("default", "10:00");
        generalSettings.add(openingTime);

        Map<String, Object> closingTime = new HashMap<>();
        closingTime.put("id", "closing-time");
        closingTime.put("name", "Closing Time");
        closingTime.put("type", "time");
        closingTime.put("default", "22:00");
        generalSettings.add(closingTime);

        settings.put("general", generalSettings);

        // Reservation settings
        List<Map<String, Object>> reservationSettings = new ArrayList<>();

        Map<String, Object> maxDuration = new HashMap<>();
        maxDuration.put("id", "max-duration");
        maxDuration.put("name", "Maximum Reservation Duration (hours)");
        maxDuration.put("type", "number");
        maxDuration.put("default", "6");
        reservationSettings.add(maxDuration);

        Map<String, Object> minAdvanceTime = new HashMap<>();
        minAdvanceTime.put("id", "min-advance-time");
        minAdvanceTime.put("name", "Minimum Advance Reservation Time (hours)");
        minAdvanceTime.put("type", "number");
        minAdvanceTime.put("default", "1");
        reservationSettings.add(minAdvanceTime);

        Map<String, Object> maxAdvanceDays = new HashMap<>();
        maxAdvanceDays.put("id", "max-advance-days");
        maxAdvanceDays.put("name", "Maximum Advance Reservation (days)");
        maxAdvanceDays.put("type", "number");
        maxAdvanceDays.put("default", "60");
        reservationSettings.add(maxAdvanceDays);

        settings.put("reservation", reservationSettings);

        // Email settings
        List<Map<String, Object>> emailSettings = new ArrayList<>();

        Map<String, Object> smtpServer = new HashMap<>();
        smtpServer.put("id", "smtp-server");
        smtpServer.put("name", "SMTP Server");
        smtpServer.put("type", "text");
        smtpServer.put("default", "smtp.gmail.com");
        emailSettings.add(smtpServer);

        Map<String, Object> smtpPort = new HashMap<>();
        smtpPort.put("id", "smtp-port");
        smtpPort.put("name", "SMTP Port");
        smtpPort.put("type", "number");
        smtpPort.put("default", "587");
        emailSettings.add(smtpPort);

        Map<String, Object> smtpUsername = new HashMap<>();
        smtpUsername.put("id", "smtp-username");
        smtpUsername.put("name", "SMTP Username");
        smtpUsername.put("type", "text");
        smtpUsername.put("default", "");
        emailSettings.add(smtpUsername);

        Map<String, Object> smtpPassword = new HashMap<>();
        smtpPassword.put("id", "smtp-password");
        smtpPassword.put("name", "SMTP Password");
        smtpPassword.put("type", "password");
        smtpPassword.put("default", "");
        emailSettings.add(smtpPassword);

        settings.put("email", emailSettings);

        return settings;
    }
}