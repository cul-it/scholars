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
    /**
     *
     * @version 1.00
     * @author Jon Corson-Rikert, Brian Caruso, and Brian Lowe
     *
     * UPDATES: 
     * 2007-09-27   BJL   moved VIVO and CALS-specific markup to VIVO clone
     * 2006-01-31   BJL   edited to remove deprecated markup
     * 2005-11-06   JCR   put styling on extra search selection box
     * 2005-10-25   JCR   changed local ALL CALS RESEARCH constant to appBean.getSharedPortalFlagNumeric()
     * 2005-10-11   JCR   tweaks to VIVO search label spacing in header
     * 2005-09-15 JCR,BDC converted to use revised ApplicationBean and PortalBean
     * 2005-08-16   JCR   added CALS_IMPACT contant and modified code to use CALS display for that portal
     * 2005-08-01   JCR   changed ordering of other portals being displayed to displayRank instead of appName (affects SGER, CALS portals)
     * 2005-07-05   JCR   retrieving ONLY_CURRENT and ONLY_PUBLIC from database and setting in ApplicationBean
     * 2005-06-20   JCR   enabling a common CALS research portal via ALL CALS RESEARCH
     * 2005-06-20   JCR   removed MIN_STATUS_ID and minstatus parameter from search -- has been changed to interactive-only maxstatus parameter
     * JCR 2005-06-14 : added isInitialized() test for appBean and portalBean
     */

// application variables not stored in application bean
    final int CALS_IMPACT = 6;
    final int FILTER_SECURITY_LEVEL = 4;
    final int CALS_SEARCHBOX_SIZE = 25;
    final int VIVO_SEARCHBOX_SIZE = 20;

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

    String fixedTabStr = (fixedTabStr = request.getParameter("fixed")) == null ? null : fixedTabStr.equals("") ? null : fixedTabStr;
    final String DEFAULT_SEARCH_METHOD = "fulltext";

%>
<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="appBean" value="${requestScope.appBean}"/>

<div id="header">

    <c:set var='themeDir' >
        <c:out value='${portal.themeDir}' default='themes/default/'/></c:set>

    <table id="head"><tr>
    <td id="LogotypeArea">
    	<table><tr>
    	<td>
        <a target="_new" href="<%=portal.getRootBreadCrumbURL()%>">
        
        <% 
        // temporary hack to fix CALS Impact portal -- will later get moved to clone modifications
        if (!portal.getAppName().equalsIgnoreCase("CALS Impact")) { %>
           <img class="closecrop" src="${themeDir}site_icons/<%=appBean.getRootLogotypeImage()%>"
                                width="<%=appBean.getRootLogotypeWidth()%>"
                     height="<%=appBean.getRootLogotypeHeight()%>"
                     alt="<%=appBean.getRootLogotypeTitle()%>"/></a>
           
        <% } else { %>
           <a><img class="closecrop" src="${themeDir}site_icons/cu_insignia_bw.gif" alt="Cornell University"/></a>      	
        <% } %>
        </td><td>
        <a target="_new" href="<%=portal.getRootBreadCrumbURL()%>">
            <img class="closecrop" src="${themeDir}site_icons/<%=portal.getLogotypeImage()%>"
                     width="<%=portal.getLogotypeWidth()%>" height="<%=portal.getLogotypeHeight()%>"
                     alt="<%=portal.getAppName()%>"/></a>
        </td>
        </tr></table>
    </td>

        <td id="SearchArea" <%if ((portal.getBannerImage() == null || portal.getBannerImage().equals(""))){%>align="right"<% } %>>
<%          if (fixedTabStr != null && fixedTabStr.equalsIgnoreCase("Search")) { %>
<%          } else { %>
	    	<table align="center"><tr><td>
        		<div class="searchForm">
        		<form action="search" >
                	<input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
                	<input type="hidden" name="appname" value="<%=portal.getAppName()%>" />
                	<input type="hidden" name="searchmethod" value="<%=DEFAULT_SEARCH_METHOD%>" /><% /* options are fulltext/termlike/both */ %>
                	<table><tr>
                	<td>
                	 	   <label for="search">Search </label>
	                </td>
	                <td>
<%              	if (securityLevel>=FILTER_SECURITY_LEVEL && appBean.isFlag1Active()) { %>
                    	<select id="select" name="flag1" class="form-item" >
                    	<option value="nofiltering" selected="selected">entire database (<%=loginName%>)</option>
                    	<option value="<%=portal.getPortalId()%>"><%=portal.getShortHand()%></option>
                    	</select>
<%              	} else {%>
                    	<input type="hidden" name="flag1" value="<%=portal.getPortalId()%>" />
<%              	} %>
                	<input type="text" name="querytext" id="search" class="search-form-item" value="<c:out value="${requestScope.querytext}"/>" 
                	   	size="<%=VIVO_SEARCHBOX_SIZE%>" />
                	</td>
                	<td>
	                	<input class="search-form-button" name="submit" type="submit"  value="Go" />
	                </td>
	                </tr></table>
        		</form>
                <a class="formlink" href="search?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>
        		</div>
        		</td></tr></table>
<%          } // not a fixed tab %>
        </td>
<% if (!(portal.getBannerImage() == null || portal.getBannerImage().equals("")))
{
%>
        <td id="BannerArea" align="right">
	        <img src="${portal.themeDir}site_icons/<%=portal.getBannerImage()%>" alt="<%=portal.getShortHand()%>"/>
        </td>
<% } %>

    </tr></table>

</div><!--header-->

