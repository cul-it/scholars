<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingUriFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.NetIdIdentifierFactory"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>

<%
  IdentifierBundle ids =
        ServletIdentifierBundleFactory.getIdBundleForRequest(request,session,pageContext.getServletContext());    
    SelfEditingUriFactory.SelfEditing selfEditingId =
        SelfEditingUriFactory.getSelfEditingIdentifier(ids);
%>

<jsp:include page="/edit/formPrefix.jsp"/>

<div id="content" class="full">
	<div class="vivo message" align="center">
		<h4>At the request of the College, College of Human Ecology faculty members and staff are asked to read the following notice:</h4>
	</div>
    <div class="college message" align="center">
        <h2>College of Human Ecology Notice</h2>
        <p/>
        <p>The College of Human Ecology has an internal application, Faculty Annual Reports,
            that allows you to update the information displayed in VIVO.  You can access the
            <a href="https://he-fin.human.cornell.edu/far08/che/">Faculty Annual Reports</a>
            at https://he-fin.human.cornell.edu/far08/che/.  The data in VIVO are updated from
            the Faculty Annual Reports on a monthly basis.</p>
        <p>If you wish to make more urgent changes to your VIVO profile, please complete the
            <a href="<c:url value="/correctionForm.jsp"/>">VIVO correction form</a> and include any questions, comments or suggestions.</p>
        <p>If you have any questions about the Faculty Annual Reports, please contact
            <a href="mailto:kl24@cornell.edu">Karen Lucas</a> at kl24@cornell.edu.</p>
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
