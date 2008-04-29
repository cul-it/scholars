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
<%@ page import="java.util.List" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jstl/functions" %>


<% /* grab the predicate URI and trim it down to get the Local Name so we can send the user back to the appropriate property */ %>
<c:set var="predicateUri" value="${param.predicateUri}" />
<c:set var="localName" value="${fn:substringAfter(predicateUri, '#')}" />
<c:url var="redirectUrl" value="../entity">
    <c:param name="uri" value="${param.subjectUri}"/>
    <c:param name="property" value="${localName}" />
</c:url>

<%
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
    if( wdf == null )
        throw new Error("could not get a WebappDaoFactory");

    ObjectProperty prop = wdf.getObjectPropertyDao().getObjectPropertyByURI(predicateUri);
    if( prop == null ) { throw new Error("In propDelete.jsp, could not find property " + predicateUri); }
    request.setAttribute("propertyName",prop.getDomainPublic());

    //do the delete
    if( request.getParameter("y") != null ){
        wdf.getPropertyInstanceDao().deleteObjectPropertyStatement(subjectUri,predicateUri,objectUri);
        // insert code to test predicateUri as an object property with stub individual range classes
        // that should be deleted -- could possibly look just at the objectUri vclass
        Individual object = (Individual)request.getAttribute("object");
        if (object==null) {
            object = wdf.getIndividualDao().getIndividualByURI( objectUri );
            if( object == null ) throw new Error("Could not find object as request attribute or in model: '" + objectUri + "'");
            request.setAttribute("object", object);
            List<VClass> vclasses=object.getVClasses(false);
        	for(VClass clas: vclasses) {
            	if ( "http://vivo.library.cornell.edu/ns/0.1#EducationalBackground".equals(clas.getURI()) ) {
            	    wdf.getIndividualDao().deleteIndividual(object);
            	}
            }
        }%>
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
    <h2>Are you sure you want to delete the following entry from <i>${propertyName}</i>?</h2>
    <div class="toBeDeleted">"${objectName}"</div>
    <input type="hidden" name="subjectUri"   value="${param.subjectUri}"/>
    <input type="hidden" name="predicateUri" value="${param.predicateUri}"/>
    <input type="hidden" name="objectUri"    value="${param.objectUri}"/>
    <input type="hidden" name="y"            value="1"/>
    <input type="hidden" name="cmd"          value="delete"/>
    <v:input type="submit" id="submit" value="Delete" cancel="${param.subjectUri}" />
</form>

<jsp:include page="${postForm}"/>
