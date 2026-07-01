package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Provides a static factory method to obtain a JDBC connection to the MySQL database. */
public class DBConnection {
    private static final String URL = getenv("DB_URL", "jdbc:mysql://localhost:3306/eappointment?useSSL=false&serverTimezone=Asia/Kuala_Lumpur");
    private static final String USER = getenv("DB_USER", "root");
    private static final String PASS = getenv("DB_PASS", "");

    // Registers the MySQL JDBC driver once at class-load time.
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL driver not found", e);
        }
    }

    private static String getenv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isEmpty()) ? defaultValue : value;
    }

    /** Opens and returns a new JDBC connection. Caller is responsible for closing it. */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
