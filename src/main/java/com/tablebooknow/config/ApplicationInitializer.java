package com.tablebooknow.config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

@WebListener
public class ApplicationInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            // Get the real path to the WEB-INF directory
            String webInfPath = sce.getServletContext().getRealPath("/WEB-INF");

            // Set up data directory path
            String dataPath = webInfPath + File.separator + "data";

            // Ensure the directory exists
            Files.createDirectories(Paths.get(dataPath));

            // Set as a system property so it can be accessed from anywhere
            System.setProperty("app.datapath", dataPath);

            System.out.println("Data directory set to: " + dataPath);
        } catch (Exception e) {
            System.err.println("Failed to initialize data directory: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Clean up if needed
    }
}