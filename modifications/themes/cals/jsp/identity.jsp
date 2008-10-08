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
<c:set var="themeDir"><c:out value="${portal.themeDir}" default="themes/default/"/></c:set>

<div id="header">

<% if (portal.getPortalId()==6) { /* IMPACT */ %>

<table id="head"><tr>

	<c:url var="themePath" value="/themes/cals/"/>

    <td id="LogotypeArea">
    	<table><tr>
    	<td>
        <a target="_new" href="http://www.cornell.edu">
        
        <img class="closecrop" src="${themePath}site_icons/cu_insignia_bw.gif" alt="Cornell University"/></a>      	
        </td><td>
        <a target="_new" href="http://www.cals.cornell.edu/cals/research/index.cfm">
            <img class="closecrop" src="${themePath}site_icons/cals_logotype.gif"
                     width="430" height="76"
                     alt="CALS Impact"/></a>
        </td>

        </tr></table>
    </td>

        <td id="SearchArea" align="right">
<table align="center"><tr><td>
        		<div class="searchForm">
				<c:url var="searchPath" value="/search"/>
        		<form action="${searchPath}" >
                	<input type="hidden" name="home" value="6" />
                	<input type="hidden" name="appname" value="CALS Impact" />
                	<input type="hidden" name="searchmethod" value="fulltext" /><table><tr>

                	<td>
                	
       	<label for="search">Search Latest Impact Statements </label>   	    				
   	    </td>
    <%if (appBean.isFlag1Active()) {%>
                          <td>
                        <select id="select" name="flag1" class="search-form-item" >
<%                                              if (securityLevel>=FILTER_SECURITY_LEVEL) {%>                                <option value="nofiltering" selected="selected">entire database (<%=loginName%>)</option>
<%                              }%>
                        <%=portal.getSearchOptions()%>
                        </select>
              </td>
<%                              } else {%>
                    <input type="hidden" name="flag1" value="<%=portal.getPortalId()%>" />
<%                              }%>
                          <td>
                <input type="text" name="querytext" id="search" class="search-form-item" size="20" value="<c:out value="${requestScope.querytext}"/>" />
              </td>	                
                	<td>
	                	<input class="search-form-button" name="submit" type="submit"  value="Go" />
	                </td>

	                </tr></table>
        		</form>
        		<a class="formlink" style="color:white;" href="${searchPath}?home=6">Advanced Search | Search Tips</a>                
                </div>
        		</td></tr></table>
</td>
</tr></table>

<% } else { /* RESEARCH PORTALS */ %>

<%  /* ======================= CALS RESEARCH PORTALS ============================= */
    int rotatingBannerWidth=0; %>
    <table id="CALS_Research_Head">
    <tr>
        <td id="logotypeArea">
            <a target="_new" href="<%=portal.getRootBreadCrumbURL()%>"><img class="closecrop" src="<%=getServletContext().getContextPath()+"/"+portal.getThemeDir()%>site_icons/<%=portal.getLogotypeImage()%>" width="<%=portal.getLogotypeWidth()%>" height="<%=portal.getLogotypeHeight()%>" alt="<%=portal.getAppName()%>"/></a>
        </td>
<%		String[] bannerImgName = new String[25];
        bannerImgName[0] = "16.reduced.jpg";
        bannerImgName[1] = "Binoculars.reduced.jpg";
        bannerImgName[2] = "bridge.reduced.jpg";
        bannerImgName[3] = "Bugs.reduced.jpg";
        bannerImgName[4] = "Building.reduced.jpg";
        bannerImgName[5] = "campusviewsmontage.reduced.jpg";
        bannerImgName[6] = "cornfield.reduced.jpg";
        bannerImgName[7] = "critters.reduced.jpg";
        bannerImgName[8] = "fallquad.reduced.jpg";
        bannerImgName[9] = "flowerbeds.reduced.jpg";
        bannerImgName[10] = "flowermarch.reduced.jpg";
        bannerImgName[11] = "foreigntour.reduced.jpg";
        bannerImgName[12] = "Gradmontage.reduced.jpg";
        bannerImgName[13] = "greenhouse.reduced.jpg";
        bannerImgName[14] = "hothouse.reduced.jpg";
        bannerImgName[15] = "inthefield.reduced.jpg";
        bannerImgName[16] = "inthefield2.reduced.jpg";
        bannerImgName[17] = "labs.reduced.jpg";
        bannerImgName[18] = "labs2.reduced.jpg";
        bannerImgName[19] = "labs3.reduced.jpg";
        bannerImgName[20] = "Lake.reduced.jpg";
        bannerImgName[21] = "lister.reduced.jpg";
        bannerImgName[22] = "motobike.reduced.jpg";
        bannerImgName[23] = "studentfaces.reduced.jpg";
        bannerImgName[24] = "watershots.reduced.jpg";
        int[][] bannersForPortal = {{5,8,12,23,4,7,21},{5,8,12,23,0,1,3,4,10,14,15,16,17,19,20,24},{5,8,12,23,0,2,3,6,7,9,10,11,13,14,15,17,18,19,20,22},{5,8,12,23,0,2,3,10,11,14,16,17,22}};
           
        java.util.Calendar cal = java.util.Calendar.getInstance();
        java.util.Random rand = new java.util.Random(cal.getInstance().getTimeInMillis());
        String bannerImageName="";
        if (portal.getPortalId()==60) {
        	bannerImageName = bannerImgName[rand.nextInt(24)];
        } else {
            bannerImageName = bannerImgName[bannersForPortal[portal.getPortalId()-2][rand.nextInt(bannersForPortal[portal.getPortalId()-2].length)]];
		}%>
		<c:url var="themePath" value="/${portal.themeDir}"/>
        <td class="plainBannerAreaRight" align="right"><img src="${themePath}site_icons/<%=bannerImageName%>" align="right" alt="<%=portal.getAppName()%>"/></td>
    </tr>
    <tr>
    	<td id="shadedSearchBox">
    	<label for="search">Search</label>
<%      if (fixedTabStr != null && fixedTabStr.equalsIgnoreCase("Search")) { %>
            &nbsp;
<%      } else {%>
			<c:url var="searchPath" value="/search"/>
            <form action="${searchPath}" >
        	<div class="searchForm">
            	<input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
            	<input type="hidden" name="appname" value="<%=portal.getAppName()%>" />
            	<input type="hidden" name="searchmethod" value="<%=DEFAULT_SEARCH_METHOD%>" /><% /* options are fulltext/termlike/both */ %>
			<table style="width:auto;"><tr>
<%				if (appBean.isFlag1Active()) {%>
			  <td>
            		<select id="select" name="flag1" class="search-form-item" >
<%						if (securityLevel>=FILTER_SECURITY_LEVEL) {%>
                    		<option value="nofiltering" selected="selected">entire database (<%=loginName%>)</option>
<%              		}%>
                    	<%=portal.getSearchOptions()%>
            		</select>
              </td>
<%				} else {%>
                    <input type="hidden" name="flag1" value="<%=portal.getPortalId()%>" />
<%				}%>
			  <td>
            	<input type="text" name="querytext" id="search" class="search-form-item" size="24" value="<c:out value="${requestScope.querytext}"/>" />
              </td>
			  <td>
            	<input class="search-form-button" name="submit" type="submit"  value="Go" /><br/>
              </td>
            </tr></table>
            	<a class="formlink" href="${searchPath}?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>
        	</div>
        	</form>
<%      }%>
    </td>
    <td class="shadedBannerArea">
        <table id="interportalnav" summary="interportal navigation links">
        <tr><%=(portal.getPortalId()==CALS_IMPACT)?"<td class='unselected'><h3>"+portal.getAppName()+"</h3></td>":portal.getNavigationChoices()%></tr>
        </table>
    </td></tr>
    </table>
<% } %>
</div><!--END header-->

