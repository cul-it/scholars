<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%
    /* Clear any cruft from session. */

    String redirectTo = null;

    if( session != null ) {

         //get n3rdf from scope
        String editJson = (String)session.getAttribute("editjson");
        EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
        EditSubmission editSub = EditSubmission.getEditSubmissionFromSession(session,request);

        if( editConfig == null || editConfig.getEntityToReturnTo() == null ){
            if( editJson == null || editJson.trim().length() == 0 ){
                redirectTo = null;
            }else{
                editConfig = new EditConfiguration(editJson);
                redirectTo = editConfig.getEntityToReturnTo();
            }
        }else{
            redirectTo = editConfig.getEntityToReturnTo();
        }

        session.removeAttribute("editjson");
        EditConfiguration.clearEditConfigurationInSession(session,editConfig);
        EditSubmission.clearEditSubmissionInSession(session, editSub);
    }

    if( redirectTo != null ){
        request.setAttribute("redirectTo",redirectTo);
        %>
        
		<c:redirect url="/entity">
            <c:param name="uri" value="${redirectTo}" />
        </c:redirect>
        <%
    }else { %>
        <c:redirect url="/about.jsp"/>
        <%
    }
%>





