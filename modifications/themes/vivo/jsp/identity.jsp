<%@ page language="java" %>
<%@ page errorPage="error.jsp"%>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%><%/* this odd thing points to something in web.xml */ %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.PortalWebUtil" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />

<%
	final int FILTER_SECURITY_LEVEL = 4;

    HttpSession currentSession = request.getSession();
    String currentSessionIdStr = currentSession.getId();
    int securityLevel = -1;
    String loginName = null;
    if (loginHandler.testSessionLevel(request) > -1) {
        securityLevel = Integer.parseInt(loginHandler.getLoginRole());
        loginName = loginHandler.getLoginName();
    }
    VitroRequest vreq = new VitroRequest(request);
    ApplicationBean appBean = vreq.getAppBean();
    Portal portal = vreq.getPortal();
    PortalWebUtil.populateSearchOptions(portal, appBean, vreq.getWebappDaoFactory().getPortalDao());
    PortalWebUtil.populateNavigationChoices(portal, request, appBean, vreq.getWebappDaoFactory().getPortalDao());
    String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")?null:fixedTabStr;
%>
<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="appBean" value="${requestScope.appBean}"/>
<c:set var='themeDir' ><c:out value='${portal.themeDir}' default='themes/default/'/></c:set>

<div id="cu-identity">
	<div id="cu-logo">
		<a id="insignia-link" class="clean" href="http://www.cornell.edu/" title="Cornell University"><img src="${portal.themeDir}site_icons/layout/cu_logo.gif" alt="Cornell University" width="283" height="76" border="0" /></a> 
		<div id="unit-signature-links"><a id="cornell-link" class="clean" href="http://www.cornell.edu/" title="Cornell University">Cornell University</a> <a id="unit-link" class="clean" href="http://www.cornell.edu" title="Cornell University">Cornell University</a> </div>
	</div><!-- cu-logo -->
	<div id="search-form"> 
		<form action="${portal.themeDir}jsp/searchTriager.jsp" method="get" name="gs"> 
		<!-- <form action="search" method="get" name="gs"> -->
			<input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
			<input type="hidden" name="appname" value="<%=portal.getAppName()%>" />
			<div id="search-input"> 
				<label for="search-form-query">SEARCH:</label>
<%              if (securityLevel>=FILTER_SECURITY_LEVEL && appBean.isFlag1Active()) { %>
                    <select id="search-form-qualifier" name="flag1">
                    	<option value="nofiltering" selected="selected">entire database (<%=loginName%>)</option>
                    	<option value="<%=portal.getPortalId()%>"><%=portal.getShortHand()%></option>
                    </select>
<%              } else {%>
                    <input type="hidden" name="flag1" value="<%=portal.getPortalId()%>" />
<%              } %>
				<input type="text" id="search-form-query" name="querytext" value="${requestScope.querytext}" size="20" />
				<input type="submit" id="search-form-submit" name="submit" value="go" />
			</div>
			<div id="search-filters"> 
				<input type="radio" id="search-filters1" name="sitesearch" value="vivo.cornell.edu" checked="checked" />
				<label for="search-filters1">VIVO</label>
				<input type="radio" id="search-filters2" name="sitesearch" value="www.cornell.edu" />
				<label for="search-filters2" class="force-right">Cornell</label>
			</div>
		</form>
	</div> <!-- search-form -->
</div> <!-- cu-identity -->
