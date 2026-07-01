package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.sql.*;

/**
 * Streams an uploaded nomination document to the browser.
 * GET /DownloadDocumentServlet?id=<docId>
 *
 * Files are stored outside the webapps directory so they survive Tomcat redeployment.
 * Falls back to the webapp root for any files uploaded before this fix was applied.
 */
@WebServlet(name = "DownloadDocumentServlet", urlPatterns = {"/DownloadDocumentServlet"})
public class DownloadDocumentServlet extends HttpServlet {

    /** Persistent upload root — survives redeployment because it is outside webapps/. */
    public static final String UPLOAD_BASE =
            System.getProperty("user.home") + File.separator + ".e-appointment-uploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return; }

        int docId;
        try { docId = Integer.parseInt(idStr); }
        catch (NumberFormatException e) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return; }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT filename, filepath FROM document WHERE id = ? LIMIT 1")) {
            ps.setInt(1, docId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

                String filename = rs.getString("filename");   // original name shown to user
                String filepath = rs.getString("filepath");   // "uploads/nominations/12345_file.pdf"

                // Resolve file: check persistent external dir first, then legacy webapp location
                File f = new File(UPLOAD_BASE, filepath.replace("/", File.separator));
                if (!f.exists()) {
                    f = new File(getServletContext().getRealPath(""),
                                 filepath.replace("/", File.separator));
                }
                if (!f.exists() || !f.isFile()) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                String lower = filename.toLowerCase();
                String mime  = lower.endsWith(".pdf")  ? "application/pdf"
                             : lower.endsWith(".doc")  ? "application/msword"
                             : lower.endsWith(".docx") ? "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                             : lower.endsWith(".jpg") || lower.endsWith(".jpeg") ? "image/jpeg"
                             : lower.endsWith(".png")  ? "image/png"
                             : "application/octet-stream";

                resp.setContentType(mime);
                resp.setHeader("Content-Disposition",
                        "attachment; filename=\"" + filename.replace("\"", "'") + "\"");
                resp.setContentLengthLong(f.length());

                try (FileInputStream fis = new FileInputStream(f)) {
                    byte[] buf = new byte[8192];
                    int read;
                    while ((read = fis.read(buf)) != -1) {
                        resp.getOutputStream().write(buf, 0, read);
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
