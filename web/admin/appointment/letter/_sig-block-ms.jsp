<%-- Malay signature block: renders uploaded image as inline base64 or falls back to blank line.
     Requires: approvalSigned (boolean), letterApproval (Map<String,Object>), application (ServletContext) --%>
<% {
  String _si = (approvalSigned && letterApproval != null && letterApproval.get("signature_image") != null)
      ? letterApproval.get("signature_image").toString().trim() : "";
  boolean _showImg = false;
  if (!_si.isEmpty()) {
    try {
      java.io.File _f = new java.io.File(application.getRealPath("/uploads/signatures"), _si);
      if (_f.exists()) {
        byte[] _b = java.nio.file.Files.readAllBytes(_f.toPath());
        String _b64 = java.util.Base64.getEncoder().encodeToString(_b);
        String _x = _si.lastIndexOf('.') >= 0 ? _si.substring(_si.lastIndexOf('.') + 1).toLowerCase() : "png";
        String _m = "jpg".equals(_x) || "jpeg".equals(_x) ? "image/jpeg" : "gif".equals(_x) ? "image/gif" : "image/png";
        out.print("<img src=\"data:" + _m + ";base64," + _b64
            + "\" alt=\"Tandatangan\" style=\"max-height:80px;max-width:220px;display:block;margin-bottom:4px;\">");
        _showImg = true;
      }
    } catch (Exception _ignored) {}
  }
  if (!_showImg) { %><div>_________________________________</div><% }
} %>
