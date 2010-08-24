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

<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.page.tabVivoAllHome.jsp");
%>

<%
    VitroRequest vreq = new VitroRequest(request);
    ApplicationBean appBean = vreq.getAppBean();
    if (appBean==null) { log.error("appBean returned null from VitroRequest"); }
    Portal portal = vreq.getPortal();
    if (portal==null) { log.error("portal returned null from VitroRequest"); }
    PortalWebUtil.populateSearchOptions(portal, appBean, vreq.getWebappDaoFactory().getPortalDao());
    PortalWebUtil.populateNavigationChoices(portal, request, appBean, vreq.getWebappDaoFactory().getPortalDao());
    //String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")?null:fixedTabStr;
%>

<c:catch var="myException">
<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="appBean" value="${requestScope.appBean}"/>

<div id="personWrap">
    <div id="dashboard" class="home">
        <div id="login">
            <h3>Faculty and Staff</h3>
            <p>Log in now to manage your page <a class="managePage" href="<c:url value="/edit/login.jsp"/>" title="Login Now">Manage your page</a></p>
        </div><!-- login -->
        <div id="seminars">
            <h3>Upcoming Seminars<span class="viewAll"><a title="View all seminars" href="<c:url value="index.jsp?home=65535&amp;collection=871"/>">view all &raquo;</a></span></h3>
            <jsp:include page="includes/upcomingSeminars.jsp" />
        </div>
    </div><!-- dashboard -->
    <div id="content" class="home">
            <h2>VIVO is a research-focused discovery tool</h2>
            <p class="intro">Browse or search for information about Cornell faculty and staff across all disciplines, departments and colleges.</p>
        
            <form id="searchHome" action="<c:url value="/${portal.themeDir}jsp/searchTriager.jsp"/>" method="get" name="searchHome"> 
                <h3><label for="searchInput">Search VIVO</label></h3>
                <input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
                <input type="hidden" name="appname" value="<%=portal.getAppName()%>" />
                <input type="text" id="searchInput" name="querytext" value="${requestScope.querytext}" size="250" />
				        <button id="searchSubmit" class="search" name="submit" type="submit">Search</button>
            </form>
        
            <div id="news">
                <h3>Making Headlines<span class="viewAll"><a title="View all news" href="<c:url value="/index.jsp?home=65535&amp;collection=864"/>">view all &raquo;</a></span></h3>
                <jsp:include page="includes/news.jsp" />
                <div class="clear"></div>
            </div>
    </div><!-- content -->
</div>
</c:catch>
<c:if test="${myException!=null}">
	<c:redirect url="/edit/login.jsp"/>
</c:if>