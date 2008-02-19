<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%
    
    String v = request.getParameter("subjectUri");
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(v));

    String objectUri = request.getParameter("objectUri");
    if( v != null){   //here we fill out urisInScope with an existing uri for edit, notice the need for the comma
        request.setAttribute("objectUriJson", MiscWebUtils.escape(objectUri));
        request.setAttribute("existingUris", ",\"newPub\": \""+MiscWebUtils.escape(objectUri)+"\"");
    }else{
        request.setAttribute("existingUris","");  //since its a new insert, no existing uri
    }

    request.getSession(true);
%>

<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?moniker
      WHERE {  ?newPub vitro:moniker ?moniker }
</v:jsonset>
<v:jsonset var="pubNameExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?name
      WHERE {  ?newPub rdfs:label ?name }
</v:jsonset>
<v:jsonset var="pubDescExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?desc
      WHERE {  ?newPub vitro:description ?desc }
</v:jsonset>

<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.

    ?person vivo:authorOf  ?newPub.
    ?newPub vivo:hasAuthor ?person.

    ?newPub rdf:type vivo:RecentJournalArticle.

    ?newPub
          vitro:moniker     ?moniker;
          vitro:description ?pubDescription;
          rdfs:label        ?pubName.
</v:jsonset>

<c:set var="editjson" scope="session">
  {
    "formUrl" : "${formUrl}",
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ ],
    "newResources"  : { "newPub" : "default" },
    "urisInScope"   : {"person" : "${subjectUriJson}"
                       ${existingUris} },
    "literalsInScope": { },
    "urisOnForm"    : [ ],
    "literalsOnForm":  [ "pubDescription", "pubName", "moniker" ],
    "sparqlForLiterals" : { },
    "sparqlForUris":{  },
    "entityToReturnTo" : "${subjectUriJson}" ,
    "basicValidators" : {"pubName" : ["nonempty" ],
                         "pubDescription" : ["nonempty" ]  }  ,
    "sparqlForExistingLiterals":{
        "pubDescription" : "${pubDescExisting}",
        "pubName"        : "${pubNameExisting}",
        "moniker"        : "${monikerExisting}" },
    "sparqlForExistingUris": { },
    "optionsForFields" : { },
    "fields" : {
      "moniker" : {
         "newResource"      : "false",
         "type"             : "select",
         "queryForExisting" : { },
         "validators"       : [ ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["journal article","book chapter","review","editorial","exhibit catalog"],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : { }
      }
    }
  }
</c:set>
<%
    //EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session);
    //if( editConfig == null ){
        EditConfiguration.clearConfigInSession(session); // otherwise keeps using same predicate from fields
        EditConfiguration editConfig = new EditConfiguration((String)session.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);
        if( objectUri != null ){     //these get done on a edit of an existing entity.
            Model model =  (Model)application.getAttribute("jenaOntModel");
            prepareForEditOfExisting(editConfig,model,session);
            editConfig.getUrisInScope().put("newPub",objectUri); //makes sure we reuse objUri 
        }
    //}

    /* get some data to make the form more useful */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    String personUri = editConfig.getUrisInScope().get("person");
    Individual subject = wdf.getIndividualDao().getIndividualByURI(personUri);
    if( subject == null ) throw new Error("could not find subject '" + personUri + "'");
    request.setAttribute("subjectName",subject.getName());

    /* these are used by pre and post form fragements */
    request.setAttribute("title", "create a new publication for " + subject.getName());
%>

<jsp:include page="${preForm}"/>

		<h1>Create a new publication</h1>

        <form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
        	<!-- dt and dd tags activated in InputElementFormattingTag.java by default -->
			<v:input type="text" label="Title" id="pubName" size="70" />
			<v:input type="select" label="Publication Type" id="moniker" />
			<v:input type="textarea" label="Bibliographic Citation" id="pubDescription" rows="5" />
			<!-- v:input tag for submit buttons coming soon -->
			<p>
				<c:url value="/entity" var="editCancel" >
				<c:param name="uri" value="${param.subjectUri}"/>
				</c:url>
				<input type="submit" value="Create new publication"/> or <a class="cancel" href="${editCancel}" title="Cancel">Cancel</a>
			</p>
        </form>

<jsp:include page="${postForm}"/>

 <%!private void prepareForEditOfExisting( EditConfiguration editConfig, Model model, HttpSession session){
        SparqlEvaluate sparqlEval = new SparqlEvaluate(model);
        Map<String,String> varsToUris =   sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForExistingUris(),
                editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
        Map<String,String> varsToLiterals =   sparqlEval.sparqlEvaluateToLiterals(editConfig.getSparqlForExistingLiterals(),
                editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
        EditSubmission esub = new EditSubmission(editConfig);
        esub.setUrisFromForm(varsToUris);
        esub.setLiteralsFromForm(varsToLiterals);
        EditSubmission.putEditSubmissionInSession(session,esub);
}%>