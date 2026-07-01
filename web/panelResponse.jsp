<%--
  Public (no-login) page for external examiners to Accept or Decline a panel appointment.
  Access is controlled by a one-time response token from the appointment email.
--%>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String tokenStatus = (String) request.getAttribute("tokenStatus");
  Map<String,Object> detail = (Map<String,Object>) request.getAttribute("panelDetail");
  String token       = (String) request.getAttribute("token");
  String flashResult = (String) request.getAttribute("flashResult");
  String reasonError = (String) request.getAttribute("reasonError");
  boolean bankFieldsError = "missing_fields".equals(request.getParameter("bankError"));
  if (tokenStatus == null) tokenStatus = "invalid";

  // Extract panel/appointment info for display
  String eeName      = "";
  String eeTitle     = "";
  String candidate   = "";
  String program     = "";
  String thesis      = "";
  String vivaDate    = "";
  String venue       = "";
  String panelResp   = "";
  String rejectReason = "";
  java.sql.Timestamp bankProvidedAt = null;
  String bankAccountName = "";
  String bankAccountNumber = "";
  String bankName = "";
  String bankIban = "";
  String bankSwift = "";
  String bankCountry = "";

  if (detail != null) {
    eeName      = detail.get("ee_name")         != null ? detail.get("ee_name").toString()         : "";
    eeTitle     = detail.get("ee_title")         != null ? detail.get("ee_title").toString()        : "";
    candidate   = detail.get("candidate_name")   != null ? detail.get("candidate_name").toString()  : "";
    program     = detail.get("candidate_program")!= null ? detail.get("candidate_program").toString(): "";
    thesis      = detail.get("thesis_title")     != null ? detail.get("thesis_title").toString()    : "";
    panelResp   = detail.get("panel_response")   != null ? detail.get("panel_response").toString()  : "";
    rejectReason= detail.get("rejection_reason") != null ? detail.get("rejection_reason").toString() : "";
    bankAccountName   = detail.get("bank_account_name")   != null ? detail.get("bank_account_name").toString() : "";
    bankAccountNumber = detail.get("bank_account_number") != null ? detail.get("bank_account_number").toString() : "";
    bankName          = detail.get("bank_name")           != null ? detail.get("bank_name").toString() : "";
    bankIban          = detail.get("bank_iban")           != null ? detail.get("bank_iban").toString() : "";
    bankSwift         = detail.get("bank_swift")          != null ? detail.get("bank_swift").toString() : "";
    bankCountry       = detail.get("bank_country")        != null ? detail.get("bank_country").toString() : "";
    bankProvidedAt    = detail.get("bank_provided_at")    != null ? (java.sql.Timestamp) detail.get("bank_provided_at") : null;
    java.sql.Timestamp ts = (java.sql.Timestamp) detail.get("scheduled_at");
    if (ts != null) vivaDate = new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(ts);
    venue = detail.get("venue") != null ? detail.get("venue").toString() : "";
  }
  String displayName = (eeTitle != null && !eeTitle.isEmpty()) ? eeTitle + " " + eeName : eeName;

  // Determine which panel_response to show on result screen
  String effectiveResult = flashResult != null ? flashResult : panelResp;
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Appointment Response — E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    *, *::before, *::after { box-sizing: border-box; }
    body {
      background: linear-gradient(150deg, #ecfdf5 0%, #e0f2fe 55%, #f3f4f6 100%);
      font-family: 'Segoe UI', Arial, sans-serif;
      min-height: 100vh;
    }
    .page-wrap { max-width: 640px; margin: 0 auto; padding: 36px 16px 64px; }

    /* ── Brand header ── */
    .brand-header {
      background: linear-gradient(135deg, #0d5254 0%, #0f766e 100%);
      color: #fff;
      border-radius: 16px 16px 0 0;
      padding: 22px 32px;
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .brand-logo {
      width: 46px; height: 46px; flex-shrink: 0;
      background: rgba(255,255,255,0.15);
      border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.5rem;
    }
    .brand-header h1 { margin: 0; font-size: 1.1rem; font-weight: 700; line-height: 1.3; }
    .brand-header p  { margin: 3px 0 0; font-size: 0.79rem; color: #a7f3d0; line-height: 1.4; }

    /* ── Card body ── */
    .card-body {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-top: none;
      border-radius: 0 0 16px 16px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.07);
      padding: 30px 36px 36px;
    }

    /* ── Info table ── */
    .info-table { width: 100%; border-collapse: collapse; }
    .info-table td { padding: 5px 0; font-size: 0.92rem; vertical-align: top; line-height: 1.5; }
    .info-table td:first-child { font-weight: 600; color: #4b5563; width: 42%; padding-right: 10px; }
    .info-table td:last-child  { color: #111827; }

    /* ── Section label ── */
    .section-label {
      font-size: 0.67rem; font-weight: 700; text-transform: uppercase;
      letter-spacing: .1em; color: #6b7280; display: block; margin-bottom: 10px;
    }

    /* ── Detail / info card ── */
    .detail-card {
      background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 12px; padding: 18px 20px;
    }

    /* ── Result boxes ── */
    .result-box { border-radius: 14px; padding: 28px 24px; text-align: center; margin-bottom: 22px; }
    .result-accepted { background: linear-gradient(135deg, #f0fdf4, #dcfce7); border: 1px solid #86efac; }
    .result-declined { background: linear-gradient(135deg, #fff1f2, #fee2e2); border: 1px solid #fca5a5; }
    .result-icon { font-size: 3rem; display: block; margin-bottom: 10px; line-height: 1; }

    /* ── Action buttons ── */
    .btn-accept {
      display: block; width: 100%;
      background: linear-gradient(135deg, #0f766e, #0d6560);
      color: #fff; border: none; font-weight: 700; font-size: 1rem;
      padding: 13px 28px; border-radius: 10px; cursor: pointer;
      transition: box-shadow .15s, transform .1s;
      letter-spacing: .01em; text-decoration: none; text-align: center;
    }
    .btn-accept:hover { box-shadow: 0 4px 14px rgba(15,118,110,0.35); transform: translateY(-1px); color: #fff; }
    .btn-decline {
      display: block; width: 100%;
      background: #fff; color: #b91c1c;
      border: 1.5px solid #fca5a5; font-weight: 700; font-size: 1rem;
      padding: 12px 28px; border-radius: 10px; cursor: pointer;
      transition: background .12s, border-color .12s;
    }
    .btn-decline:hover { background: #fef2f2; border-color: #f87171; }

    /* ── Bank details form ── */
    .bank-card {
      background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 12px; padding: 22px 24px;
    }
    .bank-card-header {
      display: flex; align-items: center; gap: 12px; margin-bottom: 16px;
    }
    .bank-card-icon {
      width: 38px; height: 38px; flex-shrink: 0;
      border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem;
    }
    .bank-card-icon.pending { background: #d1fae5; color: #059669; }
    .bank-card-icon.done    { background: #bbf7d0; color: #16a34a; }
    .bank-form-grid {
      display: grid; grid-template-columns: 1fr 1fr; gap: 14px;
    }
    .bank-form-grid .full-width { grid-column: 1 / -1; }
    .field-label {
      font-size: 0.83rem; font-weight: 600; color: #374151;
      display: block; margin-bottom: 5px;
    }
    .req-star { color: #dc2626; margin-left: 2px; }
    .opt-tag  { font-size: 0.73rem; color: #9ca3af; font-weight: 400; margin-left: 4px; }
    .field-input {
      width: 100%; border: 1.5px solid #e5e7eb; border-radius: 8px;
      padding: 9px 12px; font-size: 0.91rem; color: #111827;
      outline: none; transition: border-color .15s, box-shadow .15s;
      background: #fff;
    }
    .field-input:focus { border-color: #0f766e; box-shadow: 0 0 0 3px rgba(15,118,110,0.1); }
    .field-input.is-invalid { border-color: #dc2626; box-shadow: 0 0 0 3px rgba(220,38,38,0.08); }
    .bank-success-card {
      background: linear-gradient(135deg, #f0fdf4, #ecfdf5);
      border: 1px solid #bbf7d0; border-radius: 12px; padding: 18px 20px;
    }

    /* ── Decline section ── */
    #declineSection { display: none; }
    .decline-inner {
      background: #fff5f5; border: 1px solid #fecaca; border-radius: 12px; padding: 18px 20px;
    }
    textarea.field-input { resize: vertical; min-height: 100px; }

    /* ── Error alert ── */
    .alert-err {
      background: #fef2f2; border: 1px solid #fca5a5; border-radius: 8px;
      padding: 10px 14px; font-size: 0.87rem; color: #b91c1c; margin-bottom: 16px;
      display: flex; align-items: center; gap: 8px;
    }

    /* ── Footer ── */
    .page-footer { font-size: 0.77rem; color: #9ca3af; text-align: center; line-height: 1.7; }
    .page-footer a { color: #0f766e; }

    @media (max-width: 480px) {
      .card-body { padding: 22px 20px 28px; }
      .brand-header { padding: 18px 20px; }
      .bank-form-grid { grid-template-columns: 1fr; }
      .bank-form-grid .full-width { grid-column: 1; }
    }
  </style>
</head>
<body>
<div class="page-wrap">

  <%-- ── Brand header ── --%>
  <div class="brand-header">
    <div class="brand-logo"><i class="bi bi-mortarboard-fill"></i></div>
    <div>
      <h1>E-Appointment FSKM</h1>
      <p>Faculty of Computer and Mathematical Sciences &bull; Universiti Malaysia Terengganu</p>
    </div>
  </div>

  <div class="card-body">

  <%-- ══ INVALID TOKEN ══ --%>
  <% if ("invalid".equals(tokenStatus)) { %>

    <div style="text-align:center;padding:32px 0 20px;">
      <div style="width:68px;height:68px;background:#fef3c7;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:18px;">
        <i class="bi bi-shield-exclamation" style="font-size:2rem;color:#d97706;"></i>
      </div>
      <h2 style="font-size:1.2rem;font-weight:700;color:#111827;margin:0 0 10px;">Invalid or Expired Link</h2>
      <p style="color:#6b7280;font-size:0.93rem;max-width:360px;margin:0 auto 22px;">This response link is invalid or has already expired. Please contact the faculty administrator if you believe this is an error.</p>
      <a href="mailto:fskm@umt.edu.my" class="btn-accept" style="display:inline-block;width:auto;padding:11px 26px;font-size:0.92rem;">
        <i class="bi bi-envelope me-2"></i>Contact Administrator
      </a>
    </div>

  <%-- ══ ALREADY RESPONDED / RESULT SCREEN ══ --%>
  <% } else if ("already_responded".equals(tokenStatus) || "accepted".equals(effectiveResult) || "declined".equals(effectiveResult)) {
       boolean wasAccepted = "accepted".equals(panelResp) || "accepted".equals(effectiveResult); %>

    <div class="result-box <%= wasAccepted ? "result-accepted" : "result-declined" %>">
      <span class="result-icon"><%= wasAccepted ? "✅" : "❌" %></span>
      <h2 style="font-size:1.2rem;font-weight:700;color:<%= wasAccepted ? "#15803d" : "#b91c1c" %>;margin:0 0 6px;">
        <%= wasAccepted ? "Appointment Accepted" : "Appointment Declined" %>
      </h2>
      <p style="margin:0;color:<%= wasAccepted ? "#166534" : "#991b1b" %>;font-size:0.91rem;line-height:1.5;">
        <%= wasAccepted
            ? "Thank you for accepting this appointment. The faculty administrator has been notified."
            : "Your response has been recorded. The faculty administrator has been notified." %>
      </p>
    </div>

    <% if (!wasAccepted && !rejectReason.isEmpty()) { %>
    <div class="detail-card mb-4">
      <span class="section-label">Reason Provided</span>
      <p style="margin:0;color:#374151;font-size:0.92rem;line-height:1.6;"><%= rejectReason.replace("<","&lt;").replace(">","&gt;") %></p>
    </div>
    <% } %>

    <div class="detail-card mb-4">
      <span class="section-label">Appointment Details</span>
      <table class="info-table">
        <tr><td>Candidate</td><td>: <%= candidate.replace("<","&lt;") %></td></tr>
        <tr><td>Programme</td><td>: <%= program.replace("<","&lt;") %></td></tr>
        <% if (!thesis.isEmpty()) { %><tr><td>Thesis Title</td><td>: <%= thesis.replace("<","&lt;") %></td></tr><% } %>
        <% if (!vivaDate.isEmpty()) { %><tr><td>Viva Date &amp; Time</td><td>: <%= vivaDate %></td></tr><% } %>
        <% if (!venue.isEmpty()) { %><tr><td>Venue</td><td>: <%= venue.replace("<","&lt;") %></td></tr><% } %>
      </table>
    </div>

    <% if (wasAccepted) { %>
      <% if (bankProvidedAt == null) { %>
      <%-- ── Bank details still needed ── --%>
      <div class="bank-card mb-4">
        <div class="bank-card-header">
          <span class="bank-card-icon pending"><i class="bi bi-bank"></i></span>
          <div>
            <span class="section-label" style="margin-bottom:2px;">Bank Details for Honorarium Payment</span>
            <p style="margin:0;font-size:0.81rem;color:#6b7280;">Fields marked <span style="color:#dc2626;">*</span> are required to process your payment.</p>
          </div>
        </div>
        <hr style="border:none;border-top:1px solid #e5e7eb;margin:0 0 18px;">
        <form method="POST" action="<%= request.getContextPath() %>/PanelBankDetailsServlet?token=<%= token %>" id="bankForm" onsubmit="return validateBankForm()">
          <div class="bank-form-grid">

            <div class="full-width">
              <label class="field-label">Account Holder Name <span class="req-star">*</span></label>
              <input type="text" name="bank_account_name" id="f_acct_name" class="field-input"
                     placeholder="Full name as printed on the bank account"
                     value="<%= bankAccountName.replace("\"","&quot;") %>">
            </div>

            <div>
              <label class="field-label">Account Number <span class="req-star">*</span></label>
              <input type="text" name="bank_account_number" id="f_acct_num" class="field-input"
                     placeholder="e.g. 1234567890"
                     value="<%= bankAccountNumber.replace("\"","&quot;") %>">
            </div>

            <div>
              <label class="field-label">Bank Name <span class="req-star">*</span></label>
              <input type="text" name="bank_name" id="f_bank_name" class="field-input"
                     placeholder="e.g. Maybank, CIMB"
                     value="<%= bankName.replace("\"","&quot;") %>">
            </div>

            <div>
              <label class="field-label">Country <span class="req-star">*</span></label>
              <input type="text" name="bank_country" id="f_country" class="field-input"
                     placeholder="e.g. Malaysia"
                     value="<%= bankCountry.replace("\"","&quot;") %>">
            </div>

            <div>
              <label class="field-label">IBAN <span class="opt-tag">(optional)</span></label>
              <input type="text" name="bank_iban" class="field-input"
                     placeholder="For international transfers"
                     value="<%= bankIban.replace("\"","&quot;") %>">
            </div>

            <div>
              <label class="field-label">SWIFT / BIC <span class="opt-tag">(optional)</span></label>
              <input type="text" name="bank_swift" class="field-input"
                     placeholder="e.g. MBBEMYKL"
                     value="<%= bankSwift.replace("\"","&quot;") %>">
            </div>

          </div>

          <div id="bankFormError" class="alert-err mt-3" style="<%= bankFieldsError ? "" : "display:none;" %>">
            <i class="bi bi-exclamation-triangle-fill" style="flex-shrink:0;"></i>
            Please fill in all required fields (Account Name, Account Number, Bank Name, Country) before submitting.
          </div>

          <div style="margin-top:20px;">
            <button type="submit" class="btn-accept">
              <i class="bi bi-floppy-fill me-2"></i>Save Bank Details
            </button>
          </div>
          <p style="font-size:0.77rem;color:#9ca3af;text-align:center;margin:10px 0 0;">
            <i class="bi bi-lock-fill me-1"></i>Your details are stored securely and used solely for honorarium processing.
          </p>
        </form>
      </div>
      <% } else { %>
      <%-- ── Bank details already submitted ── --%>
      <div class="bank-success-card mb-4">
        <div class="bank-card-header" style="margin-bottom:12px;">
          <span class="bank-card-icon done"><i class="bi bi-check-circle-fill"></i></span>
          <div>
            <span class="section-label" style="margin-bottom:2px;">Bank Details Received</span>
            <p style="margin:0;font-size:0.81rem;color:#166534;">Your bank details have been successfully recorded.</p>
          </div>
        </div>
        <hr style="border:none;border-top:1px solid #bbf7d0;margin:0 0 14px;">
        <table class="info-table">
          <tr><td>Account Name</td><td>: <strong><%= bankAccountName.replace("<","&lt;").replace(">","&gt;") %></strong></td></tr>
          <tr><td>Account Number</td><td>: <strong><%= bankAccountNumber.replace("<","&lt;").replace(">","&gt;") %></strong></td></tr>
          <tr><td>Bank</td><td>: <%= bankName.replace("<","&lt;").replace(">","&gt;") %></td></tr>
          <% if (!bankCountry.isEmpty()) { %><tr><td>Country</td><td>: <%= bankCountry.replace("<","&lt;").replace(">","&gt;") %></td></tr><% } %>
        </table>
      </div>
      <% } %>
    <% } %>

  <%-- ══ PENDING: SHOW RESPONSE FORM ══ --%>
  <% } else { %>

    <div style="margin-bottom:22px;">
      <p style="font-size:0.96rem;color:#374151;margin:0 0 6px;">Dear <strong><%= displayName.replace("<","&lt;") %></strong>,</p>
      <p style="font-size:0.92rem;color:#6b7280;margin:0;line-height:1.6;">
        You have been appointed as an <strong style="color:#374151;">External Examiner</strong> for the viva voce examination listed below.
        Please review the details carefully and confirm your response.
      </p>
    </div>

    <div class="detail-card mb-4">
      <span class="section-label">Appointment Details</span>
      <table class="info-table">
        <tr><td>Candidate</td><td>: <%= candidate.replace("<","&lt;") %></td></tr>
        <tr><td>Programme</td><td>: <%= program.replace("<","&lt;") %></td></tr>
        <% if (!thesis.isEmpty()) { %><tr><td>Thesis Title</td><td>: <%= thesis.replace("<","&lt;") %></td></tr><% } %>
        <% if (!vivaDate.isEmpty()) { %><tr><td>Viva Date &amp; Time</td><td>: <%= vivaDate %></td></tr><% } %>
        <% if (!venue.isEmpty()) { %><tr><td>Venue</td><td>: <%= venue.replace("<","&lt;") %></td></tr><% } %>
      </table>
    </div>

    <% if (reasonError != null && !reasonError.isEmpty()) { %>
    <div class="alert-err">
      <i class="bi bi-exclamation-triangle-fill" style="flex-shrink:0;"></i><%= reasonError %>
    </div>
    <% } %>

    <span class="section-label">Your Response</span>
    <p style="font-size:0.87rem;color:#6b7280;margin:0 0 18px;line-height:1.5;">
      Please confirm within <strong>7 working days</strong> of receiving this appointment letter.
      If you accept, you will be asked to provide bank details for honorarium processing.
    </p>

    <%-- Accept form --%>
    <form method="POST" action="<%= request.getContextPath() %>/PanelResponseServlet?token=<%= token %>"
          onsubmit="return confirm('Confirm acceptance of this viva appointment?');" style="margin-bottom:12px;">
      <input type="hidden" name="action" value="accept">
      <button type="submit" class="btn-accept">
        <i class="bi bi-check-circle-fill me-2"></i>Accept this Appointment
      </button>
    </form>

    <%-- Decline toggle --%>
    <button type="button" class="btn-decline" onclick="toggleDecline()">
      <i class="bi bi-x-circle me-2"></i>Decline this Appointment
    </button>

    <div id="declineSection" style="margin-top:14px;">
      <div class="decline-inner">
        <p style="font-size:0.88rem;color:#7f1d1d;margin:0 0 12px;">
          <i class="bi bi-info-circle me-1"></i>
          Please provide a reason — this helps the faculty team follow up appropriately.
        </p>
        <form method="POST" action="<%= request.getContextPath() %>/PanelResponseServlet?token=<%= token %>"
              onsubmit="return confirmDecline();">
          <input type="hidden" name="action" value="decline">
          <label for="rejectionReason" class="field-label">
            Reason for Declining <span class="req-star">*</span>
          </label>
          <textarea id="rejectionReason" name="rejection_reason" class="field-input mb-3"
                    placeholder="e.g. scheduling conflict, area of expertise does not match..."
                    maxlength="2000" style="margin-bottom:12px;display:block;"></textarea>
          <button type="submit"
                  style="width:100%;background:#dc2626;color:#fff;border:none;font-weight:700;font-size:0.94rem;padding:12px 24px;border-radius:9px;cursor:pointer;transition:background .12s;">
            <i class="bi bi-x-circle me-2"></i>Submit Decline
          </button>
        </form>
      </div>
    </div>

  <% } %>

  <hr style="border:none;border-top:1px solid #f3f4f6;margin:28px 0 16px;">
  <p class="page-footer">
    This is a secure link sent specifically to you by E-Appointment FSKM.<br>
    If you did not expect this, please ignore it or contact
    <a href="mailto:fskm@umt.edu.my">fskm@umt.edu.my</a>.
  </p>
  </div><%-- end card-body --%>
</div><%-- end page-wrap --%>

<script>
  function toggleDecline() {
    var sec = document.getElementById('declineSection');
    sec.style.display = sec.style.display === 'none' || sec.style.display === '' ? 'block' : 'none';
  }

  function confirmDecline() {
    var r = document.getElementById('rejectionReason');
    if (!r || r.value.trim() === '') {
      alert('Please provide a reason for declining before submitting.');
      return false;
    }
    return confirm('Confirm declining this appointment?\n\nThe faculty administrator will be notified.');
  }

  function validateBankForm() {
    var required = [
      { id: 'f_acct_name',  label: 'Account Holder Name' },
      { id: 'f_acct_num',   label: 'Account Number' },
      { id: 'f_bank_name',  label: 'Bank Name' },
      { id: 'f_country',    label: 'Country' }
    ];
    var hasError = false;
    required.forEach(function(f) {
      var el = document.getElementById(f.id);
      if (el && !el.value.trim()) {
        el.classList.add('is-invalid');
        hasError = true;
      } else if (el) {
        el.classList.remove('is-invalid');
      }
    });
    var errBox = document.getElementById('bankFormError');
    errBox.style.display = hasError ? 'flex' : 'none';
    return !hasError;
  }

  // Clear invalid state on input
  document.querySelectorAll('.field-input').forEach(function(el) {
    el.addEventListener('input', function() { this.classList.remove('is-invalid'); });
  });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
