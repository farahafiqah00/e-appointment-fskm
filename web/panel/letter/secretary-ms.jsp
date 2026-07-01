<%-- Panel: Secretary/Recorder appointment letter — Malay language, used by memberPreview.jsp for login-based letter delivery. --%>
<%@ page import="model.VivaAppointment, java.util.Map" pageEncoding="UTF-8" %><%
  VivaAppointment a           = (VivaAppointment) request.getAttribute("appointment");
  String today                = new java.text.SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("ms","MY")).format(new java.util.Date());
  String miTitle              = (String) request.getAttribute("lv_miTitle");
  String name                 = (String) request.getAttribute("lv_name");
  String miAffiliation        = (String) request.getAttribute("lv_miAffiliation");
  String salutation           = (String) request.getAttribute("lv_salutation");
  String candidateProgram     = (String) request.getAttribute("lv_candidateProgram");
  String candidateProgramMS   = a != null && a.getCandidateProgramMS() != null ? a.getCandidateProgramMS() : "";
  String degreeLabelMS        = (String) request.getAttribute("lv_degreeLabelMS");
  String memberEmail          = (String) request.getAttribute("lv_memberEmail");
  String honorariumMS         = (String) request.getAttribute("lv_honorariumMS");
  String formRefMS            = (String) request.getAttribute("lv_formRefMS");
  String confirmDeadlineLabel = (String) request.getAttribute("lv_confirmDeadlineLabel");
  String reportDeadlineLabel  = (String) request.getAttribute("lv_reportDeadlineLabel");
  String vivaDayLabel         = (String) request.getAttribute("lv_vivaDayLabel");
  boolean approvalSigned      = Boolean.TRUE.equals(request.getAttribute("lv_approvalSigned"));
  @SuppressWarnings("unchecked")
  Map<String,Object> letterApproval = (Map<String,Object>) request.getAttribute("letterApproval");
  String signerDisplayName    = (String) request.getAttribute("lv_signerDisplayName");
  String signerDisplayRole_MS = (String) request.getAttribute("lv_signerDisplayRole_MS");
  String signerDisplayEmail   = (String) request.getAttribute("lv_signerDisplayEmail");
  if (today == null) today = "";
  if (miTitle == null) miTitle = "";
  if (name == null) name = "";
  if (miAffiliation == null) miAffiliation = "";
  if (salutation == null) salutation = name;
  if (candidateProgram == null) candidateProgram = "";
  if (degreeLabelMS == null) degreeLabelMS = "Sarjana";
  if (memberEmail == null) memberEmail = "";
  if (honorariumMS == null) honorariumMS = "";
  if (formRefMS == null) formRefMS = "";
  if (confirmDeadlineLabel == null) confirmDeadlineLabel = "";
  if (reportDeadlineLabel == null) reportDeadlineLabel = "";
  if (vivaDayLabel == null) vivaDayLabel = "";
  if (signerDisplayName == null) signerDisplayName = "";
  if (signerDisplayRole_MS == null) signerDisplayRole_MS = "Dekan";
  if (signerDisplayEmail == null) signerDisplayEmail = "fskm@umt.edu.my";
  // todayHijri and signerDisplayPhone are required by tmpl-secretary-ms.jsp but are not set by memberPreview.jsp
  String todayHijri;
  try {
    java.time.chrono.HijrahDate _hd = java.time.chrono.HijrahDate.now(java.time.ZoneId.of("Asia/Kuala_Lumpur"));
    String[] _hm = {"Muharram","Safar","Rabiul Awal","Rabiul Akhir","Jamadil Awal","Jamadil Akhir","Rejab","Syaaban","Ramadan","Syawal","Zulkaedah","Zulhijjah"};
    todayHijri = _hd.get(java.time.temporal.ChronoField.DAY_OF_MONTH) + " " + _hm[_hd.get(java.time.temporal.ChronoField.MONTH_OF_YEAR) - 1] + " " + _hd.get(java.time.temporal.ChronoField.YEAR) + "H";
  } catch (Exception _hijriEx) { todayHijri = "[ Tarikh Hijri ]"; }
  String signerDisplayPhone = letterApproval != null && letterApproval.get("signer_phone") != null ? letterApproval.get("signer_phone").toString().trim() : "09 6333974";
  if (signerDisplayPhone.isEmpty()) signerDisplayPhone = "09 6333974";
%><%@ include file="/admin/appointment/letter/tmpl-secretary-ms.jsp" %>
