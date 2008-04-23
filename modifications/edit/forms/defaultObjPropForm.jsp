<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<%
    Individual subject = (Individual)request.getAttribute("subject");
    ObjectProperty prop = (ObjectProperty)request.getAttribute("predicate");

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    if( prop.getRangeVClassURI() == null )throw new Error("Property has null for its range class URI");

    VClass rangeClass = wdf.getVClassDao().getVClassByURI( prop.getRangeVClassURI());
    if( rangeClass == null ) throw new Error ("Cannot find class for range for property.  Looking for " + prop.getRangeVClassURI() );
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
                                       "rangeLang"        : "",
                                       "literalOptions"   : [ ] ,
                                       "assertions"       : ["${n3ForEdit}"]
                                     }
                                  }
  }
</c:set>

<%  /* now put edit configuration Json object into session */
    EditConfiguration editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
    EditConfiguration.putConfigInSession(editConfig, session);
    String formTitle   ="";
    String submitLabel ="";
    Model model = (Model)application.getAttribute("jenaOntModel");
    if( request.getAttribute("object") != null ){//this block is for an edit of an existing object property statement
        editConfig.prepareForObjPropUpdate( model );
        formTitle   = "Change entry for: <em>"+prop.getDomainPublic()+"</em>";
        submitLabel = "save change";
    } else {
        editConfig.prepareForNonUpdate( model );
        if ("true".equals((String)request.getAttribute("hasCustomForm"))) {
            formTitle   = "Create a new entry for "+subject.getName();
        } else {
            formTitle   =  "Add an entry to: <em>"+prop.getDomainPublic()+"</em>";
            submitLabel ="save entry";
        }
    }
%>
<jsp:include page="${preForm}"/>

<h2><%=formTitle%></h2>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <c:if test="${hasCustomForm eq 'true'}">
        <c:url var="createNewUrl" value="/edit/editRequestDispatch.jsp">
            <c:param name="subjectUri" value="${param.subjectUri}"/>
            <c:param name="predicateUri" value="${param.predicateUri}"/>
            <c:param name="clearEditConfig" value="true"/>
        </c:url>
    </c:if>
    <c:if test="${!empty predicate.example}">
    	<p>${predicate.example}</p>
    </c:if>
    <v:input type="editKey" id="editKey"/>
    <v:input type="select" id="objectVar" size="80" /><%--label="<%=rangeClass.getName()%>" --%>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
    <c:if test="${hasCustonForm eq 'true'}">
        <p>If you don't find the appropriate entry on the selection list,
        <button type="button"
        onclick="javascript:document.location.href='${createNewUrl}'">create
        new <%=rangeClass.getName()%>  </button>
        </p>
    </c:if>
</form>

<jsp:include page="${postForm}"/>
