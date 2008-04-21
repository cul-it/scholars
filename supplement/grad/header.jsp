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
	<title>Graduate Programs in the Life Sciences</title>
	<link rel="stylesheet" href="style/screen.css" type="text/css" />
    <link rel="stylesheet" href="${jsDir}/niftyCorners.css" type="text/css" />
    <script type="text/javascript" src="${jsDir}/niftycube.js"></script>
    <script type="text/javascript" src="js/niftyConfig.js"></script>
    <script type="text/javascript" src="${jsDir}/jquery.js"></script>
    <%-- For Exhibit page only --%>
    <c:if test="${fn:contains(pageContext.request.servletPath, 'XXX.jsp')}">
        <link href="data/peopleData2.jsp" type="application/json" rel="exhibit/data" />
        <script src="http://static.simile.mit.edu/exhibit/api-2.0/exhibit-api.js" type="text/javascript"></script>
        <link rel="stylesheet" href="style/exhibit.css" type="text/css" /> <!-- Override exhibit styles -->
    </c:if>
    
    <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">
        <script src="js/defuscate.js" type="text/javascript"></script>
        <link rel="stylesheet" href="style/websnapr.css" type="text/css" />
        <script src="js/localsnapr.js" type="text/javascript"></script>
        <script type="text/javascript">
            $(document).ready(function() {
                
                // Inserting camera icons here instead of markup
                var thumbSrc = $("span.localsnapr").attr("title");
                $("span.localsnapr").append('<img alt="" src="images/icons/camera_small.png"/>').each(function() {
                    var thumbSrc = $(this).attr("title");
                    $(this).children("img").attr("alt", thumbSrc);            
                    $(this).children("img").addClass("localsnapr");   
                });
                $("span.localsnapr").removeAttr("title");
                
                // Pagination functions
                var origCount = $("tfoot td").text();
                $("#indexNav").append('<a id="showAll" href="#">show all<\/a>');
                $("#indexNav a#showAll").click(function(){
                    $("tbody").show();
                    $(this).css("outline", "none");
                    $("tfoot td").text("Total: " + origCount);
                });
                $("#indexNav a").not("#showAll").click(function(){
                    var tbodyID = "#" + $(this).text();
                    var count = $("tbody"+ tbodyID + " tr").length;
                    $("tbody").not(tbodyID).hide();
                    $("tbody").filter(tbodyID).show().each(function(){
                        $(this).children("tr").children("td:first").css("padding-top", "12px");
                    });
                    $(this).css("outline", "none");
                    $("tfoot td").empty().text("Total: " + count);
                    return false;
                });
            });
        </script>
    </c:if>
        
    <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">
        <link rel="stylesheet" href="style/websnapr.css" type="text/css" />
        <script src="js/websnapr.js" type="text/javascript"></script>
    </c:if>
    
    <script type="text/javascript">
        $(document).ready(function(){
          $("body#departments span.toggleLink").click(function () {
            $("ul#moreProjects").slideToggle("medium");
            $(this).toggleClass("toggled");
             return false;
         });
        $("body#fields span.toggleLink").click(function () {
            $("div.readMore").slideToggle("medium");
            $(this).toggleClass("toggled");
            return false;     
          });
        });
    </script>
    
    <!--[if xE]><script type="text/javascript" src="js/iepngfix.js"></script><![endif]-->
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
				<a href="http://www.cornell.edu/" title="Cornell University"><img src="images/cu_logo_unstyled.gif" alt="Cornell University" width="180" height="45" /></a>
			</div><!-- cu-logo -->
			<div id="cu-search">
				<a href="http://www.cornell.edu/search/" title="Search Cornell University">Search Cornell</a>
			</div><!-- cu-search -->
		</div> <!-- cu-identity -->
		
		<hr />
		
		<div id="header">
			<h1>Graduate Programs in the Life Sciences</h1>
			<div id="navigation">
				<ul>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'index.jsp')}">class="currentTab" </c:if>href="index.jsp" title="Home">Home</a></li>
					<li><a <c:choose><c:when test="${fn:contains(pageContext.request.servletPath, 'gradfieldsIndex.jsp')}">class="currentTab"</c:when>
					                    <c:when test="${fn:contains(pageContext.request.servletPath, 'groups.jsp')}">class="currentTab"</c:when>
					                    <c:when test="${fn:contains(pageContext.request.servletPath, 'fields.jsp')}">class="currentTab"</c:when>
					    </c:choose> href="gradfieldsIndex.jsp" title="Graduate Fields">Graduate Fields</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">class="currentTab" </c:if>href="faculty.jsp" title="Faculty">Faculty</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">class="currentTab" </c:if>href="departments.jsp" title="Departments">Departments</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'facilities.jsp')}">class="currentTab" </c:if>href="http://vivo.cornell.edu/index.jsp?collection=1441173947" title="Research Facilities">Research Facilities</a></li>
                    <li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'events.jsp')}">class="currentTab" </c:if>href="http://vivo.cornell.edu/index.jsp?collection=20" title="Events">Events</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'search.jsp')}">class="currentTab" </c:if>href="#" title="Search">Search</a></li>
				</ul>
			</div><!-- navigation -->
		</div><!-- header -->