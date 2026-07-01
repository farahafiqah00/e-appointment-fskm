package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Provides a static factory method to obtain a JDBC connection to the MySQL database. */
public class DBConnection {
    private static final String RAW_URL = getenv("DB_URL", "jdbc:mysql://localhost:3306/eappointment?useSSL=false&serverTimezone=Asia/Kuala_Lumpur");
    private static final String URL;
    private static final String USER;
    private static final String PASS;

    // Registers the MySQL JDBC driver once at class-load time.
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL driver not found", e);
        }

        if (RAW_URL.startsWith("jdbc:")) {
            URL = RAW_URL;
            USER = getenv("DB_USER", "root");
            PASS = getenv("DB_PASS", "");
        } else {
            // Kerocket injects DB_URL as "mysql://user:pass@host:port/dbname" instead of a JDBC URL.
            String withoutScheme = RAW_URL.substring(RAW_URL.indexOf("://") + 3);
            String hostPart = withoutScheme;
            String user = getenv("DB_USER", "root");
            String pass = getenv("DB_PASS", "");
            int atIdx = withoutScheme.indexOf('@');
            if (atIdx != -1) {
                String userInfo = withoutScheme.substring(0, atIdx);
                hostPart = withoutScheme.substring(atIdx + 1);
                int colonIdx = userInfo.indexOf(':');
                user = colonIdx != -1 ? userInfo.substring(0, colonIdx) : userInfo;
                pass = colonIdx != -1 ? userInfo.substring(colonIdx + 1) : "";
            }
            USER = user;
            PASS = pass;
            String separator = hostPart.contains("?") ? "&" : "?";
            URL = "jdbc:mysql://" + hostPart + separator + "useSSL=false&serverTimezone=Asia/Kuala_Lumpur";
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
