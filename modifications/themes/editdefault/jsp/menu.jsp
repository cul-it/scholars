<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.BreadCrumbsUtil" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%
	/***********************************************
    Include the theme logo and navigation, which want to live in one div element
    and may in fact overlap
     

    bdc34 2006-01-03 created
	**********************************************/
	final Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.web.header.jsp");

	Portal portal = (Portal)request.getAttribute("portalBean");
	int portalId = -1;
	if (portal==null) {
    	log.error("Attribute 'portalBean' missing or null; portalId defaulted to 1");
    	portalId=1;
	} else {
    	portalId=portal.getPortalId();
	}

	String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")? null:fixedTabStr;
%>

<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="themeDir"><c:out value="${portal.themeDir}" default="themes/editdefault/"/></c:set>

<!-- ********** START menu.jsp FROM /themes/editdefault/jsp/ ************* -->
<div id="header">
	<!-- ************************ Theme logo ********************** generated in menu.jsp **** -->
	<% if (VitroRequestPrep.isSelfEditing(request) ){ %>
    <c:url value="/edit/logout.jsp" var="editLogout" />
	<c:url value="/edit/login.jsp" var="editManage" />
	<a class="image logout" href="${editLogout}" title="Logout of editing"><img src="${themeDir}site_icons/logout.gif" alt="Logout of editing" /></a>
    <a class="image manage" href="${editManage}" title="Manage Your Profile"><img src="${themeDir}site_icons/manage.gif" alt="Manage Your Profile" /></a>
	<% } %>

	<h1>Academic Profile</h1>
</div><!-- END header -->