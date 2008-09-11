<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier"%>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>

<c:set var="themeDir">themes/editdefault/</c:set>


<%
// This page will check the SelfEditingId and send the user to a page
// describing why they are not allowed to login and self edit.

    IdentifierBundle ids =
        ServletIdentifierBundleFactory.getIdBundleForRequest(request,session,pageContext.getServletContext());    
SelfEditingIdentifierFactory.SelfEditing selfEditingId =
    SelfEditingIdentifierFactory.getSelfEditingIdentifier(ids);
    
    if( selfEditingId != null && 
        selfEditingId.getBlacklisted() == SelfEditingIdentifierFactory.NOT_BLACKLISTED &&
        selfEditingId.getValue() != null ){
        %>
        <c:redirect url="/entity">       
            <c:param name="uri" value="${personUri}"/>
        </c:redirect>
        <%
        return;        
    }

    if( CALS_UNIT_CODE.equals(selfEditingId.getBlacklisted()) ){
        %><jsp:forward page="/admin/selfEditBlacklist/cals.jsp"/><%
        return;
    }else if( CHE_UNIT_CODE.equals(selfEditingId.getBlacklisted() )){
        %><jsp:forward page="/admin/selfEditBlacklist/che.jsp"/><%
        return;
    }
    String netid = "unknown";
    if(request.getHeader("REMOTE_USER") != null )
        netid = request.getHeader("REMOTE_USER");
%>


<jsp:include page="formPrefix.jsp"/>
<div id="content" class="full">
    <div align="center">
    We are unable to log you into the system using the NetId of <%=netid%>.   
    </div>
    <!--  Cause: <%=selfEditingId.getBlacklisted()%> -->

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
<jsp:include page="formSuffix.jsp"/>

<%!
private static final String CALS_UNIT_CODE = "AG";
private static final String CHE_UNIT_CODE =  "HE";

%>