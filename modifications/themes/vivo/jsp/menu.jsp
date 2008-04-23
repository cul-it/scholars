<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.BreadCrumbsUtil" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>

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

<!-- ********** START menu.jsp FROM /themes/vivo/jsp/ ************* -->
<div id="header">
    <!-- ************************ Theme logo ********************** generated in menu.jsp **** -->
    <%-- <c:url value="/edit/login.jsp" var="loginUrl"/> --%>
    <%-- nac26: 080422 - changed login url to handle temporary login via self editing for CAS demo --%>
    <c:url value="/admin/temporaryLogin.jsp" var="loginUrl"/>
    <a class="image login" href="${loginUrl}" title="Edit Your Profile"><img src="themes/vivo/site_icons/login.gif" alt="Edit Your Profile" /></a>
    <a class="image vivoLogo" href="index.jsp?home=<%=portalId%>" title="Home"><img src="themes/vivo/site_icons/vivo_logo.gif" alt="VIVO: Virtual Life Sciences Library" /></a>
    <em class="portal"><%=portal.getShortHand()%></em>
    
    <!-- ************************ Navigation ********************** generated in menu.jsp **** -->
    <div id="menu">
<%      VitroRequest vreq = new VitroRequest(request);%>
        <!-- include primary menu list elements from TabMenu.java -->
        <%=TabMenu.getPrimaryTabMenu(vreq)%>
    </div> <!-- menu -->
    <div id="secondaryMenu">
    <%=BreadCrumbsUtil.getBreadCrumbsDiv(request)%>
    <!-- now render the standard Index, About, and Contact Us navigation  --> 
        <ul id="otherMenu">
<%          if ("browse".equalsIgnoreCase(fixedTabStr)) {%>
                <li class="activeTab"><a href="browsecontroller" title="list all contents by type">Index</a></li>
<%          } else {%>
                <li><a href="browsecontroller?home=<%=portalId%>" title="list all contents by type">Index</a></li>
<%          }
            if ("about".equalsIgnoreCase(fixedTabStr)) {%>
                <li><a class="activeTab" href="about.jsp?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%          } else {%>
                <li><a href="about?home=<%=portalId%>&amp;login=none" title="more about this web site">About</a></li>
<%          }                                                    %>
<%          if ("comments".equalsIgnoreCase(fixedTabStr)) { %>
                <li class="activeTab"><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%          } else {%>
                <li><a href="comments?home=<%=portalId%>">Contact Us</a></li>
<%          }%>
        </ul>
    </div> <!-- secondaryMenu -->
</div> <!-- header -->
<!-- ********** END menu.jsp FROM /themes/vivo/jsp/ ************* -->
