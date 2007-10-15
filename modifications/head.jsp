<%@ page language="java" %>
<%@ page errorPage="error.jsp"%>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.flags.PortalFlag" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.PortalWebUtil" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%><%/* this odd thing points to something in web.xml */ %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />

<%
    /**
     *
     * @version 1.00
     * @author Jon Corson-Rikert and Brian Caruso
     *
     * UPDATES:
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

    ApplicationBean appBean = (ApplicationBean)request.getAttribute("appBean");    
    Portal portal = (Portal)request.getAttribute("portalBean");    
    PortalWebUtil.populateSearchOptions(portal, appBean, ((WebappDaoFactory)getServletConfig().getServletContext().getAttribute("webappDaoFactory")).getPortalDao());
    PortalWebUtil.populateNavigationChoices(portal, request, appBean, ((WebappDaoFactory)getServletConfig().getServletContext().getAttribute("webappDaoFactory")).getPortalDao());

    String fixedTabStr = (fixedTabStr = request.getParameter("fixed")) == null ? null : fixedTabStr.equals("") ? null : fixedTabStr;
    final String DEFAULT_SEARCH_METHOD = "fulltext";
//final int     BATCH_GALLERY_IMAGE_WIDTH=90;
//final boolean USE_BATCH_GALLERY=true;
//final boolean FILTER_BY_PORTAL=true;
//final int     TAB_FILTER_FLAG2    =2; // see TabBean
//final int     TAB_FILTER_FLAG3    =3; // see TabBean
//final int     TAB_FILTER_FLAG_BOTH=5; // see TabBean
//final int     MIN_GALLERY_COLS_FOR_ALPHA_DISPLAY=5;

%>
<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="appBean" value="${requestScope.appBean}"/>

<div id="header">

<% /* =========== CALS RESEARCH PORTALS ============================================== */ %>

<%
if ((portal.getPortalId()>1 && portal.getPortalId()<6) || portal.getPortalId()==60) { // CALS Research portals
    int rotatingBannerWidth=0; %>
    <table id="CALS_Research_Head">
    <tr>
        <td id="logotypeArea">
            <a target="_new" href="<%=portal.getRootBreadCrumbURL()%>"><img class="closecrop" src="<%=portal.getThemeDir()%>site_icons/<%=portal.getLogotypeImage()%>" width="<%=portal.getLogotypeWidth()%>" height="<%=portal.getLogotypeHeight()%>" alt="<%=portal.getAppName()%>"/></a>
        </td>
        
        <% String[] bannerImgName = new String[25];
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
		   }
        %>
        
         <td class="plainBannerAreaRight" align="right"><img src="${portal.themeDir}site_icons/<%=bannerImageName%>" align="right" alt="<%=portal.getAppName()%>"/></td>
        
    </tr>
    <tr>
    <td id="shadedSearchBox">
    <label for="search">Search</label>
<%      if (fixedTabStr != null && fixedTabStr.equalsIgnoreCase("Search")) { %>
            &nbsp;
<%      } else {%>
            <form action="search" >
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
            	<a class="formlink" href="search?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>
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
    <%
    
   /* ================ VIVO ================================================ */
   
} else if (portal.getAppName().equalsIgnoreCase("VIVO")) {%>
    <table id="head">
    <tr>
        <td id="BannerArea">
            <img class="closecrop" src="${portal.themeDir}site_icons/<%=portal.getBannerImage()%>" alt="<%=portal.getShortHand()%>"/>
        </td>
        <td id="SearchArea">
<%          if (fixedTabStr != null && fixedTabStr.equalsIgnoreCase("Search")) { %>
                &nbsp;
<%          } else { %>
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
	                    <input type="text" name="querytext" id="search" class="search-form-item" value="<c:out value="${requestScope.querytext}"/>" size="<%=VIVO_SEARCHBOX_SIZE%>" />
                    </td>
                    <td>
                		<input class="search-form-button" name="submit" type="submit"  value="Go" /><br/>
                	</td>
                	</tr></table>
        		</form>
        		<a class="formlink" href="search?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>
        		</div>
        		
<%          } // not a fixed tab %>
        </td>
        <td id="LogotypeArea" align="right">
        	<table><tr>
	            <td><a target="_new" href="<%=portal.getRootBreadCrumbURL()%>">
                <img class="closecrop" src="${portal.themeDir}site_icons/<%=appBean.getRootLogotypeImage()%>" width="<%=appBean.getRootLogotypeWidth()%>" height="<%=appBean.getRootLogotypeHeight()%>" alt="<%=appBean.getRootLogotypeTitle()%>"/></a></td>
 				<td><a target="_new" href="<%=portal.getRootBreadCrumbURL()%>">
                <img class="closecrop" src="${portal.themeDir}site_icons/<%=portal.getLogotypeImage()%>" width="<%=portal.getLogotypeWidth()%>" height="<%=portal.getLogotypeHeight()%>" alt="<%=portal.getAppName()%>"/></a></td>
            </tr></table>
        </td>
    </tr>
    <tr><td class="light_ivory_bottom_bordered" colspan="3" ></td></tr>
    </table>
<%

    /* ======== OTHER CLONES =================================== */

} else { // all other portals until otherwise treated differently %>
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
                	
       	<% 
        // temporary hack to fix CALS Impact portal -- will later get moved to clone modifications
        if (!portal.getAppName().equalsIgnoreCase("CALS Impact")) { %>
   	                	<label for="search">Search </label>
   	    <% } else {%>
   	                	<label for="search">Search Latest Impact Statements </label>   	    				
   	    <% } %>
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
        		<% 
		        // temporary hack to fix CALS Impact portal -- will later get moved to clone modifications
        		if (!portal.getAppName().equalsIgnoreCase("CALS Impact")) { %>
                <a class="formlink" href="search?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>
                <% } else { %>
                <a class="formlink" style="color:white;" href="search?home=<%=portal.getPortalId()%>">Advanced Search | Search Tips</a>                
                <% } %>
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
<% } %>

</div><!--header-->

