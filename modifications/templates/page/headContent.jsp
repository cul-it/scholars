<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.Portal"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean"%>
<%
  VitroRequest vreq = new VitroRequest(request);  
  Portal portal = vreq.getPortal();
  String themeDir =  (portal!=null && portal.getThemeDir()!=null)?portal.getThemeDir():"/themes/default/";
  if( themeDir.startsWith("/") )
      themeDir = request.getContextPath() + themeDir; // was application.getContextPath()
  else 
      themeDir = request.getContextPath() + '/' + themeDir; // was application.getContextPath()
  
%>
<!-- headContent.jsp -->
<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/screen.css" media="screen"/>
<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/print.css" media="print"/>
<c:out value="${requestScope.css}" escapeXml="false"/>
<title><c:out value="${requestScope.title}"/></title>
<%
// nac26 080424: the following line should only be uncommented for PHILLIPS (vivo.cornell.edu) to ensure we're only tracking stats on the live site
// <script type="text/javascript" src="http://vivostats.mannlib.cornell.edu/?js"></script>
%>
<c:if test="${!empty scripts}"><jsp:include page="${scripts}"/></c:if>

<c:set var="customJsp"><c:out value="${requestScope.bodyJsp}" default="/debug.jsp"/></c:set>
<c:set var="customHeadJsp">
    <c:if test="${fn:substringAfter(customJsp,'.jsp') == ''}">${fn:substringBefore(customJsp,'.jsp')}${"Head.jsp"}</c:if>
</c:set>
<c:if test="${customJsp != '/debug.jsp' && customHeadJsp != ''}">
    <c:catch var="fileCheck">
        <c:import url="${customHeadJsp}"/>
    </c:catch>
</c:if>

<!-- end headContent.jsp -->
