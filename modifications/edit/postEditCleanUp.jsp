<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jstl/functions" %>

<%
    /* Clear any cruft from session. */

    String redirectTo = null;

    if( session != null ) {
        EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
        EditSubmission editSub = EditSubmission.getEditSubmissionFromSession(session,request);

        EditConfiguration.clearEditConfigurationInSession(session, editConfig);
        EditSubmission.clearEditSubmissionInSession(session, editSub);

        if( editConfig != null && editConfig.getEntityToReturnTo() != null ){
            String predicateUri = editConfig.getPredicateUri();
            /*System.out.println("Return to property after submitting form: " + predicateUri);*/%>
            <c:set var="predicateUri" value="<%=predicateUri%>" />
            <c:set var="localName" value="${fn:substringAfter(predicateUri, '#')}" />
            
        <%    redirectTo = editConfig.getEntityToReturnTo();
        }
    }

    if( redirectTo != null ){
        request.setAttribute("redirectTo",redirectTo);    %>
        <c:redirect url="/entity">
            <c:param name="uri" value="${redirectTo}" />
            <c:param name="property" value="${localName}" />
        </c:redirect>
    <% }else { %>
        <c:redirect url="/about"/>
    <% } %>





