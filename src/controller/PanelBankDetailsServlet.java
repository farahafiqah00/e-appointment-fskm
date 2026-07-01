package controller;

import dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Accepts the external examiner's bank details after they have accepted the panel appointment (token-authenticated, no login required). */
@WebServlet(name = "PanelBankDetailsServlet", urlPatterns = {"/PanelBankDetailsServlet"})
public class PanelBankDetailsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet");
            return;
        }

        String accountName = req.getParameter("bank_account_name");
        String accountNumber = req.getParameter("bank_account_number");
        String bankName = req.getParameter("bank_name");
        String iban = req.getParameter("bank_iban");
        String swift = req.getParameter("bank_swift");
        String country = req.getParameter("bank_country");

        try {
            AppointmentDAO dao = new AppointmentDAO();
            // Ensure token exists and panel has accepted
            java.util.Map<String,Object> detail = dao.getPanelDetailByResponseToken(token);
            if (detail == null) {
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token);
                return;
            }
            String existing = detail.get("panel_response") != null ? detail.get("panel_response").toString() : null;
            if (!"accepted".equals(existing)) {
                // Only allow bank details when accepted
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token);
                return;
            }

            boolean missing = isEmpty(accountName) || isEmpty(accountNumber) || isEmpty(bankName) || isEmpty(country);
            if (missing) {
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token + "&bankError=missing_fields");
                return;
            }
            dao.savePanelBankDetailsByToken(token, accountName, accountNumber, bankName, iban, swift, country);

            resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token + "&result=accepted");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }
}
