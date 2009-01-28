<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
		<h4>At the request of the College, School of Hotel Administration faculty members and staff are asked to read the following notice:</h4>
	</div>
    <div class="college message" align="center">
        <h2>School of Hotel Administration Notice</h2>
        <p/>
        <p>The School of Hotel Administration has an internal application, Activity Insight,
            to update the information displayed in VIVO.</p>
        <p>If you wish to make changes to your VIVO profile via Activity Insight, please complete the
            <a href="<c:url value="/correctionForm.jsp"/>">VIVO correction form</a> and include any comments or suggestions.</p>
        <p>If you have questions about Activity Insight, please contact
            <a href="mailto:tsl33@cornell.edu">Tammy Lindsay</a> at TSL33@cornell.edu.</p>
	    <h4>Thank you</h4>
 	</div>
 	<p/>
    <% if( selfEditingId != null && selfEditingId.getValue() != null ) { %>   
       <c:url value="/entity" var="siteRoot">
          <c:param name="uri"><%=selfEditingId.getValue() %></c:param>
       </c:url>
           
    <div align="center">                
      <button type="button" 
        onclick="javascript:document.location.href='${siteRoot}'">
        Goto your profile</button>
    </div>
    
    <% } %>
    
    <c:url value="/" var="siteRoot"/>   
    <div align="center">                
      <button type="button" 
        onclick="javascript:document.location.href='${siteRoot}'">
        Return to main site</button>
    </div>
</div>
<jsp:include page="/edit/formSuffix.jsp"/>
