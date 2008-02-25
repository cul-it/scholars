<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" xmlns:ex="http://simile.mit.edu/2006/11/exhibit#">
<head>
	<title>Graduate Programs in the Life Sciences</title>
	<link rel="stylesheet" href="style/screen.css" type="text/css" />
	<link href="data/peopleData2-dump.js" type="application/json" rel="exhibit/data" />
  
    <script src="exhibit/src/webapp/api/exhibit-api.js" type="text/javascript"></script>
</head>

<body>
	<div id="bodyOverlay">
	<div id="skipnav">
		<a href="#content">Skip to main content</a>
	</div>
	<hr />
	<div id="wrap">
		<!-- The following div contains the Cornell University logo with unit signature -->
		<div id="cu-identity"> 
			<div id="cu-logo">
				<a href="http://www.cornell.edu/" title="Cornell University"><img src="images/cu_logo_unstyled.gif" alt="Cornell University" width="180" height="45" /></a>
			</div><!-- cu-logo -->
			<div id="cu-search">
				<a href="http://www.cornell.edu/search/" title="Search Cornell University">Search Cornell</a>
			</div><!-- cu-search -->
		</div> <!-- cu-identity -->
		
		<hr />
		
		<div id="header">
			<h1>Graduate Programs in the Life Sciences</h1>
			<!-- <a class="image" href="/vivo/grad" title="Home"><img id="title" src="images/gradprogram_title.gif" alt="Graduate Program in the Life Sciences" /></a> -->
			<div id="navigation">
				<ul>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'index.jsp')}">class="currentTab" </c:if>href="/vivo/grad" title="Home">Home</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'fields.jsp')}">class="currentTab" </c:if>href="groupedfields.jsp" title="Graduate Fields">Graduate Fields</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">class="currentTab" </c:if>href="faculty.jsp" title="Faculty">Faculty</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'facilities.jsp')}">class="currentTab" </c:if>href="http://vivo.cornell.edu/index.jsp?collection=1441173947" title="Research Facilities">Research Facilities</a></li>
                    <!-- <li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">class="currentTab" </c:if>href="departments.jsp" title="Departments">Departments</a></li> -->
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'events.jsp')}">class="currentTab" </c:if>href="http://vivo.cornell.edu/index.jsp?collection=20" title="Events">Events</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'search.jsp')}">class="currentTab" </c:if>href="#" title="Search">Search</a></li>
				</ul>
			</div><!-- navigation -->
		</div><!-- header -->