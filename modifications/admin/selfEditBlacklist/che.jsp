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
      <h2> CHE will not allow you to edit your profile.</h2>
	<h4>Please contact <a href="mailto:someoneatche@cornell.edu?subject=It seems that I am blocked from logging in to the VIVO web site, why is that?">CHE office of administration</a> with your questions and suggesions.</h4> 
     </div>

    <% if( selfEditingId.getValue() != null ) { %>   
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
