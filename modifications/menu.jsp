<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
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
<div id="header">
	<!-- ************************ Theme logo ********************** generated in header.jsp **** -->
	<a class="image" href="#" title="Home"><img src="themes/vivo/site_icons/vivo_logo.gif" alt="VIVO: Virtual Life Sciences Library" /></a>
	
    <!-- ************************ Navigation ********************** generated in header.jsp **** -->
	<div id="menu">
		<div id="primaryAndOther">
<%			VitroRequest vreq = new VitroRequest(request);%>
			<!-- include primary menu list elements from TabMenu.java -->
    		<%=TabMenu.getPrimaryTabMenu(vreq)%>
    		<!-- now render the standard Index, About, and Contact Us navigation  --> 
    		<ul id="otherMenu">
<%		  	 	if ("browse".equalsIgnoreCase(fixedTabStr)) {%>
        			<li class="activeTab"><a href="browsecontroller" title="list all contents by type">Index</a></li>
<% 		     	} else {%>
        			<li><a href="browsecontroller?home=<%=portalId%>" title="list all contents by type">Index</a></li>
<%		      	}
              	if ("about".equalsIgnoreCase(fixedTabStr)) {%>
					<li><a class="activeTab" href="about.jsp?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%		      	} else {%>
        			<li><a href="about?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%		      	}
              	if ("comments".equalsIgnoreCase(fixedTabStr)) { %>
        			<li class="activeTab"><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			  	} else {%>
        			<li><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%			  }%>
   			</ul>
  		</div><!--end 'primaryAndOther'-->
<%		if (fixedTabStr==null) { %>
  			<div id="secondaryTabMenu">
				<!-- include secondary list elements from TabMenu.java -->
        		<%=TabMenu.getSecondaryTabMenu(vreq)%> 
  			</div><!--end 'secondaryTabMenu'-->
<% 		} %>
	</div><!-- END menu -->
</div><!-- END header -->
