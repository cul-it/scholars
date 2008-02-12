<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.shared.Lock" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%
    /*
   Clear any cruft from session.
    */

    String redirectTo = "/about.jsp";

    if( session != null ) {

         //get n3rdf from scope
        String editJson = (String)session.getAttribute("editjson");
        if( editJson == null || editJson.trim().length() == 0 )
            throw new Error("need edit object in session");

        System.out.println("editJson:\n" + editJson);
        EditConfiguration editConfig = new EditConfiguration(editJson);
        redirectTo = editConfig.getEntityToReturnTo();
        session.removeAttribute("editjson");
        EditConfiguration.clearConfigInSession(session);
        EditSubmission.clearEditSubmissionInSession(session);
    }
    
    if( redirectTo != null ){
        request.setAttribute("redirectTo",redirectTo);
        %>
        <c:url var="redirectUrl" value="../entity">
    	  <c:param name="uri" value="${redirectTo}"/>
		</c:url>
		<c:redirect url="${redirectUrl}"/>
		<%	
    }else {
		%>
        <c:redirect url="/"/>
        <%
    }
%>





