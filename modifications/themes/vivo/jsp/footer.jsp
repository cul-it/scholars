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
	<p class="siteFeedback"><a href="commentsForm.jsp" title="Send Us Feedback">Site Feedback</a></p>
	<p>&#169; 2003-<%= new DateTime().getYear() %> <%= " " %> <a href="<%=portal.getCopyrightURL()%>"><%=portal.getCopyrightAnchor()%></a></p>
	
    <div class="copyright">
	    <p>All Rights Reserved. <a href="termsOfUse?home=<%=portal.getPortalId()%>">Terms of Use</a></p>
    </div><!-- END div 'copyright' -->
</div><!-- footer -->

