<%@ page language="java"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.*"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
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
    HttpSession currentSession = request.getSession();

    boolean authorized = false;
    if (loginHandler.getLoginStatus().equals("authenticated")) /* test if session is still valid */
        if (currentSession.getId().equals(loginHandler.getSessionId()))
            if (request.getRemoteAddr().equals(
                    loginHandler.getLoginRemoteAddr()))
                authorized = true;
%>
<div class='footer'><div class='footerLinks'>
    <%= BreadCrumbsUtil.getRootBreadCrumb(vreq,"",portal)%>
    | <a href="<%=(authorized?"browsecontroller":"browsecontroller")%>?home=<%=portal.getPortalId()%>">Index</a>
    | <a href="comments?home=<%=portal.getPortalId()%>">Contact Us</a>
    <c:if test="${sessionScope.loginHandler.loginStatus == 'authenticated' && sessionScope.loginHandler.loginRole > 3 }">
        | admin [
	    <a href="http://validator.w3.org/check?uri=referer">validate xhtml</a>
	    <a href="http://jigsaw.w3.org/css-validator/check/referer">validate css</a>
	    ]
    </c:if>
    </div>
    <div class='copyright'>
	    &copy;2003-2007, <a href="<%=portal.getCopyrightURL()%>"><%=portal.getCopyrightAnchor()%></a>.
    </div>
    <div class='copyright'>
	    All Rights Reserved. <a href="termsOfUse?home=<%=portal.getPortalId()%>">Terms of Use</a>
    </div>
</div>


<%-- Google Analytics Tracking Codes --%>
<%-- added by mw542, 7/27/09 --%>
<% if (portal.getPortalId()==6) { /* Impact Portal */ %>
  
  <script type="text/javascript">
  var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
  document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
  </script>
  <script type="text/javascript">
  try {
  var pageTracker = _gat._getTracker("UA-5164622-6");
  pageTracker._trackPageview();
  } catch(err) {}</script>
  
<% } else { /* Main Research Portal */ %>
  
  <script type="text/javascript">
  var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
  document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
  </script>
  <script type="text/javascript">
  try {
  var pageTracker = _gat._getTracker("UA-5164622-7");
  pageTracker._trackPageview();
  } catch(err) {}</script>
  
<% } %>