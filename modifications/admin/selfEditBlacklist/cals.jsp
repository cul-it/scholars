<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>

<%
  IdentifierBundle ids =
        ServletIdentifierBundleFactory.getIdBundleForRequest(request,session,pageContext.getServletContext());    
    SelfEditingIdentifierFactory.SelfEditing selfEditingId =
        SelfEditingIdentifierFactory.getSelfEditingIdentifier(ids);
%>

<jsp:include page="/edit/formPrefix.jsp"/>

<div id="content" class="full">
	<div class="vivo message" align="center">
		<h4>As a College of Agriculture and Life Sciences faculty or staff member, you are receiving the following notice
		   in lieu of updating your VIVO profile directly:</h4>
	</div>
    <div class="college message" align="center">
        <h3>College of Agriculture and Life Sciences Notice</h3>
        <p/>
        <p>The College of Agriculture and Life Sciences (Ithaca and Geneva locations) has an internal application,
            Faculty Data Collection, that we use to update the information displayed in VIVO annually. Beginning in
            January, 2009, CALS is targeting to use a new application called Activity Insight to update the information
            displayed in VIVO on a more frequent basis.</p>
        <p>If you wish to make more urgent changes to your VIVO profile, please complete the
            <a href="<c:url value="/correctionForm.jsp"/>">VIVO correction form</a> and include any questions, comments or suggestions.</p>
        <p>If you have any questions about the CALS annual faculty data collection process, please contact
            <a href="mailto:lad23@cornell.edu">Lynn Benedetto</a> at lad23@cornell.edu.</p>
        <h4>Thank you</h4>
    </div>
    <p/>
<%  if( selfEditingId != null && selfEditingId.getValue() != null ) { %>   
        <c:url value="/entity" var="siteRoot">
            <c:param name="uri"><%=selfEditingId.getValue() %></c:param>
        </c:url>
           
        <div align="center">                
            <button type="button" 
            onclick="javascript:document.location.href='${siteRoot}'">
            Go to your profile</button>
        </div>
<%  } %>
    <p/>
    <c:url value="/" var="siteRoot"/>   
    <div align="center">                
        <button type="button" 
        onclick="javascript:document.location.href='${siteRoot}'">
        Return to main site</button>
    </div>
</div>
<jsp:include page="/edit/formSuffix.jsp"/>
