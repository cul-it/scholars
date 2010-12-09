<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean"%>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%! 
  public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.page.headContent.jsp");
%>
<%
  VitroRequest vreq = new VitroRequest(request);  
  Portal portal = vreq.getPortal();
  
  String themeDir = portal != null ? portal.getThemeDir() : Portal.DEFAULT_THEME_DIR_FROM_CONTEXT;
  themeDir = vreq.getContextPath() + '/' + themeDir;   
%>

<!-- headContent.jsp -->

<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/screen.css" media="screen"/>
<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/print.css" media="print"/>
<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/infomaki_link.css" media="screen"/>
<%-- This should be a non-theme-specific stylesheet --%>
<link rel="stylesheet" type="text/css" href="<%=themeDir%>css/edit.css"/>

<title><c:out value="${requestScope.title}"/></title>

<script type="text/javascript" src="${pageContext.request.contextPath}/js/SOTCAnimator.js"></script>

<c:if test="${!empty scripts}"><jsp:include page="${scripts}"/></c:if>

<!-- end headContent.jsp -->
     