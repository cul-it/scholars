<%@ page language="java" %>
<%@ page errorPage="error.jsp"%>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.PortalWebUtil" %>

<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.BreadCrumbsUtil" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>

<%
    VitroRequest vreq = new VitroRequest(request);
    ApplicationBean appBean = vreq.getAppBean();
    Portal portal = vreq.getPortal();
    PortalWebUtil.populateSearchOptions(portal, appBean, vreq.getWebappDaoFactory().getPortalDao());
    PortalWebUtil.populateNavigationChoices(portal, request, appBean, vreq.getWebappDaoFactory().getPortalDao());
    String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")?null:fixedTabStr;
%>

<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="appBean" value="${requestScope.appBean}"/>

<div id="personWrap">
    <div id="dashboard" class="home">
        <div id="login">
            <h3>Faculty and Staff</h3>
            <p>Log in now to manage your page <a class="image" href="<c:url value="/edit/login.jsp"/>" title="Login Now"><img src="<c:url value="/themes/vivo/site_icons/bt_managepage.gif"/>" alt="Edit Your Profile" /></a></p>
        </div><!-- login -->
        <div id="seminars">
            <h3>Upcoming Seminars<span class="viewAll"><a title="View all seminars" href="<c:url value="index.jsp?home=65535&amp;collection=20"/>">View all &raquo;</a></span></h3>
            <jsp:include page="includes/upcomingSeminars.jsp" />
        </div>
    </div><!-- dashboard -->
    <div id="content" class="person">
        <div class="contents home">
            <h2>VIVO is a research-focused discovery tool</h2>
            <p class="intro">Browse or search for information about Cornell faculty and staff across all disciplines, departments and colleges.</p>
        
            <form id="searchHome" action="<c:url value="/${portal.themeDir}jsp/searchTriager.jsp"/>" method="get" name="searchHome"> 
                <h3><label for="searchInput">Discover Cornell</label></h3>
                <input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
                <input type="hidden" name="appname" value="<%=portal.getAppName()%>" />
                <input type="text" id="searchInput" name="querytext" value="${requestScope.querytext}" size="250" />
                <input type="submit" id="searchSubmit" name="submit" value="search" />
            </form>
        
            <div id="news">
                <h3>Making Headlines<span class="viewAll"><a title="View all news" href="<c:url value="/index.jsp?home=65535&amp;collection=864"/>">View all &raquo;</a></span></h3>
                <jsp:include page="includes/news.jsp" />
            </div>
        </div><!-- contents home -->
    </div><!-- content -->
</div>