<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%
    
    String subjectUri = request.getParameter("subjectUri");
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));

    String objectUri = request.getParameter("objectUri");
    if( objectUri != null){   //here we fill out urisInScope with an existing uri for edit, notice the need for the comma
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
<v:jsonset var="pubYearExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?yearEx
      WHERE {  ?newPub vivo:publicationYear ?yearEx }
</v:jsonset>

<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newPub vitro:moniker ?moniker .
</v:jsonset>
<v:jsonset var="pubNameAssertion" >
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    ?newPub rdfs:label ?name .
</v:jsonset>
<v:jsonset var="pubDescriptionAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newPub vitro:description ?desc .
</v:jsonset>
<v:jsonset var="pubYearAssertion" >
  @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
  ?newPub vitro:publicationYear ?year .
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
          vivo:publicationYear ?pubYear;
          rdfs:label        ?pubName.
</v:jsonset>

<c:set var="editjson" scope="session">
  {
    "formUrl" : "${formUrl}",
    "editKey"  : "${editKey}",

    "subject"   : [ "person",    "${subjectUriJson}"],
    "predicate" : [ "predicate", "${predicateUriJson}"],
    "object"    : [ "newPub" ,   "${objectUriJson}" , "URI" ],
      
    "datapropKey"  : "",
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ ],
    "newResources"  : { "newPub" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"   : { },
    "literalsInScope": { },
    "urisOnForm"    : [ ],
    "literalsOnForm":  [ "pubDescription", "pubName", "moniker" ,"pubYear"],
    "filesOnForm"   : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris":{  },
    
    "sparqlForExistingLiterals":{
        "pubDescription" : "${pubDescExisting}",
        "pubName"        : "${pubNameExisting}",
        "moniker"        : "${monikerExisting}",
        "pubYear"        : "${pubYearExisting}"  },
    "sparqlForExistingUris": { },
    
   
    "fields" : {
      "moniker" : {
         "newResource"      : "false",
         "type"             : "select",
         "queryForExisting" : { },
         "validators"       : [ ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["journal article","book chapter","review","editorial","exhibit catalog"],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : ["${monikerAssertion}"]
      },
      "pubName" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${pubNameAssertion}" ]
      },
         "pubDescription" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${pubDescriptionAssertion}" ]
      },
      "pubYear" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${pubYearAssertion}" ]
      }
    }
  }
</c:set>
<%
    //EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session);
    //if( editConfig == null ){

        EditConfiguration editConfig = new EditConfiguration((String)session.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);
            
        Model model =  (Model)application.getAttribute("jenaOntModel");
        if( objectUri != null ){            
            editConfig.prepareForObjPropUpdate( model);
        }else{
            editConfig.prepareForNonUpdate( model );
        }
            
    //}

    /* get some data to make the form more useful */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    String personUri = editConfig.getUrisInScope().get("person");
    Individual subject = wdf.getIndividualDao().getIndividualByURI(personUri);
    if( subject == null ) throw new Error("could not find subject '" + personUri + "'");
    request.setAttribute("subjectName",subject.getName());
    /* title is used by pre and post form fragments */
    String submitLabel=""; // don't put local variables into the request
    if (objectUri != null) {
    	request.setAttribute("title", "Edit publication for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new publication for " + subject.getName());
        submitLabel = "Create new publication";
    }
%>

<jsp:include page="${preForm}"/>

<h2>${title}</h2>

<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text"  label="Title" id="pubName" size="70" />
    <v:input type="text"  label="year"  id="pubYear" size="4" />
    <v:input type="radio" label="Publication Type" id="moniker" />
    <v:input type="textarea" label="Bibliographic Citation" id="pubDescription" rows="5" />
    <v:input type="submit"  id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}" />
</form>

<jsp:include page="${postForm}"/>

