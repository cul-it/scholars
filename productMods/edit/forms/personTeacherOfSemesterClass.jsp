<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.DataPropertyDao" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ModelAccess"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.personTeacherOfSemesterCourse.jsp");
%>
<!-- PART A: Identify the vClass(es) of individuals related to the primary object via object properties -->
<v:jsonset var="semester_vClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>

<!-- PART B: For each of the data properties you will be saving, look up the datatypeURI and/or language -->
<%
	VitroRequest vreq = new VitroRequest(request);
	WebappDaoFactory wdf = vreq.getWebappDaoFactory();
	DataPropertyDao dpDao = wdf.getDataPropertyDao();

	String codePropUri = "http://vivo.library.cornell.edu/ns/0.1#classCourseCode4Digit";
	try {
    	request.setAttribute("code4digitRangeDatatypeUri",dpDao.getDataPropertyByURI(codePropUri).getRangeDatatypeURI());
	} catch (Exception ex) {
	   	log.error("could not find data property " + codePropUri);
	}
	

	String enrollmentPropUri = "http://vitro.mannlib.cornell.edu/ns/reporting#semesterClassEnrollment";
	try {
	    request.setAttribute("enrollmentRangeDatatypeUri",dpDao.getDataPropertyByURI(enrollmentPropUri).getRangeDatatypeURI());
	} catch (Exception ex) {
	    log.error("could not find data property " + enrollmentPropUri);
	}
	
%>

<!-- PART C: For each piece of information to be pre-populated on the form from existing data
     and assertions to be saved back to the data model, enter a SPARQL fragment
     that will be substituted using the respective var names.  Note that a period is required
     to terminate the @prefix statement of the assertion but not for the PREFIX statement used
     to retrieve an existing value. -->
<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingMoniker
      WHERE {  ?newSemesterClass vitro:moniker ?existingMoniker }
</v:jsonset>
<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newSemesterClass vitro:moniker ?moniker .
</v:jsonset>

<v:jsonset var="titleExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?existingTitle
      WHERE {  ?newSemesterClass rdfs:label ?existingTitle }
</v:jsonset>
<v:jsonset var="titleAssertion" >
      @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
      ?newSemesterClass rdfs:label ?title .
</v:jsonset>

<v:jsonset var="code4digitExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingCode4digit
      WHERE {  ?newSemesterClass vivo:classCourseCode4Digit  ?existingCode4digit }
</v:jsonset>
<v:jsonset var="code4digitAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
      ?newSemesterClass vivo:classCourseCode4Digit  ?code4digit .
</v:jsonset>

<v:jsonset var="descriptionExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?existingDescription
      WHERE {  ?newSemesterClass vitro:description ?existingDescription }
</v:jsonset>
<v:jsonset var="descriptionAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newSemesterClass vitro:description ?description .
</v:jsonset>

<v:jsonset var="semesterExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?existingSemester
      WHERE {  ?newSemesterClass vivo:classTaughtInSemester  ?existingSemester }
</v:jsonset>
<v:jsonset var="semesterAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
      ?newSemesterClass vivo:classTaughtInSemester  ?semester .
</v:jsonset>

<v:jsonset var="enrollmentExisting" >
      PREFIX reporting:  <http://vitro.mannlib.cornell.edu/ns/reporting#>
      SELECT ?existingEnrollment
      WHERE {  ?newSemesterClass reporting:semesterClassEnrollment  ?existingEnrollment }
</v:jsonset>
<v:jsonset var="enrollmentAssertion" >
      @prefix reporting:  <http://vitro.mannlib.cornell.edu/ns/reporting#>.
      ?newSemesterClass reporting:semesterClassEnrollment  ?enrollment .
</v:jsonset>

<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
    @prefix reporting: <http://vitro.mannlib.cornell.edu/ns/reporting#>.

    ?person vivo:teacherOfSemesterClass  ?newSemesterClass .
    ?newSemesterClass vivo:taughtByAcademicEmployee ?person .

    ?newSemesterClass rdf:type vivo:CornellSemesterClass .

    ?newSemesterClass
          vitro:moniker     ?moniker ;
          rdfs:label        ?title .

    ?newSemesterClass vivo:classTaughtInSemester ?semester .
</v:jsonset>

<v:jsonset var="n3optional"  >
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#> .
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#> .
    @prefix reporting: <http://vitro.mannlib.cornell.edu/ns/reporting#> .
    
    ?newSemesterClass vitro:description ?description .
    ?newSemesterClass vivo:classCourseCode4Digit ?code4digit .
    ?newSemesterClass reporting:semesterClassEnrollment ?enrollment .
</v:jsonset>


<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/entity",

    "subject"   : ["person",    "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["newSemesterClass", "${objectUriJson}", "URI"],
    
    "n3required"  : [ "${n3ForEdit}" ],
    "n3optional"  : [ "${n3optional}" ],
    "newResources"  : { "newSemesterClass" : "http://vivo.library.cornell.edu/ns/0.1#individual"},
    "urisInScope"     : { },
    "literalsInScope" : { },
    "urisOnForm"     : ["semester"],
    "literalsOnForm" : ["description", "title", "moniker", "enrollment", "code4digit" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris"     : { },
    "sparqlForExistingLiterals" : {
        "description" : "${descriptionExisting}",
        "title"       : "${titleExisting}",
        "moniker"     : "${monikerExisting}",
        "enrollment"  : "${enrollmentExisting}",
        "code4digit"  : "${code4digitExisting}"
    },
    "sparqlForExistingUris" : {
        "semester"    : "${semesterExisting}"
    },
    "fields" : {
      "title" : {
         "newResource"      : "false",
         "validators"       : ["nonempty"],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : ["${titleAssertion}"]
      },
      "code4digit" : {
         "newResource"      : "false",
         "validators"       : [],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${code4digitRangeDatatypeUri}",
         "rangeLang"        : "",
         "assertions"       : ["${code4digitAssertion}"]
      },
      "description" : {
         "newResource"      : "false",
         "validators"       : ["nonempty"],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "http://www.w3.org/2001/XMLSchema#string",
         "rangeLang"        : "",
         "assertions"       : ["${descriptionAssertion}"]
      },
      "moniker" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["1 credit course",
                               "1.5 credit course",
                               "2 credit course",
                               "3 credit course",
                               "1-3 credit course",
                               "4 credit course",
                               "5 credit course",
                               "6 credit course"],
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "http://www.w3.org/2001/XMLSchema#string",
         "rangeLang"        : "",
         "assertions"       : ["${monikerAssertion}"]
      },
      "semester" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${semester_vClass}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : ["${semesterAssertion}"]
      },
      "enrollment" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${enrollmentRangeDatatypeUri}",
         "rangeLang"        : "",
         "assertions"       : ["${enrollmentAssertion}"]
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
    <v:input type="select" label="semester" id="semester" multiple="multiple"/>
    <v:input type="text" label="course code (4-digit)" id="code4digit"/>
    <v:input type="radio" label="credit value" id="moniker"/>
    <v:input type="textarea" label="course description" id="description" rows="5"/>
    <v:input type="text" label="final enrollment" id="enrollment"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>


