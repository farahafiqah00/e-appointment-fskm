package listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.TimeZone;

/**
 * Sets the JVM default timezone to Asia/Kuala_Lumpur at application startup.
 * This ensures every SimpleDateFormat call (which defaults to JVM timezone) displays Malaysian time.
 */
@WebListener
public class TimezoneConfig implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Kuala_Lumpur"));
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}
