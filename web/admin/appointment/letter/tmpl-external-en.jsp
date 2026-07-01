<%-- Letter template fragment: External examiner appointment letter in English. Included by letterPreview.jsp for admin preview and printing. --%>
<%@ page pageEncoding="UTF-8" %>
<% today = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date()); %>
<div class="letter-paper">
<%@ include file="_lh-header.jsp" %>

  <!-- ─── Header ─────────────────────────────────────── -->
  <div style="text-align:right;margin-bottom:1.5rem;">
    <div><strong>Our Reference</strong> : UMT/FSKM/1-8/5/1</div>
    <div><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%= today %></div>
  </div>

  <!-- ─── Recipient ───────────────────────────────────── -->
  <div style="margin-bottom:1.5rem;">
    <div><strong><%= name %></strong></div>
    <% if (!miAffiliation.isEmpty()) { %><div><%= miAffiliation %></div><% } %>
    <% if (!miCountry.isEmpty()) { %><div><%= miCountry %></div><% } %>
  </div>

  <p>Dear <%= salutation %>,</p>

  <p style="text-decoration:underline;font-weight:bold;">APPOINTMENT AS <%= degreeLabelEN.toUpperCase() %> (BY RESEARCH) THESIS EXAMINER</p>

  <table style="width:100%;margin-bottom:1.5rem;border-collapse:collapse;">
    <tr>
      <td style="width:32%;padding:3px 0;font-weight:bold;vertical-align:top;">STUDENT NAME</td>
      <td style="vertical-align:top;padding:3px 0;">
        :&nbsp;<strong><%= a.getCandidateName() != null ? a.getCandidateName().toUpperCase() : "—" %>
        <% if (a.getCandidateStudentId() != null) { %>(<%= a.getCandidateStudentId() %>)<% } %></strong>
      </td>
    </tr>
    <tr>
      <td style="padding:3px 0;font-weight:bold;vertical-align:top;">PROGRAMME</td>
      <td style="vertical-align:top;padding:3px 0;">:&nbsp;<strong><%= (candidateProgram != null && !candidateProgram.isEmpty() ? candidateProgram : degreeLabelEN).toUpperCase() %></strong></td>
    </tr>
    <tr>
      <td style="padding:3px 0;font-weight:bold;vertical-align:top;">THESIS TITLE</td>
      <td style="vertical-align:top;padding:3px 0;">:&nbsp;<strong><%= a.getThesisTitle() != null ? a.getThesisTitle().toUpperCase() : "—" %></strong></td>
    </tr>
  </table>

  <p style="text-align:justify;">Refering to the above matter, we are pleased to inform you that the Meeting of Graduate Studies Committee for Faculty of Computer Science and Mathematics has agreed on above appointment and you will receive an honorarium payment of MYR600.00.</p>

  <p>2.&nbsp;&nbsp;&nbsp;The final examination and viva date were suggested on <strong><%= vivaDayLabel %></strong>. Attached here, the documents for your kind perusal:</p>

  <p style="margin-left:2.5rem;">i.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1 softcopy of student's thesis</p>
  <p style="margin-left:2.5rem;">ii.&nbsp;&nbsp;&nbsp;&nbsp;PG-16a form (Thesis Examination Report) and softcopy of student's thesis were included and email to <em><%= memberEmail.isEmpty() ? "[examiner email]" : memberEmail %></em>. We seek your kind cooperation to return us the below documents:</p>
  <p style="margin-left:2.5rem;">iii.&nbsp;&nbsp;&nbsp;Please confirm your acceptance using the secure response link sent to your email (or click the Respond button in the appointment email). Once you accept, you will be shown a short secure form to provide bank/payment details for honorarium processing. Please complete that form by <strong><%= confirmDeadlineLabel %></strong>.</p>
  <p style="margin-left:2.5rem;">iv.&nbsp;&nbsp;&nbsp;Completed PG-16a Form along with completed Thesis Examination Report (as per enclosed guideline) by <em>email</em> to the secretariat by <strong><%= reportDeadlineLabel %></strong> for our further action.</p>

  <p>Thank you in advance for your attention and cooperation.</p>

  <p style="font-weight:bold;margin-top:1.5rem;">
    "MALAYSIA MADANI"<br>
    "BERKHIDMAT UNTUK NEGARA"
  </p>

  <div style="page-break-inside:avoid;">
  <p>Yours sincerely,</p>
  <br>
  <%@ include file="_sig-block-en.jsp" %>
  <div class="fw-bold letter-signer-name"><%= signerDisplayName.isEmpty() ? "[ DEAN / DEPUTY DEAN ]" : signerDisplayName %></div>
  <div class="letter-signer-role-ms"><%= signerDisplayRole_EN %></div>
  <% if (approvalSigned && letterApproval != null && letterApproval.get("signed_at") != null) { %>
  <div style="font-size:0.9rem;"><%= new java.text.SimpleDateFormat("dd MMMM yyyy").format(letterApproval.get("signed_at")) %></div>
  <% } %>
  <div>Faculty of Computer Science and Mathematics</div>
  <div>Universiti Malaysia Terengganu</div>
  <br>
  <div>&#9990; <%= signerDisplayPhone %></div>
  <div>&#9993; <a class="letter-signer-email-link" href="mailto:<%= signerDisplayEmail %>"><%= signerDisplayEmail %></a></div>

  <div style="margin-top:1.5rem;font-size:0.9rem;">
    c.c &nbsp;&nbsp;- File
  </div>
  </div>
<%@ include file="_lh-footer.jsp" %>
</div><!-- end main letter -->
