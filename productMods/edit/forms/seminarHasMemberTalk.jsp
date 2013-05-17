<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<v:jsonset var="semesterClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>
<v:jsonset var="roomClass">http://vivo.library.cornell.edu/ns/0.1#RoomOrHall</v:jsonset>
<v:jsonset var="talkClass">http://vivo.library.cornell.edu/ns/0.1#LectureSeminarOrColloquium</v:jsonset>
<v:jsonset var="heldInObjProp">http://vivo.library.cornell.edu/ns/0.1#eventHeldInFacility</v:jsonset>

<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingMoniker
      WHERE { ?newTalk vitro:moniker ?existingMoniker }
</v:jsonset>
<v:jsonset var="titleExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?existingTitle
      WHERE { ?newTalk rdfs:label ?existingTitle }
</v:jsonset>
<v:jsonset var="blurbExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingBlurb
      WHERE { ?newTalk vitro:blurb ?existingBlurb }
</v:jsonset>
<v:jsonset var="roomExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingRoom
      WHERE { ?newTalk vivo:eventHeldInFacility ?existingRoom }
</v:jsonset>
<v:jsonset var="timekeyExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingTimekey
      WHERE { ?newTalk vitro:timekey ?existingTimekey } 
</v:jsonset>

<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?newTalk vitro:moniker ?assertedMoniker .
</v:jsonset>
<v:jsonset var="titleAssertion" >
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
      ?newTalk rdfs:label ?assertedTitle .
</v:jsonset>
<v:jsonset var="blurbAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?newTalk vitro:blurb ?assertedBlurb .
</v:jsonset>
<v:jsonset var="roomAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#> .
      ?newTalk vivo:eventHeldInFacility ?assertedRoom .
</v:jsonset>
<v:jsonset var="timekeyAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
      ?newTalk vitro:timekey ?assertedTimekey .
</v:jsonset>


<v:jsonset var="n3ForEdit"  >
      @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .

      ?series vivo:seminarOrLectureSeriesHasMemberTalk  ?newTalk .
      ?newTalk   vivo:talkMemberOfSeminarOrLectureSeries ?series .

      ?newTalk rdf:type vivo:LectureSeminarOrColloquium .

      ?newTalk
          vitro:moniker     ?assertedMoniker ;
          vitro:blurb       ?assertedBlurb ;
          rdfs:label        ?assertedTitle ;
          vitro:timekey     ?assertedTimekey .
</v:jsonset>

<v:jsonset var="n3optional"  >
      @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
      ?newTalk vivo:eventHeldInFacility ?assertedRoom .
      ?assertedRoom vivo:facilityForEvent ?newTalk .
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/entity",

    "subject"   : ["series",    "${subjectUriJson}", ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["newTalk", "${objectUriJson}", "URI" ],
    
    "n3required"                : [ "${n3ForEdit}" ],
    "n3optional"                : [ "${n3optional}" ],
    "newResources"              : { "newTalk" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"               : { },
    "literalsInScope"           : { },
    "urisOnForm"                : [ "assertedRoom" ],
    "literalsOnForm"            : [ "assertedBlurb", "assertedTitle", "assertedMoniker", "assertedTimekey" ],
    "filesOnForm"               : [ ],
    "sparqlForLiterals"         : { },
    "sparqlForUris"             : { },
    "sparqlForExistingLiterals" : {
        "assertedBlurb"         : "${blurbExisting}",
        "assertedTitle"         : "${titleExisting}",
        "assertedMoniker"       : "${monikerExisting}"
    },
    "sparqlForExistingUris"     : {
        "assertedRoom"          : "${roomExisting}",
    },
    "fields" : {
        "assertedTitle" : {
            "newResource"       : "false",
            "validators"        : [ "nonempty" ],
            "optionsType"       : "UNDEFINED",
            "literalOptions"    : [],
            "subjectUri"        : "${param.subjectUri}",
            "subjectClassUri"   : "",
            "predicateUri"      : "",
            "objectClassUri"    : "",
            "rangeDatatypeUri"  : "",
            "rangeLang"         : "",
            "assertions"        : [ "${titleAssertion}" ]
        },
        "assertedBlurb" : {
            "newResource"       : "false",
            "validators"        : [ "nonempty" ],
            "optionsType"       : "UNDEFINED",
            "literalOptions"    : [],
            "subjectUri"        : "${param.subjectUri}",
            "subjectClassUri"   : "",
            "predicateUri"      : "",
            "objectClassUri"    : "",
            "rangeDatatypeUri"  : "",
            "rangeLang"         : "",
            "assertions"        : [ "${blurbAssertion}" ]
        },
        "assertedMoniker" : {
            "newResource"       : "false",
            "validators"        : [ ],
            "optionsType"       : "STRINGS_VIA_DATATYPE_PROPERTY",
            "literalOptions"    : [],
            "subjectUri"        : "${param.subjectUri}",
            "subjectClassUri"   : "",
            "predicateUri"      : "${param.predicateUri}",
            "objectClassUri"    : "",
            "rangeDatatypeUri"  : "",
            "rangeLang"         : "",
            "assertions"        : [ "${monikerAssertion}" ]
        },
            "assertedRoom" : {
            "newResource"       : "false",
            "validators"        : [ ],
            "optionsType"       : "INDIVIDUALS_VIA_OBJECT_PROPERTY",
            "literalOptions"    : [" (none)"],
            "subjectUri"        : "${param.subjectUri}",
            "subjectClassUri"   : "",
            "predicateUri"      : "${heldInObjProp}",
            "objectClassUri"    : "${buildingClass}",
            "rangeDatatypeUri"  : "",
            "rangeLang"         : "",
            "assertions"        : [ "${roomAssertion}" ]
        } ,
            "assertedTimekey"   : {
            "newResource"       : "false",
            "validators"        : [ ],
            "optionsType"       : "UNDEFINED",
            "literalOptions"    : [],
            "subjectUri"        : "${param.subjectUri}",
            "subjectClassUri"   : "",
            "predicateUri"      : "",
            "objectClassUri"    : "",
            "rangeDatatypeUri"  : "",
            "rangeLang"         : "",
            "assertions"        : [ "${timeKeyAssertion}" ]
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
    OntModel model = ModelAccess.on(getServletContext()).getJenaOntModel();
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
    <v:input type="text" label="seminar title" id="assertedTitle" size="60"/>
    <% System.out.println("in seminarHasMemberTalk.jsp A"); %>
    <v:input type="select" label="held in room" id="assertedRoom"/>
    <% System.out.println("in seminarHasMemberTalk.jsp B"); %>
    <v:input type="text" label="type of talk" id="assertedMoniker"/>
    <% System.out.println("in seminarHasMemberTalk.jsp B2"); %>
    <v:input type="datetime" label="date and time" id="assertedTimekey"/>
    <% System.out.println("in seminarHasMemberTalk.jsp C "); %>
    <v:input type="textarea" label="seminar description" id="assertedBlurb" rows="5"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>
<% System.out.println("in seminarHasMemberTalk.jsp D"); %>




