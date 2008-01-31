<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.BreadCrumbsUtil" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%
    /***********************************************
     Make the Tab menu div, nothing else.

     bdc34 2006-01-03 created
     **********************************************/
    final Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.web.menu.jsp");

    Portal portal = (Portal)request.getAttribute("portalBean");
    int portalId = -1;
    if (portal==null) {
    	log.error("Attribute 'portalBean' missing or null; portalId defaulted to 1");
    	portalId=1;
    } else {
    	portalId=portal.getPortalId();
    }
    String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")?null:fixedTabStr;
%>
<!-- ***************Begin menu.jsp ********************** -->
<div id="menu">
	<div id="primaryAndOther">
<%		VitroRequest vreq = new VitroRequest(request);%>
    	<%=TabMenu.getPrimaryTabMenu(vreq)%>  
    	<ul id="otherMenu">
<%			if ( fixedTabStr != null && fixedTabStr.equalsIgnoreCase("browse")) {%>
        		<li class="activeTab"><a href="browsecontroller" title="list all contents by type">Index</a></li>
<% 			} else { %>
        		<li><a href="browsecontroller?home=<%=portalId%>" title="list all contents by type">Index</a></li>
<%			}
        	if ( fixedTabStr != null && fixedTabStr.equalsIgnoreCase("about")) {%>
        		<li><a class="activeTab" href="about.jsp?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%			} else { %>
        		<li><a href="about?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%			}         %>

             <c:url value="/selfEditIntro.jsp" var="loginUrl"/>
            <li><a href="${loginUrl}">Edit Your Profile</a></li>

<%          if ( fixedTabStr != null && fixedTabStr.equalsIgnoreCase("comments")) {%>
        		<li class="activeTab"><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			} else {%>
        		<li><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			}%>
    	</ul>
	</div><!-- END 'primaryAndOther'-->
<%	if (fixedTabStr==null) { %>
		<div id="secondaryTabMenu">
		<%=TabMenu.getSecondaryTabMenu(vreq)%>
		</div><!--END 'secondaryTabMenu'--><% 
	}%>
</div><!-- END 'menu' -->
<div id="breadcrumbs"><%=BreadCrumbsUtil.getBreadCrumbsDiv(request)%></div>
<!-- ************************ END menu.jsp ************************ -->
