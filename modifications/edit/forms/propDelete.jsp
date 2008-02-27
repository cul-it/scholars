<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%
    System.out.println("in propDelete.jsp");
    if( session == null)
        throw new Error("need to have session");
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {%>
        <c:redirect url="/about.jsp"/>
<%  }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String objectUri    = request.getParameter("objectUri");
    
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    ObjectProperty prop = wdf.getObjectPropertyDao().getObjectPropertyByURI(predicateUri);
    if( prop == null ) throw new Error("In propDelete.jsp, could not find property " + predicateUri);
    request.setAttribute("propertyName",prop.getDomainPublic());
    
    //do the delete
    if( request.getParameter("y") != null ){    
        System.out.println("In propDelete.jsp, doing the delete of \n"+subjectUri+"\n"+predicateUri+"\n"+objectUri);
        wdf.getPropertyInstanceDao().deleteObjectPropertyStatement(subjectUri,predicateUri,objectUri);

//      ObjectPropertyStatement stmt = new ObjectPropertyStatement();
//      stmt.setSubjectURI( subjectUri );
//      stmt.setPropertyURI( predicateUri );
//      stmt.setObjectURI( objectUri );
//
//      wdf.getObjectPropertyStatementDao().deleteObjectPropertyStatement(stmt);

        //request.setAttribute("propertyName",prop.getDomainPublic());
%>
        <c:url var="redirectUrl" value="../entity">
    	    <c:param name="uri" value="${param.subjectUri}"/>
		</c:url>
		<c:redirect url="${redirectUrl}"/>
<%  }

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    Individual object = wdf.getIndividualDao().getIndividualByURI(objectUri);
    if( object == null ) throw new Error("could not find subject " + objectUri);
    request.setAttribute("objectName",object.getName());
    
    VClass rangeClass = wdf.getVClassDao().getVClassByURI(prop.getRangeVClassURI());
    request.setAttribute("rangeClassName", rangeClass.getName());
%>
<jsp:include page="${preForm}"/>

<form action="editRequestDispatch.jsp" method="get">
    <h4>You are attempting to delete the property statement "${subjectName}" <i>${propertyName}"</i> "${objectName}"</h4>
    <input type="hidden" name="subjectUri"   value="${param.subjectUri}"/>
    <input type="hidden" name="predicateUri" value="${param.predicateUri}"/>
    <input type="hidden" name="objectUri"    value="${param.objectUri}"/>
    <input type="hidden" name="y"            value="1"/>
    <input type="hidden" name="cmd"          value="delete"/>
    <v:input type="submit" id="submit" value="Delete" cancel="${param.subjectUri}" />
</form>

<jsp:include page="${postForm}"/>
