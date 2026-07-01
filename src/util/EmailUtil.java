package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.io.UnsupportedEncodingException;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

/**
 * Sends outbound SMTP emails (plain-text and HTML) for appointment letters and notifications.
 *
 * Setup:
 *  1. Place javax.mail.jar in WEB-INF/lib/
 *  2. Configure SMTP settings via environment variables:
 *     SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM_NAME.
 *     For Gmail: use an App Password (Google Account → Security → App passwords).
 *     For other SMTP: update SMTP_HOST and SMTP_PORT accordingly.
 */
public class EmailUtil {

    // ─── SMTP Configuration ───────────────────────────────────────────────────
    private static final String SMTP_HOST = getenv("SMTP_HOST", "smtp.gmail.com");
    private static final int    SMTP_PORT = getenvInt("SMTP_PORT", 587);          // TLS port
    private static final String SMTP_USER = getenv("SMTP_USER", "eappointmentfskm@gmail.com");   // sender Gmail account
    private static final String SMTP_PASS = getenv("SMTP_PASS", "");
    private static final String FROM_NAME = getenv("SMTP_FROM_NAME", "E-Appointment FSKM");
    // ──────────────────────────────────────────────────────────────────────────

    private static String getenv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isEmpty()) ? defaultValue : value;
    }

    private static int getenvInt(String name, int defaultValue) {
        String value = System.getenv(name);
        if (value == null || value.isEmpty()) return defaultValue;
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private static final Logger log = Logger.getLogger(EmailUtil.class.getName());

    /** Single-threaded queue for async email delivery — sequential sends avoid Gmail's concurrent-connection throttle. */
    private static final ExecutorService EMAIL_EXECUTOR =
        Executors.newSingleThreadExecutor(r -> {
            Thread t = new Thread(r, "email-sender");
            t.setDaemon(true);
            return t;
        });

    /**
     * Send a plain-text email synchronously.
     */
    public static void sendEmail(String toEmail, String subject, String body)
            throws MessagingException, UnsupportedEncodingException {
        doSend(toEmail, subject, body, false, null);
    }

    /**
     * Send an HTML email synchronously (no inline image).
     */
    public static void sendHtmlEmail(String toEmail, String subject, String htmlBody)
            throws MessagingException, UnsupportedEncodingException {
        doSend(toEmail, subject, htmlBody, true, null);
    }

    /**
     * Send an HTML email synchronously with an inline CID image (e.g. signature).
     * The HTML body should reference the image as {@code <img src="cid:signature">}.
     */
    public static void sendHtmlEmail(String toEmail, String subject, String htmlBody, java.io.File sigFile)
            throws MessagingException, UnsupportedEncodingException {
        doSend(toEmail, subject, htmlBody, true, sigFile);
    }

    /**
     * Send an HTML email asynchronously — returns immediately so the HTTP request thread
     * is not blocked by the SMTP round-trip (typically 3–6 s).
     * Delivery errors are logged but not propagated to the caller.
     */
    public static void sendHtmlEmailAsync(String toEmail, String subject, String htmlBody) {
        EMAIL_EXECUTOR.submit(() -> {
            try {
                doSend(toEmail, subject, htmlBody, true, null);
            } catch (Exception e) {
                log.warning("Async email to " + toEmail + " failed: " + e.getMessage());
            }
        });
    }

    /** Async variant that includes an inline CID signature image. */
    public static void sendHtmlEmailAsync(String toEmail, String subject, String htmlBody, java.io.File sigFile) {
        EMAIL_EXECUTOR.submit(() -> {
            try {
                doSend(toEmail, subject, htmlBody, true, sigFile);
            } catch (Exception e) {
                log.warning("Async email to " + toEmail + " failed: " + e.getMessage());
            }
        });
    }

    /**
     * Send a plain-text email asynchronously.
     */
    public static void sendEmailAsync(String toEmail, String subject, String body) {
        EMAIL_EXECUTOR.submit(() -> {
            try {
                doSend(toEmail, subject, body, false, null);
            } catch (Exception e) {
                log.warning("Async email to " + toEmail + " failed: " + e.getMessage());
            }
        });
    }

    private static void doSend(String toEmail, String subject, String body, boolean isHtml, java.io.File sigFile)
            throws MessagingException, UnsupportedEncodingException {

        Properties props = new Properties();
        props.put("mail.smtp.auth",              "true");
        props.put("mail.smtp.starttls.enable",   "true");
        props.put("mail.smtp.host",              SMTP_HOST);
        props.put("mail.smtp.port",              String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.trust",         SMTP_HOST);
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout",           "8000");
        props.put("mail.smtp.writetimeout",      "8000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER, FROM_NAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);

        if (isHtml) {
            // Plain-text fallback
            String plain = body
                .replaceAll("(?i)<br\\s*/?>", "\n")
                .replaceAll("(?i)<p[^>]*>", "\n")
                .replaceAll("(?i)<tr[^>]*>", "\n")
                .replaceAll("(?i)<td[^>]*>", " ")
                .replaceAll("<[^>]+>", "")
                .replaceAll("&amp;", "&").replaceAll("&lt;", "<").replaceAll("&gt;", ">")
                .replaceAll("&mdash;", "-").replaceAll("&nbsp;", " ").replaceAll("&rarr;", "->")
                .replaceAll("[ \\t]{2,}", " ").replaceAll("\\n{3,}", "\n\n").trim();

            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setText(plain, "UTF-8");
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(body, "text/html; charset=UTF-8");

            MimeMultipart alternative = new MimeMultipart("alternative");
            alternative.addBodyPart(textPart);
            alternative.addBodyPart(htmlPart);

            if (sigFile != null && sigFile.exists()) {
                // Wrap alternative + CID image in multipart/related — no base64, not a spam trigger
                MimeBodyPart altWrapper = new MimeBodyPart();
                altWrapper.setContent(alternative);

                String fn  = sigFile.getName();
                String ext = fn.contains(".") ? fn.substring(fn.lastIndexOf('.') + 1).toLowerCase() : "png";
                String mime = "jpg".equals(ext) || "jpeg".equals(ext) ? "image/jpeg" : "image/png";

                MimeBodyPart imgPart = new MimeBodyPart();
                imgPart.setDataHandler(new javax.activation.DataHandler(new javax.activation.FileDataSource(sigFile)));
                imgPart.setContentID("<signature>");
                imgPart.setDisposition(MimeBodyPart.INLINE);
                imgPart.setHeader("Content-Type", mime + "; name=\"" + fn + "\"");

                MimeMultipart related = new MimeMultipart("related");
                related.addBodyPart(altWrapper);
                related.addBodyPart(imgPart);
                message.setContent(related);
            } else {
                message.setContent(alternative);
            }
        } else {
            message.setText(body);
        }

        Transport.send(message);
    }
}
