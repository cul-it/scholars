<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<v:jsonset var="semesterClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>
<v:jsonset var="buildingClass">http://vivo.library.cornell.edu/ns/0.1#Building</v:jsonset>
<v:jsonset var="degreeClass">http://vivo.library.cornell.edu/ns/0.1#AcademicDegree</v:jsonset>

<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingMoniker
      WHERE {  ?newCourse vitro:moniker ?existingMoniker }
</v:jsonset>
<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?newCourse vitro:moniker ?moniker .
</v:jsonset>

<v:jsonset var="titleExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?existingTitle
      WHERE {  ?newCourse rdfs:label ?existingTitle }
</v:jsonset>
<v:jsonset var="titleAssertion" >
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
      ?newCourse rdfs:label ?title .
</v:jsonset>

<v:jsonset var="descriptionExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?desc
      WHERE {  ?newCourse vitro:description ?desc }
</v:jsonset>
<v:jsonset var="descriptionAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?newCourse vitro:description ?eescription .
</v:jsonset>

<v:jsonset var="roomExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingRoom
      WHERE {  ?newCourse vivo:eventHeldInFacility ?existingRoom }
</v:jsonset>
<v:jsonset var="roomAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#> .
      ?newCourse vivo:eventHeldInFacility ?room .
</v:jsonset>

<v:jsonset var="semesterExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingSemester
      WHERE {  ?newCourse vivo:SemesterCourseOccursInSemester  ?existingSemester }
</v:jsonset>
<v:jsonset var="semesterAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
      ?newCourse vivo:SemesterCourseOccursInSemester  ?semester .
</v:jsonset>

<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.

    ?person vivo:PersonTeacherOfSemesterCourse  ?newCourse.
    ?newCourse vivo:SemesterCourseHasTeacherPerson ?person.

    ?newCourse rdf:type vivo:CornellSemesterCourse.

    ?newCourse
          vitro:moniker     ?moniker ;
          vitro:description ?description ;
          rdfs:label        ?title .

    ?newCourse vivo:SemesterCourseOccursInSemester ?semester.
</v:jsonset>

<v:jsonset var="n3optional"  >
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    ?newCourse vivo:eventHeldInFacility ?heldIn.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/entity",

    "subject"   : ["person",    "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["newCourse", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ "${n3optional}" ],
    "newResources"  : { "newCourse" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : ["semester","room"],
    "literalsOnForm" : [ "description", "title", "moniker" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : { },
    "sparqlForExistingLiterals" : {
        "description"       : "${descriptionExisting}",
        "title"             : "${titleExisting}",
        "moniker"           : "${monikerExisting}" 
    },
    "sparqlForExistingUris" : {
        "room"              : "${roomExisting}",
        "semester"          : "${semesterExisting}"
    },
    "fields" : {
      "title" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${titleAssertion}" ]
      },
     "description" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${descriptionAssertion}" ]
      },
      "moniker" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["1 credit course",
                               "2 credit course",
                               "3 credit course",
                               "4 credit course",
                               "5 credit course",
                               "6 credit course",
                               "1-3 credit course",
                               "1.5 credit course"],
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${monikerAssertion}" ]
      },
      "semester" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${semesterClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${semesterAssertion}"]
      },
      "room" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : ["leave blank"],
         "predicateUri"     : "",
         "objectClassUri"   : "${buildingClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${roomAssertion}" ]
      }
    }
  }
</c:set>

<%
    System.out.println( request.getAttribute("editjson") );
    
    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if( editConfig == null ){
        editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);
    }

    String objectUri = (String)request.getAttribute("objectUri");
    Model model = ModelAccess.on(application).getJenaOntModel();
    if( objectUri != null ){            
        editConfig.prepareForObjPropUpdate( model);
    }else{
        editConfig.prepareForNonUpdate( model );
    }

    /* get some data to make the form more useful */
    Individual subject = (Individual)request.getAttribute("subject");

    String submitLabel=""; // don't put local variables into the request
    /* title is used by pre and post form fragments */
    if (objectUri != null) {
    	request.setAttribute("title", "Edit course for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new course for " + subject.getName());
        submitLabel = "Create new course";
    }

%>

<jsp:include page="${preForm}"/>

<h2>${title}</h2>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="course title" id="title" size="60"/>
    <v:input type="checkbox" label="semester" id="semester"/>
    <v:input type="select" label="held in location" id="room"/>
    <v:input type="radio" label="credit value" id="moniker"/>
    <v:input type="textarea" label="course description" id="description" rows="5"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>


