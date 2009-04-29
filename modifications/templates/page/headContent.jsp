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
// mw542 033009: moved the Mint javascript include to footer.jsp
%>

<c:url var="jqueryPath" value="/js/jquery.js"/>
<script type="text/javascript" src="${jqueryPath}"></script>

<c:if test="${!empty scripts}"><jsp:include page="${scripts}"/></c:if>

<%-- 
mw542 021009: Brian C said this was ignoring the catch tags throwing exceptions. we should find a better way to include css/js anyway

<c:set var="customJsp"><c:out value="${requestScope.bodyJsp}" default="/debug.jsp"/></c:set>
<c:set var="customHeadJsp">
    <c:if test="${fn:substringAfter(customJsp,'.jsp') == ''}">${fn:substringBefore(customJsp,'.jsp')}${"Head.jsp"}</c:if>
</c:set>
<c:if test="${customJsp != '/debug.jsp' && customHeadJsp != ''}">
    <c:catch var="fileCheck">
        <c:import url="${customHeadJsp}"/>
    </c:catch>
</c:if> 
--%>

<!-- end headContent.jsp -->
