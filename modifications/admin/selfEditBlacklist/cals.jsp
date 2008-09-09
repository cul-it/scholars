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
        <h2>CALS Administration has requested that you edit your profile only through the CALS annual reporting process</h2>
        <p style="text-align:center;">The next reporting period begins in January, 2009. Changes you make then will be propagated to VIVO and the CALS
            Research Portals.</p>
	    <h4>Please contact <a href="mailto:AcademicReportingContact-L@cornell.edu?subject=request to change CALS research/VIVO profile">CALS</a>
	        with any questions or with corrections you wish to make before January.
	    </h4> 
    </div>
    <p/>
<%  if( selfEditingId.getValue() != null ) { %>   
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
