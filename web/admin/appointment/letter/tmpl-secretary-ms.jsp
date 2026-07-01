<%-- Letter template fragment: Secretary/Recorder appointment letter in Malay. Included by letterPreview.jsp for admin preview and printing. --%>
<%@ page pageEncoding="UTF-8" %>
<% { java.util.Locale _msL = new java.util.Locale("ms","MY");
     today = new java.text.SimpleDateFormat("dd MMMM yyyy", _msL).format(new java.util.Date());
     if (a != null && a.getScheduledAt() != null) {
       vivaDayLabel         = new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)", _msL).format(a.getScheduledAt());
       confirmDeadlineLabel = new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)", _msL).format(new java.util.Date(a.getScheduledAt().getTime() - 14L*24*60*60*1000));
       reportDeadlineLabel  = new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)", _msL).format(new java.util.Date(a.getScheduledAt().getTime() - 7L*24*60*60*1000));
     }
} %>
<div class="letter-paper">
<%@ include file="_lh-header.jsp" %>

  <!-- ─── Header ─────────────────────────────────────── -->
  <div style="text-align:right;margin-bottom:1.5rem;">
    <div><strong>Rujukan Kami</strong> : UMT/FSKM/1-8/5/1</div>
    <div><strong>Tarikh</strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <%= today %></div>
    <div><strong>Bersamaan</strong> &nbsp;&nbsp;: <%= todayHijri %></div>
  </div>

  <!-- ─── Recipient ───────────────────────────────────── -->
  <div style="margin-bottom:1.5rem;">
    <div><strong><%= name %></strong></div>
    <% if (!miAffiliation.isEmpty()) { %><div><%= miAffiliation %></div><% } %>
  </div>

  <p>YBrs. <%= salutation %>,</p>

  <p style="text-decoration:underline;font-weight:bold;">PELANTIKAN SEBAGAI PENCATAT MESYUARAT JAWATANKUASA PEPERIKSAAN TESIS <%= degreeLabelMS.toUpperCase() %></p>

  <table style="width:100%;margin-bottom:1.5rem;border-collapse:collapse;">
    <tr>
      <td style="width:32%;padding:3px 0;font-weight:bold;vertical-align:top;">NAMA PELAJAR</td>
      <td style="vertical-align:top;padding:3px 0;">
        :&nbsp;<strong><%= a.getCandidateName() != null ? a.getCandidateName().toUpperCase() : "—" %>
        <% if (a.getCandidateStudentId() != null) { %>(<%= a.getCandidateStudentId() %>)<% } %></strong>
      </td>
    </tr>
    <tr>
      <td style="padding:3px 0;font-weight:bold;vertical-align:top;">PROGRAM PENGAJIAN</td>
      <td style="vertical-align:top;padding:3px 0;">:&nbsp;<strong><%= (candidateProgramMS != null && !candidateProgramMS.isEmpty() ? candidateProgramMS : degreeLabelMS + (candidateProgram != null && !candidateProgram.isEmpty() ? " (" + candidateProgram + ")" : "")).toUpperCase() %></strong></td>
    </tr>
    <tr>
      <td style="padding:3px 0;font-weight:bold;vertical-align:top;">TAJUK TESIS</td>
      <td style="vertical-align:top;padding:3px 0;">:&nbsp;<strong><%= a.getThesisTitle() != null ? a.getThesisTitle().toUpperCase() : "—" %></strong></td>
    </tr>
  </table>

  <p style="text-align:justify;">Saya dengan segala hormatnya merujuk kepada perkara di atas.</p>

  <p style="text-align:justify;">2.&nbsp;&nbsp;&nbsp;Sukacita dimaklumkan bahawa, Jawatankuasa Pengajian Siswazah FSKM telah bersetuju untuk melantik YBrs. <%= salutation %> sebagai Pencatat Mesyuarat Jawatankuasa Peperiksaan Viva bagi pelajar di atas.</p>

  <p style="text-align:justify;">3.&nbsp;&nbsp;&nbsp;Sehubungan itu, Mesyuarat Jawatankuasa Pemeriksaan Tesis dan Viva bagi pelajar di atas dicadangkan pada <strong><%= vivaDayLabel %></strong>. Justeru, mohon kerjasama pihak YBrs. <%= salutation %> untuk mengesahkan penerimaan melalui portal FSKM (lihat pratonton surat dalam sistem) atau menggunakan pautan respons selamat yang dihantar ke emel anda sebelum atau pada <strong><%= confirmDeadlineLabel %></strong>. Kami percaya dengan pengalaman dan kredibiliti YBrs. <%= salutation %> sesi Viva ini dapat dilaksanakan dengan lancar dan jayanya.</p>

  <p style="text-align:justify;">Kerjasama YBrs. <%= salutation %> dihargai dan didahului dengan ucapan ribuan terima kasih.</p>

  <p>Sekian.</p>

  <p style="font-weight:bold;margin-top:1.5rem;">
    "Kebersamaan UMT"<br>
    "MALAYSIA MADANI"<br>
    "BERKHIDMAT UNTUK NEGARA"
  </p>

  <div style="page-break-inside:avoid;">
  <p>Saya yang menjalankan amanah,</p>
  <br>
  <%@ include file="_sig-block-ms.jsp" %>
  <div class="fw-bold letter-signer-name"><%= signerDisplayName.isEmpty() ? "[ DEKAN / TIMBALAN DEKAN ]" : signerDisplayName %></div>
  <div class="letter-signer-role-ms"><%= signerDisplayRole_MS %></div>
  <% if (approvalSigned && letterApproval != null && letterApproval.get("signed_at") != null) { %>
  <div style="font-size:0.9rem;"><%= new java.text.SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("ms","MY")).format(letterApproval.get("signed_at")) %></div>
  <% } %>
  <div>Fakulti Sains Komputer dan Matematik</div>
  <div>Universiti Malaysia Terengganu</div>
  <br>
  <div>&#9990; <%= signerDisplayPhone %></div>
  <div>&#9993; <a class="letter-signer-email-link" href="mailto:<%= signerDisplayEmail %>"><%= signerDisplayEmail %></a></div>

  <div style="margin-top:1.5rem;font-size:0.9rem;">
    s.k &nbsp;&nbsp;- Fail
  </div>
  </div>
<%@ include file="_lh-footer.jsp" %>
</div><!-- end main letter -->

<!-- Lampiran 1 removed to preserve first-page letter layout -->
