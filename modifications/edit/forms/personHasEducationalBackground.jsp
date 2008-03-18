<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<%-- Enter here the class names to be used for constructing INDIVIDUALS_VIA_VCLASS pick lists
     These are then referenced in the field's ObjectClassUri but not elsewhere --%>
<v:jsonset var="educationalBackgroundClass">http://vivo.library.cornell.edu/ns/0.1#EducationalBackground</v:jsonset>
<v:jsonset var="degreeClass">http://vivo.library.cornell.edu/ns/0.1#AcademicDegree</v:jsonset>

<%--  Then enter a SPARQL query for each field, by convention concatenating the field id with "Existing"
      to convey that the expression is used to retrieve any existing value for the field in an existing individual.
      Each of these must then be referenced in the sparqlForExistingLiterals section of the JSON block below
      and in the literalsOnForm --%>
<v:jsonset var="yearExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?yearExisting
      WHERE {  ?edBackground vivo:yearDegreeAwarded ?yearExisting }
</v:jsonset>
<%--  Pair the "existing" query with the skeleton of what will be asserted for a new statement involving this field.
      The actual assertion inserted in the model will be created via string substitution into the ? variables.
      NOTE the pattern of punctuation (a period after the prefix URI and after the ?field) --%> 
<v:jsonset var="yearAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:yearDegreeAwarded ?year .
</v:jsonset>

<v:jsonset var="institutionExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?institutionExisting
      WHERE {  ?edBackground vivo:institutionAwardingDegree ?institutionExisting }
</v:jsonset>
<v:jsonset var="institutionAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:institutionAwardingDegree ?institution .
</v:jsonset>

<v:jsonset var="majorFieldExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?majorFieldExisting
      WHERE {  ?edBackground vivo:majorFieldOfDegree ?majorFieldExisting }
</v:jsonset>
<v:jsonset var="majorFieldAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:majorFieldOfDegree ?majorField .
</v:jsonset>

<v:jsonset var="visibilityExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?visibilityExisting
      WHERE {  ?edBackground vivo:ownerPublicVisibilityFlag ?visibilityExisting }
</v:jsonset>
<v:jsonset var="visibilityAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:ownerPublicVisibilityFlag ?visibility .
</v:jsonset>

<v:jsonset var="degreeAbbrevExisting" >
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?degreeAbbrevExisting
      WHERE {  ?edBackground vivo:preferredDegreeAbbreviation ?degreeAbbrevExisting }
</v:jsonset>
<v:jsonset var="degreeAbbrevAssertion" >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:preferredDegreeAbbreviation ?degreeAbbrev .
</v:jsonset>

<%--  Note there is really no difference in how things are set up for an object property except
      below in the n3ForEdit section, in whether the ..Existing variable goes in SparqlForExistingLiterals
      or in the SparqlForExistingUris, as well as perhaps in how the options are prepared --%>
<v:jsonset var="degreeTypeExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?degreeTypeExisting
      WHERE {  ?edBackground vivo:awardedAcademicDegree ?degreeTypeExisting }
</v:jsonset>
<v:jsonset var="degreeTypeAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
      ?edBackground vivo:awardedAcademicDegree ?degreeType .
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
          vivo:yearDegreeAwarded           ?year;
          vivo:institutionAwardingDegree   ?institution;
          vivo:preferredDegreeAbbreviation ?degreeAbbrev;
          vivo:majorFieldOfDegree          ?majorField;
          vivo:ownerPublicVisibilityFlag   ?visibility.

    ?edBackground vivo:awardedAcademicDegree ?degreeType.
</v:jsonset>

<v:jsonset var="n3optional"  >
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
    ?edBackground vitro:description ?comment.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",

    "subject"   : ["person",    "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["edBackground", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ "${n3optional}" ],
    "newResources"  : { "edBackground" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : ["degreeType"],
    "literalsOnForm" :  [ "year", "institution", "degreeAbbrev", "majorField", "visibility", "comment" ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "year"              : "${yearExisting}",
        "institution"       : "${institutionExisting}",
        "majorField"        : "${majorFieldExisting}",
        "visibility"        : "${visibilityExisting}",
        "degreeAbbrev"      : "${degreeAbbrevExisting}" },
    "sparqlForExistingUris" : {
        "degreeType"        : "${degreeTypeExisting}",
    },
    "fields" : {
      "year" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${yearAssertion}" ]
      },
     "degreeType" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "${degreeClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${degreeTypeAssertion}" ]
      },
      "degreeAbbrev" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["A.B.","A.M.","B.A.","B.B.S.","B.C.L.","B.D.","B.Lit.","B.Litt.","B.L.L.","B.S.","B.Sc.","C.E.","Ch.E.",
                               "D.C.L.","D.D.","D.D.S.","D.Litt.","D.M.D.","D.S.","D.Sc.","D.V.M.","E.E.","J.D.","L.H.D.","L.L.D.",
                               "Lit.B.","Litt.D.","L.L.B.","M.A.","M.B.A.","M.C.E.","M.D.","M.E.","M.S.","M.Sc.","Mus.B.","Mus.D.",
                               "Ph.D.","Ph.G.","Sc.B.","S.T.B.","S.T.D.","V.S."],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${degreeAbbrevAssertion}" ]
      },

      "institution" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${institutionAssertion}" ]
      },
      "majorField" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : ["${majorFieldAssertion}"]
      },
      "visibility" : {
         "newResource"      : "false",
         "validators"       : [],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["true","false"],
         "subjectUri"       : "",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${visibilityAssertion}" ]
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
         "rangeLang"        : "",
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
    	request.setAttribute("title", "Edit educational background entry for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new educational background entry for " + subject.getName());
        submitLabel = "Create new educational background entry";
    }

%>

<jsp:include page="${preForm}"/>

<h2>${title}</h2>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="year" id="year" size="4"/>
    <v:input type="select" label="degree type" id="degreeType"/>
    <v:input type="select" label="abbreviation" id="degreeAbbrev"/>
    <v:input type="text" label="institution" id="institution" size="30" value="Cornell University"/>
    <v:input type="text" label="major field" id="majorField" size="30"/>
    <v:input type="radio" label="publicly visible" id="visibility" value="true"/>
    <v:input type="text" label="comment" id="comment" size="40"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>
