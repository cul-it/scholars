<%@ page import="edu.cornell.mannlib.vitro.webapp.web.*" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>

<%	/***********************************************
		 Display a single Page  in the most basic fashion.
		 The html <HEAD> is generated followed by the banners and menu.
		 After that the result of the jsp in the attribute bodyJsp is inserted.
		 Finally comes the footer.
		 
		 request.attributes:					
		 	"bodyJsp" - jsp of the body of this page.
			"title" - title of page
			"css" - optional additional css for page
			"scripts" - optional name of file containing <script> elements to be included in the page
			"bodyAttr" - optional attributes for the <body> tag, e.g. 'onload': use leading space
			"portalBean" - PortalBean object for request.
					 
		  Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
		  for debugging info.
		  		 
		 bdc34 2006-02-03 created		 
        **********************************************/
        /*
        String e = "";
		if (request.getAttribute("bodyJsp") == null){
        	e+="basicPage.jsp expects that request parameter 'bodyJsp' be set to the jsp to display as the page body.\n";    	    
        }         
        if (request.getAttribute("title") == null){
        	e+="basicPage.jsp expects that request parameter 'title' be set to the title to use for page.\n";    	    
        }         
    	if (request.getAttribute("css") == null){
			e+="basicPage.jsp expects that request parameter 'css' be set to css to include in page.\n";    	    
        }         
        if( request.getAttribute("portalBean") == null){
        	e+="basicPage.jsp expects that request attribute 'portalBean' be set.\n";    	    
        }
        if( request.getAttribute("appBean") == null){
        	e+="basicPage.jsp expects that request attribute 'appBean' be set.\n";    	    
        }
        if( e.length() > 0 ){
    	    throw new JspException(e);
		}
        */
%>

<% if( VitroRequestPrep.isSelfEditing(request) ){
        request.setAttribute("showPropEdits","true");
    }
%>

<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="themeDir"><c:out value="${portal.themeDir}" default="themes/default/"/></c:set>
<c:set var="bodyJsp"><c:out value="${requestScope.bodyJsp}" default="/debug.jsp"/></c:set>
<c:url var="jsDir" value="/js"></c:url>
		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">	
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
   <link rel="stylesheet" type="text/css" href="<c:url value="${themeDir}css/screen.css"/>" media="screen"/>
   <c:out value="${requestScope.css}" escapeXml="false"/>
   <title><c:out value="${requestScope.title}"/></title>
   <c:if test="${!empty scripts}"><jsp:include page="${scripts}"/></c:if>
</head>
<body${requestScope.bodyAttr}>
<div id="wrap">
	<jsp:include page="/${themeDir}jsp/identity.jsp" flush="true"/>
	<div id="contentwrap">
		<jsp:include page="/${themeDir}jsp/menu.jsp" flush="true"/>
		<c:import url="${bodyJsp}"/>
	</div> <!-- contentwrap -->
	<jsp:include page="/${themeDir}jsp/footer.jsp" flush="true"/>
</div> <!-- wrap -->
</body>
</html>
