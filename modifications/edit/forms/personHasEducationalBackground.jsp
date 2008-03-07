<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<v:jsonset var="educationalBackgroundClass">http://vivo.library.cornell.edu/ns/0.1#EducationalBackground</v:jsonset>
<v:jsonset var="degreeClass">http://vivo.library.cornell.edu/ns/0.1#AcademicDegree</v:jsonset>
<v:jsonset var="degreePredicate">http://vivo.library.cornell.edu/ns/0.1#awardedAcademicDegree</v:jsonset>


<v:jsonset var="yearExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?yearExisting
      WHERE {  ?edBackground vivo:yearDegreeAwarded ?yearExisting }
</v:jsonset>
<v:jsonset var="yearAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:yearDegreeAwarded ?year.
</v:jsonset>

<v:jsonset var="institutionExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?institutionExisting
      WHERE {  ?edBackground vivo:institutionAwardingDegree ?institutionExisting }
</v:jsonset>
<v:jsonset var="institutionAssertion" >
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    ?edBackground vivo:institutionAwardingDegree ?institution.
</v:jsonset>

<v:jsonset var="majorFieldExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?majorFieldExisting
      WHERE {  ?edBackground vivo:majorFieldOfDegree ?majorFieldExisting }
</v:jsonset>
<v:jsonset var="majorFieldAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:majorFieldOfDegree ?majorField.
</v:jsonset>

<v:jsonset var="degreeExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?degreeExisting
      WHERE {  ?edBackground vivo:awardedAcademicDegree ?degreeExisting }
</v:jsonset>
<v:jsonset var="degreeAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:awardedAcademicDegree ?degree.
</v:jsonset>


<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.

    ?person vivo:hasEducationalBackground  ?edBackground.
    ?edBackground vivo:educationalBackgroundOf ?person.

    ?edBackground rdf:type vivo:EducationalBackground.

    ?edBackground
          vivo:year        ?year;
          vivo:institution ?institution;
          vivo:majorField  ?majorField.

    ?edBackground vivo:awardedAcademicDegree ?degree.
</v:jsonset>

<v:jsonset var="n3optional"  >
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
    ?edBackground vitro:description ?comment.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",

    "subject"   : ["person",    "${subjectUriJson}", ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["edBackground", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ "${n3optional}" ],
    "newResources"  : { "edBackground" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : ["degree"],
    "literalsOnForm" :  [ "year", "institution", "majorField", "comment" ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "year"              : "${yearExisting}",
        "institution"       : "${institutionExisting}",
        "majorField"        : "${majorFieldExisting}" },
    "sparqlForExistingUris" : {
        "degree"            : "${degreeExisting}",
    },
    "fields" : {
      "year" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "assertions"       : [ "${yearAssertion}" ]
      },
     "degree" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "INDIVIDUALS_VIA_OBJECT_PROPERTY",
         "literalOptions"   : [],
         "subjectUri"       : "${objectUriJson}",
         "subjectClassUri"  : "",
         "predicateUri"     : "${degreePredicate}",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "assertions"       : [ "${degreeAssertion}" ]
      },
      "institution" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "assertions"       : [ "${institutionAssertion}" ]
      },
      "majorField" : {
         "newResource"      : "false",
         "validators"       : [],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "assertions"       : ["${majorFieldAssertion}"]
      },
      "comment" : {
         "newResource"      : "false",
         "validators"       : [],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "assertions"       : [ "${commentAssertion}" ]
      }
    }
  }
</c:set>
<%
    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if( editConfig == null ){
        editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);
    }

    String objectUri = (String)request.getAttribute("objectUri");
    if( objectUri != null ){
        Model model =  (Model)application.getAttribute("jenaOntModel");
        //prepareForEditOfExisting(editConfig, model, request, session);
        editConfig.prepareForUpdate(request,model);
    }

    /* get some data to make the form more useful */
    Individual subject = (Individual)request.getAttribute("subject");

    String submitLabel=""; // don't put local variables into the request
    /* title is used by pre and post form fragments */
    if (objectUri != null) {
    	request.setAttribute("title", "Edit educational background for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new educational background entry for " + subject.getName());
        submitLabel = "Create new educational background entry";
    }

%>

<jsp:include page="${preForm}"/>

<h1>${title}</h1>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="year" id="year" size="4"/>
    <v:input type="select" label="degree" id="degree"/>
    <v:input type="text" label="institution" id="institution"/>
    <v:input type="text" label="major field" id="majorField"/>
    <v:input type="text" label="comment" id="comment"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>"/>
</form>

<jsp:include page="${postForm}"/>
