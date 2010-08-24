<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
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
<%          if ("browse".equalsIgnoreCase(fixedTabStr)) {%>
                <li class="activeTab"><a href="<c:url value="/browsecontroller"/>" title="list all contents by type">Index</a></li>
<%          } else {%>
                <li><a href="<c:url value="/browsecontroller"><c:param name="home" value="${portalBean.portalId}"/></c:url>" title="list all contents by type">Index</a></li>
<%          }
            if ("about".equalsIgnoreCase(fixedTabStr)) {%>
                <li><a class="activeTab" href="<c:url value="/about"><c:param name="home" value="${portalBean.portalId}"/><c:param name="login" value="none"/></c:url>" title="more about this web site">About</a></li>
<%          } else {%>
                <li><a href="<c:url value="/about"><c:param name="home" value="${portalBean.portalId}"/><c:param name="login" value="none"/></c:url>" title="more about this web site">About</a></li>
<%          }                                                    %>
<%          if ("comments".equalsIgnoreCase(fixedTabStr)) { %>
                <li class="activeTab"><a href="<c:url value="/contact"><c:param name="home" value="${portalBean.portalId }"/></c:url>">Contact Us</a></li>
<%          } else {%>
                <li><a href="<c:url value="/contact"><c:param name="home" value="${portalBean.portalId }"/></c:url>">Contact Us</a></li>
<%          }%>        
    	</ul>
	</div><!-- END 'primaryAndOther'-->
<%	if (fixedTabStr==null) { %>
		<div id="secondaryTabMenu">
		<%=TabMenu.getSecondaryTabMenu(vreq)%>
		</div><!--END 'secondaryTabMenu'--><% 
	}%>
</div><!-- END 'menu' -->
<!-- ************************ END menu.jsp ************************ -->
