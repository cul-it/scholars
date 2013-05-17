<%@ page import="com.hp.hpl.jena.rdf.model.Literal" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>


<%-- Enter here the class names to be used for constructing INDIVIDUALS_VIA_VCLASS pick lists
     These are then referenced in the field's ObjectClassUri but not elsewhere --%>
<v:jsonset var="internationalActivityClass">http://vivo.library.cornell.edu/ns/0.1#InternationalActivityResponse</v:jsonset>
<v:jsonset var="internationalRegionClass">http://vivo.library.cornell.edu/ns/0.1#InternationalGeographicalRegion</v:jsonset>
<v:jsonset var="personClass">http://www.aktors.org/ontology/portal#Person</v:jsonset>


<%--  Then enter a SPARQL query for each field, by convention concatenating the field id with "Existing"
      to convey that the expression is used to retrieve any existing value for the field in an existing individual.
      Each of these must then be referenced in the sparqlForExistingLiterals section of the JSON block below
      and in the literalsOnForm --%>
<v:jsonset var="startDateExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingStartDate
      WHERE {  ?activity vivo:timeIntervalResponseStartDate ?existingStartDate }
</v:jsonset>
<%--  Pair the "existing" query with the skeleton of what will be asserted for a new statement involving this field.
      The actual assertion inserted in the model will be created via string substitution into the ? variables.
      NOTE the pattern of punctuation (a period after the prefix URI and after the ?field) --%> 
<v:jsonset var="startDateAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
      ?activity vivo:timeIntervalResponseStartDate ?startDate .
</v:jsonset>

<v:jsonset var="endDateExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingEndDate
      WHERE {  ?activity vivo:timeIntervalResponseEndDate ?existingEndDate }
</v:jsonset>
<v:jsonset var="endDateAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
      ?activity vivo:timeIntervalResponseEndDate ?endDate .
</v:jsonset>

<v:jsonset var="descriptionExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingDescription
      WHERE {  ?activity vitro:description ?existingDescription }
</v:jsonset>
<v:jsonset var="descriptionAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?activity vitro:description ?description .
</v:jsonset>

<v:jsonset var="nameExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?existingName
      WHERE {  ?activity rdfs:label ?existingName }
</v:jsonset>
<v:jsonset var="nameAssertion" >
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
      ?activity rdfs:label ?name .
</v:jsonset>

<%--  Note there is really no difference in how things are set up for an object property except
      below in the n3ForEdit section, in whether the ..Existing variable goes in SparqlForExistingLiterals
      or in the SparqlForExistingUris, as well as perhaps in how the options are prepared --%>
<c:choose>
	<c:when test="${param.predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#hasInternationalActivity'}">
        <v:jsonset var="indirectObjExisting" >
            PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
            SELECT ?existingIndirectObj
            WHERE {  ?activity vivo:internationalGeographicFocus ?existingIndirectObj }
        </v:jsonset>
        <v:jsonset var="indirectObjAssertion" >
            @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
            ?activity vivo:internationalGeographicFocus ?indirectObj .
        </v:jsonset>
        <c:set var="indirectObjLabel" value="geographic region"/>
        <c:set var="indirectObjClass" value="${internationalRegionClass}"/>
        <v:jsonset var="n3ForEdit"  >
            @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#> .
            @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .

            ?subjIndiv vivo:hasInternationalActivity  ?activity .
            ?activity vivo:internationalActivityOf ?subjIndiv .
            ?activity rdf:type vivo:InternationalActivityResponse .
            ?activity
                rdfs:label                         ?name ;
                vivo:timeIntervalResponseStartDate    ?startDate ;
                vivo:internationalGeographicFocus  ?indirectObj .
            ?indirectObj vivo:focusOfInternationalActivity ?activity .
        </v:jsonset>
    </c:when>
    <c:when test="${param.predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#focusOfInternationalActivity'}">
        <v:jsonset var="indirectObjExisting" >
            PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
            SELECT ?existingIndirectObj
            WHERE {  ?activity vivo:internationalActivityOf ?existingIndirectObj }
        </v:jsonset>
        <v:jsonset var="indirectObjAssertion" >
            @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
            ?activity vivo:internationalActivityOf ?indirectObj .
        </v:jsonset>
        <c:set var="indirectObjLabel" value="person"/>
        <c:set var="indirectObjClass" value="${personClass}"/>
        <v:jsonset var="n3ForEdit"  >
            @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
            @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
            @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#> .
            @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .

            ?subjIndiv vivo:focusOfInternationalActivity  ?activity .
            ?activity vivo:internationalGeographicFocus ?subjIndiv .
            ?activity rdf:type vivo:InternationalActivityResponse .
            ?activity
                rdfs:label                         ?name ;
                vivo:timeIntervalResponseStartDate ?startDate ;
                vivo:internationalActivityOf       ?indirectObj .
            ?indirectObj vivo:hasInternationalActivity ?activity .
        </v:jsonset>
    </c:when>
    <c:otherwise>
        throw new Error("predicateUri not matched: "+${predicateUriJson});        
    </c:otherwise>
</c:choose>

<v:jsonset var="n3optional1"  >
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
    ?activity vitro:description ?description .
</v:jsonset>
<v:jsonset var="n3optional2"  >
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
    ?activity vivo:timeIntervalResponseEndDate ?endDate .
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/entity",

    "subject"   : ["subjIndiv", "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["activity",  "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ "${n3optional1}", "${n3optional2}" ],
    "newResources"  : { "activity" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : ["indirectObj"],
    "literalsOnForm" :  [ "name", "description", "startDate", "endDate" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "name"              : "${nameExisting}",
        "description"       : "${descriptionExisting}",
        "startDate"         : "${startDateExisting}",
        "endDate"           : "${endDateExisting}"
    },
    "sparqlForExistingUris" : {
        "indirectObj"       : "${indirectObjExisting}"
    },
    "fields" : {
      "name" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "http://www.w3.org/2001/XMLSchema#string",
         "rangeLang"        : "",
         "assertions"       : [ "${yearAssertion}" ]
      },
      "indirectObj" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${indirectObjClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${indirectObjAssertion}" ]
      },
      "startDate" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${startDateAssertion}" ]
      },
      "endDate" : {
         "newResource"      : "false",
         "validators"       : [],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",         
         "assertions"       : [ "${endDateAssertion}" ]
      },
      "description" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "http://www.w3.org/2001/XMLSchema#string",
         "rangeLang"        : "",         
         "assertions"       : ["${descriptionAssertion}"]
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

    Model model = ModelAccess.on(application).getJenaOntModel();
    String objectUri = (String)request.getAttribute("objectUri");    
    if( objectUri != null ){        
        editConfig.prepareForObjPropUpdate(model);            
    }else{
        editConfig.prepareForNonUpdate(model);
    }

    /* get some data to make the form more useful */
    Individual subject = (Individual)request.getAttribute("subject");

    String submitLabel=""; // don't put local variables into the request
    /* title is used by pre and post form fragments */
    if (objectUri != null) {
    	request.setAttribute("title", "Edit international activity entry for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new international activity entry for " + subject.getName());
        submitLabel = "Create new international activity entry";
    }

%>

<jsp:include page="${preForm}">
	<jsp:param name="useTinyMCE" value="true"/>
</jsp:include>

<h2>${title}</h2>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="title for activity" id="name" size="30"/>
    <v:input type="select" label="${indirectObjLabel}" id="indirectObj"/>
    <v:input type="text" label="start year" id="startDate" size="4" value=""/>
    <v:input type="text" label="end year" id="endDate" size="4" value=""/>
    <v:input type="textarea" label="description" id="description" rows="2"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>
