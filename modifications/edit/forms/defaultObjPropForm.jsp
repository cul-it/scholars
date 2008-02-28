<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ page import="java.util.Map" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils"%>
<%!

%>
<%
    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    // not yet fully set up for editing an existing object property statement by changing the related individual
    String objectUri = request.getParameter("objectUri");

    request.setAttribute("subjectUriJson",MiscWebUtils.escape(subjectUri));
    request.setAttribute("predicateUriJson",MiscWebUtils.escape(predicateUri));

    if( objectUri != null ){
        request.setAttribute("objectUriJson",MiscWebUtils.escape(objectUri));
    }

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
    ?subject ?predicate ?object.
    ?object ?inverse ?subject.
</v:jsonset>

<%
    /* get some data to make the form more useful */

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    ObjectProperty prop = wdf.getObjectPropertyDao().getObjectPropertyByURI(predicateUri);
    if( prop == null ) throw new Error("could not find property " + predicateUri);
    request.setAttribute("propertyName",prop.getDomainPublic());
    
    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    VClass rangeClass = wdf.getVClassDao().getVClassByURI(prop.getRangeVClassURI());
    request.setAttribute("rangeClassName", rangeClass.getName());
%>

<c:set var="editjson" scope="request">
  {
    "formUrl"                   : "${formUrl}",
    "editKey"                   : "${editKey}",

    "subjectUri"   : "${subjectUriJson}",
    "predicateUri" : "${predicateUriJson}",
    "objectUri"    : "${objectUriJson}",

    "n3required"                : [ "${n3ForEdit}" ],
    "n3optional"                : [ ],
    "newResources"              : { },
    "urisInScope"               : { "subject"   : "${subjectUriJson}",
                                    "predicate" : "${predicateUriJson}"},
    "literalsInScope"           : { },
    "objectVar"                 : "object",
    "urisOnForm"                : ["object"],
    "literalsOnForm"            : [ ],
    "sparqlForLiterals"         : { },
    "sparqlForUris"             : {"inverse" : "${queryForInverse}" },
    "entityToReturnTo"          : "${subjectUriJson}",
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris"     : { },
    "fields"                    : { "object" : {
                                       "newResource"      : "false",
                                       "queryForExisting" : { },
                                       "validators"       : [ ],
                                       "optionsType"      : "INDIVIDUALS_VIA_OBJECT_PROPERTY",
                                       "subjectUri"       : "${subjectUriJson}",
                                       "subjectClassUri"  : { },
                                       "predicateUri"     : "${predicateUriJson}",
                                       "objectClassUri"   : { },
                                       "literalOptions"   : [ ] ,
                                       "assertions"       : ["${n3ForEdit}"] 
                                     }
								  }
  }
</c:set>

<%  /* put edit configuration Json object into session */
    //EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session);
    //if( editConfig != null ){
        //EditConfiguration.clearAllConfigsInSession(session); // otherwise keeps using same predicate from fields
        
        EditConfiguration editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);
        /* this next section is the beginnings of being able to edit an existing statement -- have to figure */
        /* out how to select the right object individual, and if changed, how to delete the existing statement */
        /* and insert a new one */
        String formTitle   =""; // don't add local page variables to the request
        String submitLabel ="";
        if( objectUri != null ){     //these get done on an edit of an existing object property statement
            Model model =  (Model)application.getAttribute("jenaOntModel");
            prepareForEditOfExisting(editConfig,model,session);
            editConfig.getUrisInScope().put("newObject",objectUri); //makes sure we reuse objUri
            formTitle   = "Change value for &quot;"+prop.getDomainPublic()+"&quot; property for "+subject.getName();
            submitLabel = "save change";
        } else {
            formTitle   ="Select value for new &quot;"+prop.getDomainPublic()+"&quot; property for "+subject.getName();
            submitLabel ="save entry";
        }
    //}

%>

<jsp:include page="${preForm}"/>
  <h1><%=formTitle%></h1>
  <form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
	  <v:input type="select" id="object" label="object of property" /> 
      <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
      <v:input type="editKey" id="editKey"/>

      <c:if test="${hasCustomForm eq 'true'}">
          <p>If you don't find the appropriate entry on the selection list,
          <c:url var="createNewUrl" value="/edit/editRequestDispatch.jsp">
              <c:param name="subjectUri" value="${param.subjectUri}"/>
              <c:param name="predicateUri" value="${param.predicateUri}"/>
              <c:param name="clearEditConfig" value="true"/>
          </c:url>
          <button type="button" onclick="javascript:document.location.href='${createNewUrl}'">create new ${rangeClassName}</button>
          </p>
      </c:if>
      <!-- v:input type="cancel" id="cancel" cancel="${param.subjectUri}" / -->
  </form>
<jsp:include page="${postForm}"/>

<%!private void prepareForEditOfExisting( EditConfiguration editConfig, Model model, HttpSession session){
//        SparqlEvaluate sparqlEval = new SparqlEvaluate(model);
//        Map<String,String> varsToUris = sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForExistingUris(),
//                editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
//        Map<String,String> varsToLiterals = sparqlEval.sparqlEvaluateToLiterals(editConfig.getSparqlForExistingLiterals(),
//                editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
//        EditSubmission esub = new EditSubmission(editConfig);
//        esub.setUrisFromForm(varsToUris);
//        esub.setLiteralsFromForm(varsToLiterals);
//        EditSubmission.putEditSubmissionInSession(session,esub);
}%>