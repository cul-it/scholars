<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>

<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ page import="java.util.Map" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils"%>

<%  /* get some data not already retrieved in editRequestDispatch to make the form more useful */
    String subjectUri   = request.getParameter("subjectUri");
    // already done in editRequestDispatch.jsp: request.setAttribute("subjectUriJson",MiscWebUtils.escape(subjectUri));
    Individual subject = (Individual)request.getAttribute("subject");
    if( subject == null ) throw new Error("In defaultObjPropForm.jsp, did not find subject in request scope: " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    String predicateUri = request.getParameter("predicateUri");
    // already done in editRequestDispatch.jsp: request.setAttribute("predicateUriJson",MiscWebUtils.escape(predicateUri));
    ObjectProperty prop = (ObjectProperty)request.getAttribute("predicate");
    if( prop == null ) throw new Error("In defaultObjPropForm.jsp, did not find property in request scope: " + predicateUri);
    request.setAttribute("propertyName",prop.getDomainPublic());
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    VClass rangeClass = wdf.getVClassDao().getVClassByURI(prop.getRangeVClassURI());
    request.setAttribute("rangeClassName", rangeClass.getName());

    // not yet fully set up for editing an existing object property statement by changing the related individual
    //String objectVarHandle = "objhandle";
    String objectUri = request.getParameter("objectUri");
    Individual object=null;
    if( objectUri != null ){
        object = (Individual)request.getAttribute("object");
        if( object == null ){ throw new Error("found an objectUri but no object in defaultObjPropForm.jsp"); }
        // already done in editRequestDispatch.jsp: request.setAttribute("objectUriJson",MiscWebUtils.escape(objectUri));
    }

    // what does this do?
    request.getSession(true);
%>

<v:jsonset var="queryForInverse" >
    PREFIX owl:  <http://www.w3.org/2002/07/owl#>
    SELECT ?inverse
    WHERE {
        ?inverse owl:inverseOf ?predicate
    }
</v:jsonset>

<v:jsonset var="n3ForEdit"  >
    ?subject ?predicate ?objectVar.
    ?objectVar ?inverse ?subject.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl"                   : "${formUrl}",
    "editKey"                   : "${editKey}",

    "subject"      : [ "subject", "${subjectUriJson}" ] ,
    "predicate"    : [ "predicate", "${predicateUriJson}" ],
    "object"       : [ "objectVar" ,  "${objectUriJson}" , "URI"],

    "n3required"                : [ "${n3ForEdit}" ],
    "n3optional"                : [ ],
    "newResources"              : { },

    "urisInScope"               : { },
    "literalsInScope"           : { },

    "urisOnForm"                : ["objectVar"],
    "literalsOnForm"            : [ ],

    "sparqlForLiterals"         : { },
    "sparqlForUris"             : {"inverse" : "${queryForInverse}" },

    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris"     : { },
    "fields"                    : { "objectVar" : {
                                       "newResource"      : "false",
                                       "queryForExisting" : { },
                                       "validators"       : [ ],
                                       "optionsType"      : "INDIVIDUALS_VIA_OBJECT_PROPERTY",
                                       "subjectUri"       : "${subjectUriJson}",
                                       "subjectClassUri"  : "",
                                       "predicateUri"     : "${predicateUriJson}",
                                       "objectClassUri"   : "",
                                       "rangeDatatypeUri" : "",
                                       "literalOptions"   : [ ] ,
                                       "assertions"       : ["${n3ForEdit}"]
                                     }
                                  }
  }
</c:set>

<%  /* now put edit configuration Json object into session */
    EditConfiguration editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
    EditConfiguration.putConfigInSession(editConfig, session);
    String formTitle   =""; // don't add local page variables to the request
    String submitLabel ="";
    if( objectUri != null ){     //these get done on an edit of an existing object property statement
        Model model = (Model)application.getAttribute("jenaOntModel");
        editConfig.prepareForUpdate(request,model);
        formTitle   = "Change value for &quot;"+prop.getDomainPublic()+"&quot; property for "+subject.getName();
        submitLabel = "save change";
    } else if ("true".equals((String)request.getAttribute("hasCustomForm"))) {
        formTitle   = "Create a new entry for "+subject.getName();
    } else {
        formTitle   =  "Choose an item to add to your &quot;"+prop.getDomainPublic()+"&quot; list";
        submitLabel ="save entry";
    }
%>
<jsp:include page="${preForm}"/>

<h2><%=formTitle%></h2>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <c:choose>
        <c:when test="${hasCustomForm eq 'true'}">
        	<c:url var="createNewUrl" value="/edit/editRequestDispatch.jsp">
            	<c:param name="subjectUri" value="${param.subjectUri}"/>
            	<c:param name="predicateUri" value="${param.predicateUri}"/>
            	<c:param name="clearEditConfig" value="true"/>
        	</c:url>
        	<button type="button" onclick="javascript:document.location.href='${createNewUrl}'">create new ${rangeClassName}</button>
        </c:when>
        <c:otherwise>
    		<v:input type="select" id="objectVar" size="80" label="<%=rangeClass.getName()%>" />
    		<v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
    		<v:input type="editKey" id="editKey"/>
    		<%-- use this here instead of the <c:choose> structure if you want to both pick an existing object and allow
    		     creation of a new one ...
    		    <c:if test="${hasCustomForm eq 'true'}">
        			<c:url var="createNewUrl" value="/edit/editRequestDispatch.jsp">
            			<c:param name="subjectUri" value="${param.subjectUri}"/>
            			<c:param name="predicateUri" value="${param.predicateUri}"/>
            			<c:param name="clearEditConfig" value="true"/>
        			</c:url>
        			<p>If you don't find the appropriate entry on the selection list,
        			<button type="button" onclick="javascript:document.location.href='${createNewUrl}'">create new ${rangeClassName}</button>
        			</p>
    			</c:if>
    		--%>
        </c:otherwise>
    </c:choose>
</form>

<jsp:include page="${postForm}"/>
