<%-- Letter template fragment: External examiner appointment letter in Malay. Included by letterPreview.jsp for admin preview and printing. --%>
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
    <% if (!miCountry.isEmpty()) { %><div><%= miCountry %></div><% } %>
  </div>

  <p>YBrs. <%= salutation %>,</p>

  <p style="text-decoration:underline;font-weight:bold;">PELANTIKAN SEBAGAI PEMERIKSA TESIS <%= degreeLabelMS.toUpperCase() %></p>

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

  <p style="text-align:justify;">2.&nbsp;&nbsp;&nbsp;Sukacita dimaklumkan bahawa, Jawatankuasa Pengajian Siswazah FSKM dalam Mesyuaratnya telah bersetuju untuk melantik YBrs. <%= salutation %> sebagai Pemeriksa Tesis bagi pelajar di atas dan <%= honorariumMS %></p>

  <p>3.&nbsp;&nbsp;&nbsp;Sehubungan itu, Mesyuarat Jawatankuasa Pemeriksaan Tesis dan Viva adalah dicadangkan pada <strong><%= vivaDayLabel %></strong>. Bersama-sama ini disertakan maklumat sepertimana berikut:</p>

  <p style="margin-left:2.5rem;">i.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Satu (1) salinan Tesis Pelajar</p>
  <p style="margin-left:2.5rem;text-align:justify;">ii.&nbsp;&nbsp;&nbsp;&nbsp;Borang <%= formRefMS %> (Laporan Pemeriksaan Tesis) disertakan juga dalam bentuk <em>softcopy</em> ke email <em><%= memberEmail.isEmpty() ? "[emel pemeriksa]" : memberEmail %></em>. Borang <%= formRefMS %> yang telah lengkap diisi mohon dikembalikan kepada pihak urus setia Fakulti Sains Komputer dan Matematik selewat-lewatnya pada <strong><%= reportDeadlineLabel %></strong>.</p>

  <p style="text-align:justify;">4.&nbsp;&nbsp;&nbsp;Mohon kerjasama YBrs. <%= salutation %> untuk mengesahkan penerimaan melalui pautan respons selamat yang dihantar ke emel anda atau melalui portal FSKM sebelum atau pada <strong><%= confirmDeadlineLabel %></strong> untuk tindakan selanjutnya. Kerjasama yang diberikan oleh YBrs. <%= salutation %> amat dihargai dan diucapkan terima kasih.</p>

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
