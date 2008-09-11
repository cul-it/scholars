<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingUriFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier"%>
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
    <div align="center">
        <h2>The College of Human Ecology (CHE) administration has requested that you edit your profile only through the College's annual reporting process.</h2>
        <p style="text-align:center;">The next reporting period begins in January, 2009. Changes you make then will be propagated to VIVO.</p>
	    <h4>Please contact <a href="mailto:AcademicReportingContact-L@cornell.edu?subject=request to change VIVO profile">CHE</a>
	        with any questions or with corrections you wish to make in VIVO before January.
	    </h4> 
 
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
