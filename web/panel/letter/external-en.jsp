<%-- Panel: External examiner appointment letter — English language, used by panelResponse.jsp for token-based letter delivery. --%>
<%@ page import="model.VivaAppointment, java.util.Map" pageEncoding="UTF-8" %><%
  VivaAppointment a           = (VivaAppointment) request.getAttribute("appointment");
  String today                = (String) request.getAttribute("lv_today");
  String miTitle              = (String) request.getAttribute("lv_miTitle");
  String name                 = (String) request.getAttribute("lv_name");
  String miAffiliation        = (String) request.getAttribute("lv_miAffiliation");
  String miCountry            = (String) request.getAttribute("lv_miCountry");
  String salutation           = (String) request.getAttribute("lv_salutation");
  String candidateProgram     = (String) request.getAttribute("lv_candidateProgram");
  String degreeLabelMS        = (String) request.getAttribute("lv_degreeLabelMS");
  String degreeLabelEN        = (String) request.getAttribute("lv_degreeLabelEN");
  String memberEmail          = (String) request.getAttribute("lv_memberEmail");
  String honorariumMS         = (String) request.getAttribute("lv_honorariumMS");
  String honorariumEN         = (String) request.getAttribute("lv_honorariumEN");
  String formRefMS            = (String) request.getAttribute("lv_formRefMS");
  String formRefEN            = (String) request.getAttribute("lv_formRefEN");
  String confirmDeadlineLabel = (String) request.getAttribute("lv_confirmDeadlineLabel");
  String reportDeadlineLabel  = (String) request.getAttribute("lv_reportDeadlineLabel");
  String vivaDayLabel         = (String) request.getAttribute("lv_vivaDayLabel");
  boolean approvalSigned      = Boolean.TRUE.equals(request.getAttribute("lv_approvalSigned"));
  @SuppressWarnings("unchecked")
  Map<String,Object> letterApproval = (Map<String,Object>) request.getAttribute("letterApproval");
  String signerDisplayName    = (String) request.getAttribute("lv_signerDisplayName");
  String signerDisplayRole_EN = (String) request.getAttribute("lv_signerDisplayRole_EN");
  String signerDisplayEmail   = (String) request.getAttribute("lv_signerDisplayEmail");
  if (today == null) today = "";
  if (miTitle == null) miTitle = "";
  if (name == null) name = "";
  if (miAffiliation == null) miAffiliation = "";
  if (miCountry == null) miCountry = "";
  if (salutation == null) salutation = name;
  if (candidateProgram == null) candidateProgram = "";
  if (degreeLabelMS == null) degreeLabelMS = "Sarjana";
  if (degreeLabelEN == null) degreeLabelEN = "Master";
  if (memberEmail == null) memberEmail = "";
  if (honorariumMS == null) honorariumMS = "";
  if (honorariumEN == null) honorariumEN = "";
  if (formRefMS == null) formRefMS = "";
  if (formRefEN == null) formRefEN = "";
  if (confirmDeadlineLabel == null) confirmDeadlineLabel = "";
  if (reportDeadlineLabel == null) reportDeadlineLabel = "";
  if (vivaDayLabel == null) vivaDayLabel = "";
  if (signerDisplayName == null) signerDisplayName = "";
  if (signerDisplayRole_EN == null) signerDisplayRole_EN = "Dean";
  if (signerDisplayEmail == null) signerDisplayEmail = "fskm@umt.edu.my";
  // signerDisplayPhone is required by tmpl-external-en.jsp but is not set by memberPreview.jsp
  String signerDisplayPhone = letterApproval != null && letterApproval.get("signer_phone") != null ? letterApproval.get("signer_phone").toString().trim() : "09 6333974";
  if (signerDisplayPhone.isEmpty()) signerDisplayPhone = "09 6333974";
%><%@ include file="/admin/appointment/letter/tmpl-external-en.jsp" %>
