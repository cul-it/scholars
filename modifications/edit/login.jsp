<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.NetIdIdentifierFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%@ page contentType="text/html; charset=UTF-8"%>


<%@ page errorPage="/error.jsp"%>
<%@ page contentType="text/html; charset=UTF-8"%>

<c:set var="themeDir">themes/editdefault/</c:set>

<%
    String errorMsg = "";
    IdentifierBundle ids =
            ServletIdentifierBundleFactory.getIdBundleForRequest(request,session,pageContext.getServletContext());
    String netid = null;
    if( ids != null ){
        for(Identifier id : ids){
            if( id instanceof NetIdIdentifierFactory.NetId){
                netid = ((NetIdIdentifierFactory.NetId)id).getValue();
            }
        }
    }

    String personUri = null;
    VitroRequest vreq = new VitroRequest(request);
    if( netid != null && netid.length() > 0 && netid.length() < 100){
        String uri = null;
        try{
            uri = vreq.getWebappDaoFactory().getIndividualDao().getIndividualURIFromNetId(netid);
            if( uri == null  ){
                errorMsg = NO_NETID_ERROR_MSG;
            }
        }catch (Throwable t) {
            errorMsg = DEFAULT_ERROR_MSG;
        }
        Individual ind = vreq.getWebappDaoFactory().getIndividualDao().getIndividualByURI(uri);
        if( ind == null || ind.getURI() == null ){
            errorMsg = NO_NETID_ERROR_MSG;
        }else{
            personUri = ind.getURI();
            errorMsg = null;
        }
    }else{
        errorMsg = NO_NETID_ERROR_MSG;
    }

    if( personUri != null ){
        VitroRequestPrep.forceToSelfEditing(request);
        request.setAttribute("personUri",personUri);

        %>
        <c:redirect url="/entity">       
            <c:param name="uri" value="${personUri}"/>
        </c:redirect>
        <%
        return;
    }


    VitroRequestPrep.forceOutOfSelfEditing(request);
    //continue on to JSP error page bellow
    request.setAttribute("title","there was a problem accessing your profile");
    request.setAttribute("editThemeDir","/themes/editdefault");
    request.setAttribute("errorMsg",errorMsg);
%>


<jsp:include page="formPrefix.jsp"/>
<div id="content" class="full">
    <div align="center">${errorMsg}</div>

    <c:url value="/" var="siteRoot"/>	
    <div align="center">                
      <button type="button" 
        onclick="javascript:document.location.href='${siteRoot}'">
        Return to main site</button>
    </div>
</div>
<jsp:include page="formSuffix.jsp"/>

<%!

    private final String DEFAULT_ERROR_MSG ="There was an error in the system while accessing your profile, " +
            "please use the contact us form to request assistance.";
	private final String NO_NETID_ERROR_MSG = "<p>No netId is available from the current session; "
											+ "CUWebAuth may not be configured on this server.</p>"
											+ "<p>Please use the contact form to let us know that "
											+ "you were unable to edit your profile.</p>";
	
    private final String NO_MATCHING_NETID_ERROR_MSG = "There does not seem to be a profile in the system for your netId";
    private final String MULTIPLE_NETID_ERROR_MSG =
            "There is a problem with the system, please use the contact us form to let us "+
            "know that you were unable to edit your profile." ;
%>