<%@ page language="java"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.*"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="org.joda.time.DateTime" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
<%
    /**
     * @version 1.00
     * @author Jon Corson-Rikert
     * UPDATES:
     * 2006-01-04   bdc   removed <head> and <body> tags and moved from <table> to <div>
     * 2005-07-07   JCR   included LoginFormBean so can substitute filterbrowse for portalbrowse for authorized users
     */

    VitroRequest vreq = new VitroRequest(request);
    Portal portal = vreq.getPortal();    
%>
<div id="footer">
	<p class="siteFeedback"><a href="<c:url value="/comments"><c:param name="home" value="${portalBean.portalId}"/></c:url>" title="Send Us Feedback">Contact Us</a></p>
	<p>&#169; 2003-<%= new DateTime().getYear() %> <%= " " %> <a href="<%=portal.getCopyrightURL()%>"><%=portal.getCopyrightAnchor()%></a></p>
	
    <div class="copyright">
	    <p>All Rights Reserved. <a href="<c:url value="/termsOfUse"/>">Terms of Use</a></p>
    </div><!-- END div 'copyright' -->
</div><!-- footer -->

<%--
// nac26 080424: the following line should only be uncommented for PHILLIPS (vivo.cornell.edu) to ensure we're only tracking stats on the live site
<script type="text/javascript" src="http://vivostats.mannlib.cornell.edu/?js"></script>
--%>

<%--
// mw542 033009: the following block for Google Analytics should also only be uncommented for PHILLIPS 
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-5164622-5");
pageTracker._trackPageview();
} catch(err) {}</script>
--%>



