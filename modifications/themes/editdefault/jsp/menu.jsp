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
	<a class="image vivoLogo" href="index.jsp?home=<%=portalId%>" title="Home"><img src="themes/vivo/site_icons/vivo_logo.gif" alt="VIVO: Virtual Life Sciences Library" /></a>
	
	<% if (VitroRequestPrep.isSelfEditing(request) ){ %>
    <c:url value="/edit/logout.jsp" var="editLogout" />
	<c:url value="/edit/login.jsp" var="editManage" />
	<a class="image logout" href="${editLogout}" title="Logout of editing"><img src="${themeDir}site_icons/logout.gif" alt="Logout of editing" /></a>
    <a class="image manage" href="${editManage}" title="Manage Your Profile"><img src="${themeDir}site_icons/manage.gif" alt="Manage Your Profile" /></a>
	<% } %>
	
    <!-- ************************ Navigation ********************** generated in menu.jsp **** -->
	<div id="menu">
<%		VitroRequest vreq = new VitroRequest(request);%>
		<!-- include primary menu list elements from TabMenu.java -->
   		<%=TabMenu.getPrimaryTabMenu(vreq)%>
	</div><!-- END menu -->
	<div id="secondaryMenu">
	<%=BreadCrumbsUtil.getBreadCrumbsDiv(request)+"\n"%>
	<!-- now render the standard Index, About, and Contact Us navigation  --> 
		<ul id="otherMenu">
<%			if ("browse".equalsIgnoreCase(fixedTabStr)) {%>
				<li class="activeTab"><a href="browsecontroller" title="list all contents by type">Index</a></li>
<%			} else {%>
				<li><a href="browsecontroller?home=<%=portalId%>" title="list all contents by type">Index</a></li>
<%			}
      		if ("about".equalsIgnoreCase(fixedTabStr)) {%>
				<li><a class="activeTab" href="about.jsp?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%			} else {%>
				<li><a href="about?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%			}
      		if ("comments".equalsIgnoreCase(fixedTabStr)) { %>
				<li class="activeTab"><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			} else {%>
				<li><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			}%>
		</ul>
	</div>
</div><!-- END header -->

<!-- ********** END menu.jsp FROM /themes/vivo/jsp/ ************* -->
<jsp:include page="/${themeDir}jsp/dashboard.jsp" flush="true"/>
