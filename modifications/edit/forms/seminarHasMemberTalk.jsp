<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<v:jsonset var="semesterClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>
<v:jsonset var="roomClass">http://vivo.library.cornell.edu/ns/0.1#RoomOrHall</v:jsonset>
<v:jsonset var="talkClass">http://vivo.library.cornell.edu/ns/0.1#LectureSeminarOrColloquium</v:jsonset>
<v:jsonset var="heldInObjProp">http://vivo.library.cornell.edu/ns/0.1#eventHeldInFacility</v:jsonset>

<v:jsonset var="talkMonikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingMoniker
      WHERE {  ?talk vitro:moniker ?existingMoniker }
</v:jsonset>
<v:jsonset var="talkNameExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?name
      WHERE {  ?talk rdfs:label ?name }
</v:jsonset>
<v:jsonset var="talkBlurbExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?blurb
      WHERE {  ?talk vitro:blurb ?blurb }
</v:jsonset>
<v:jsonset var="talkHeldInExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?extBuilding
      WHERE {  ?talk vivo:eventHeldInFacility ?extBuilding }
</v:jsonset>
<v:jsonset var="talkTimekeyExisting" >
    PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
    SELECT ?time
    WHERE { ?talk vitro:timekey ?time } 
</v:jsonset>

<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?talk vitro:moniker ?moniker .
</v:jsonset>
<v:jsonset var="talkNameAssertion" >
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    ?talk rdfs:label ?talkName .
</v:jsonset>
<v:jsonset var="talkBlurbAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?talk vitro:blurb ?talkBlurb  .
</v:jsonset>
<v:jsonset var="talkHeldInAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
    ?talk vivo:eventHeldInFacility ?room .
</v:jsonset>
<v:jsonset var="talkTimekeyAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?talk vitro:timekey ?talkTimekey  .
</v:jsonset>


<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.

    ?series vivo:seminarOrLectureSeriesHasMemberTalk  ?talk.
    ?talk   vivo:talkMemberOfSeminarOrLectureSeries ?series.

    ?talk rdf:type vivo:LectureSeminarOrColloquium .

    ?talk
          vitro:moniker     ?moniker;
          vitro:description ?talkDescription;
          rdfs:label        ?talkName;
          vitro:timekey     ?timekey.
</v:jsonset>

<v:jsonset var="n3optional"  >
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    ?talk vivo:eventHeldInFacility ?room .
    ?room vivo:facilityForEvent ?talk .
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",

    "subject"   : ["series",    "${subjectUriJson}", ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["talk", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ "${n3optional}" ],
    "newResources"  : { "talk" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : ["room"],
    "literalsOnForm" :  [ "talkDescription", "talkName", "moniker", "timekey" ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "talkDescription" : "${talkBlurbExisting}",
        "talkName"        : "${talkNameExisting}",
        "moniker"         : "${talkMonikerExisting}" },
    "sparqlForExistingUris" : {
        "room"            : "${talkHeldInExisting}",
    },
    "fields" : {
      "talkName" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${talkNameAssertion}" ]
      },

     "talkBlurb" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${talkBlurbAssertion}" ]
      },
      "moniker" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "STRINGS_VIA_DATATYPE_PROPERTY",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : "",
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${monikerAssertion}" ]
      },
      "room" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_OBJECT_PROPERTY",
         "literalOptions"   : [" (none)"],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : "",
         "predicateUri"     : "${heldInObjProp}",
         "objectClassUri"   : "${buildingClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${talkHeldInAssertion}" ]
      } ,
       "timekey" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : "",
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${talkTimeKeyAssertion}" ]
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
    Model model =  (Model)application.getAttribute("jenaOntModel");
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
    	request.setAttribute("title", "Edit Seminar for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new Seminar for " + subject.getName());
        submitLabel = "Create new seminar";
    }

%>

<jsp:include page="${preForm}"/>

<h1>${title}</h1>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="seminar title" id="talkName" size="60"/>
    <% System.out.println("in seminarHasMemberTalk.jsp A"); %>
    <v:input type="select" label="held in room" id="room"/>
    <% System.out.println("in seminarHasMemberTalk.jsp B"); %>
    <v:input type="text" label="moniker " id="moniker"/>
    <% System.out.println("in seminarHasMemberTalk.jsp B2"); %>
    <v:input type="datetime" label="date and time" id="timekey"/>
    <% System.out.println("in seminarHasMemberTalk.jsp C "); %>
    <v:input type="textarea" label="seminar description" id="talkDescription" rows="5"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>
<% System.out.println("in seminarHasMemberTalk.jsp D"); %>




