<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.FakeSelfEditingIdentifierFactory;"%>
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
<c:set var="themeDir"><c:out value="${request.pageContext}/${portal.themeDir}" default="${request.pageContext}/themes/editdefault/"/></c:set>

<!-- ********** START menu.jsp FROM /themes/editdefault/jsp/ ************* -->
<div id="header">
	<!-- ************************ Theme logo ********************** generated in menu.jsp **** -->
	<% if (VitroRequestPrep.isSelfEditing(request) ){ %>
    <!-- <c:url value="/edit/logout.jsp" var="editLogout" /> -->
    <%-- nac26: 080422 - changed logout url to handle temporary login via self editing for CAS demo --%>
    <c:url value="/admin/temporaryLogin.jsp?stopfaking=1" var="editLogout" />
    <!-- <c:url value="/edit/login.jsp" var="editManage" /> -->
    <%-- nac26: 080422 - changed manage url to handle temporary login via self editing for CAS demo --%>
    <% String netid = (String)session.getAttribute(FakeSelfEditingIdentifierFactory.FAKE_SELF_EDIT_NETID); %>
	<c:url value="/entity" var="editManage">
	    <c:param name="netid" value="<%=netid%>" />
	</c:url>
	<c:choose>
	    <c:when test="${fn:contains(pageContext.request.servletPath, 'edit/forms/')}">
	    </c:when>
	    <c:otherwise>
        	<a class="image logout" href="${editLogout}" title="Logout of editing"><img src="<c:url value='${themeDir}site_icons/logout.gif'/>" alt="Logout of editing" /></a>
            <a class="image manage" href="${editManage}" title="Manage Your Profile"><img src="<c:url value='${themeDir}site_icons/manage.gif'/>" alt="Manage Your Profile" /></a>
        </c:otherwise>
    </c:choose>
	<% } %>

	<h1>Academic Profile</h1>
</div><!-- END header -->