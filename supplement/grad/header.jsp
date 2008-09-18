<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.web.*" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:url var="jsDir" value="/js"></c:url>   

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<!--noindex-->

	<%-- the following meta value is used by javascript --%>
	<c:if test="${not empty param.metaURI}">
		<meta name="uri" content="${param.metaURI}"/>
	</c:if>

	<title>
	    <c:choose>
            <c:when test="${!empty param.titleText}">${param.titleText}</c:when>
            <c:otherwise>Graduate Programs in the Life Sciences | Cornell University</c:otherwise>
	    </c:choose>
	</title>
	
	<link rel="shortcut icon" href="${faviconLoc}"/>
	<link rel="stylesheet" href="/resources/css/screen.css" type="text/css" />
    <link rel="stylesheet" href="${jsDir}/niftyCorners.css" type="text/css" />
    <script type="text/javascript" src="${jsDir}/niftycube.js"></script>
    <script type="text/javascript" src="/resources/js/niftyConfig.js"></script>
    <script type="text/javascript" src="${jsDir}/jquery.js"></script>
    <script type="text/javascript" src="${jsDir}/jquery_plugins/getURLParam.js"></script>
    <script type="text/javascript" src="${jsDir}/jquery_plugins/jquery.hoverIntent.minified.js"></script>

    <%-- <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">
        <script type="text/javascript" src="/resources/js/jquery_plugins/jquery.cluetip.js"></script>
        <script type="text/javascript" src="/resources/js/jquery_plugins/jquery.dimensions.js"></script>
        <script type="text/javascript" src="/resources/js/jquery_plugins/jquery.hoverIntent.js"></script>
        <link rel="stylesheet" href="/resources/css/jquery.cluetip.css" type="text/css" />
    </c:if> --%>
        
    <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">
        <link rel="stylesheet" href="/resources/css/websnapr.css" type="text/css" />
        <script src="/resources/js/websnapr.js" type="text/javascript"></script>
    </c:if>

    <c:if test="${fn:contains(pageContext.request.servletPath, 'feedback.jsp')}">
        <script type="text/javascript" src="${jsDir}/jquery_plugins/jquery.validate.pack.js"></script>
        <script type="text/javascript" src="${jsDir}/jquery_plugins/jquery.form.js"></script>
        <script type="text/javascript" src="${jsDir}/jquery_plugins/jquery.delegate.js"></script>
    </c:if>
    
    <script type="text/javascript" src="/resources/js/lifescigrad.js"></script>
</head>

<body <c:if test="${not empty param.bodyID}">id="${param.bodyID}"</c:if>>
	<div id="bodyOverlay">
	<div id="skipnav">
		<a href="#content">Skip to main content</a>
	</div>
	<hr />
	<div id="wrap">
		<!-- The following div contains the Cornell University logo with unit signature -->
		<div id="cu-identity"> 
			<div id="cu-logo">
				<a href="http://www.cornell.edu/" title="Cornell University"><img src="/resources/images/cu_logo_unstyled.gif" alt="Cornell University" border="0" /></a>
			</div><!-- cu-logo -->
			<div id="cu-search">
				<a href="http://www.cornell.edu/search/" title="Search Cornell University">Search Cornell</a>
			</div><!-- cu-search -->
		</div> <!-- cu-identity -->
		
		
		
		<div id="header">
			<h1>Graduate Programs in the Life Sciences</h1>
			<div id="navigation">
				<ul>
					<li id="homeTab" <c:if test="${fn:contains(pageContext.request.servletPath, '/index.jsp')}">class="currentTab"</c:if>><a href="/" title="Home">Home</a></li>
					<li <c:choose>
					            <c:when test="${fn:contains(pageContext.request.servletPath, 'fieldsindex.jsp')}">class="currentTab"</c:when>
					            <c:when test="${fn:contains(pageContext.request.servletPath, 'areas.jsp')}">class="currentTab"</c:when>
					            <c:when test="${fn:contains(pageContext.request.servletPath, 'fields.jsp')}">class="currentTab"</c:when>
					        </c:choose>><a href="/fieldsindex/" title="an index of graduate fields">Graduate Fields</a></li>
					<li <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">class="currentTab" </c:if>><a href="/faculty/" title="index of graduate faculty">Faculty</a></li>
					<li <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">class="currentTab" </c:if>><a href="/departments/" title="an index of departments">Departments</a></li>
					<li <c:if test="${fn:contains(pageContext.request.servletPath, 'facilities.jsp')}">class="currentTab" </c:if>><a href="/facilities/" title="life science research facilities">Research Facilities</a></li>
					<li <c:if test="${fn:contains(pageContext.request.servletPath, 'search.jsp')}">class="currentTab" </c:if>><a href="/search/" title="search this site">Search</a></li>
				</ul>
			</div><!-- navigation -->
			
		</div><!-- header -->
<!--/noindex-->