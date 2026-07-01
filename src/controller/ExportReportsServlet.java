package controller;

import dao.ReportsDAO;

import dao.NominationDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/** Streams report data as a UTF-8 CSV download for multiple report types (appointments, examiner frequency, departments, detail, unverified nominations). */
@WebServlet({"/admin/reports/export", "/dean/reports/export"})
public class ExportReportsServlet extends HttpServlet {

    private ReportsDAO dao = new ReportsDAO();
    private NominationDAO nomDao = new NominationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String type = req.getParameter("reportType");
        boolean isDeanRoute = req.getServletPath() != null && req.getServletPath().startsWith("/dean/");
        if (type == null) {
            resp.sendRedirect(req.getContextPath() + (isDeanRoute ? "/dean/reports/appointments" : "/admin/reports/exportPage"));
            return;
        }

        // Set CSV response headers and write a UTF-8 BOM so Excel on Windows recognizes UTF-8 encoding.
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"report_" + type + ".csv\"");

        try (javax.servlet.ServletOutputStream sos = resp.getOutputStream()) {
            // UTF-8 BOM
            byte[] bom = new byte[] {(byte)0xEF, (byte)0xBB, (byte)0xBF};
            sos.write(bom);
            OutputStreamWriter osw = new OutputStreamWriter(sos, StandardCharsets.UTF_8);
            PrintWriter out = new PrintWriter(osw, true);
            // Help Excel recognise the delimiter (force comma separation)
            out.println("sep=,");
            if ("appointments_by_year".equals(type)) {
                List<Map<String,Object>> rows = dao.getAppointmentCountByYear();
                out.println("Year,Count");
                for (Map<String,Object> r : rows) out.println(r.get("year") + "," + r.get("count"));
            } else if ("examiner_frequency".equals(type)) {
                List<Map<String,Object>> rows = dao.getExaminerAppointmentFrequencyByYear();
                out.println("Year,Examiner,Count");
                for (Map<String,Object> r : rows) out.println(r.get("year") + ",\"" + csv(r.get("examiner")) + "\"," + r.get("count"));
            } else if ("department_stats".equals(type)) {
                List<Map<String,Object>> rows = dao.getDepartmentStats();
                out.println("Department,Count");
                for (Map<String,Object> r : rows) out.println("\"" + csv(r.get("department")) + "\"," + r.get("count"));
            } else if ("appointment_detail_by_year".equals(type)) {
                String yearParam = req.getParameter("year");
                int year = (yearParam != null && !yearParam.isEmpty()) ? Integer.parseInt(yearParam) : java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                List<Map<String,Object>> rows = dao.getAppointmentsByYear(year);
                out.println("Candidate,Matric No,Programme,Thesis Title,Viva Date,Status,Chairperson,Recorder,Internal Examiner,External Examiner");
                for (Map<String,Object> r : rows) {
                    out.println(
                        "\"" + csv(r.get("candidate")) + "\"," +
                        "\"" + csv(r.get("matric")) + "\"," +
                        "\"" + csv(r.get("programme")) + "\"," +
                        "\"" + csv(r.get("thesis")) + "\"," +
                        "\"" + csv(r.get("vivaDate")) + "\"," +
                        "\"" + csv(r.get("status")) + "\"," +
                        "\"" + csv(r.get("chairperson")) + "\"," +
                        "\"" + csv(r.get("recorder")) + "\"," +
                        "\"" + csv(r.get("internalExaminer")) + "\"," +
                        "\"" + csv(r.get("externalExaminer")) + "\""
                    );
                }
            } else if ("unverified_nominations".equals(type)) {
                List<Map<String,Object>> rows = nomDao.getUnverifiedNominationsReport();
                out.println("Nominated By,Date,Examiner Name,University/Affiliation,Email,Specialization,Expertise,Status");
                for (Map<String,Object> r : rows) {
                    out.println(
                        "\"" + csv(r.get("nominator")) + "\"," +
                        "\"" + csv(r.get("date")) + "\"," +
                        "\"" + csv(r.get("examiner")) + "\"," +
                        "\"" + csv(r.get("university")) + "\"," +
                        "\"" + csv(r.get("email")) + "\"," +
                        "\"" + csv(r.get("specialization")) + "\"," +
                        "\"" + csv(r.get("expertise")) + "\"," +
                        "\"" + csv(r.get("status")) + "\""
                    );
                }
            } else {
                out.println("message,Unknown report type");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Escape a value for CSV output — replace nulls and escape double-quotes. */
    private static String csv(Object v) {
        if (v == null) return "";
        String s = v.toString().replaceAll("[\\r\\n]+", " ").trim();
        return s.replace("\"", "\"\"");
    }
}
