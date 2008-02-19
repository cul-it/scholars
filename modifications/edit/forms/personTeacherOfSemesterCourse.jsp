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
    String subjectUri   = request.getParameter("subjectUri");
    String v = request.getParameter("subjectUri");
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(v));

    String objectUri = request.getParameter("objectUri");
    if( v != null){
        request.setAttribute("objectUriJson", MiscWebUtils.escape(objectUri));
        request.setAttribute("existingUris", ",\"newCourse\": \""+MiscWebUtils.escape(objectUri)+"\"");
    }else{
        request.setAttribute("existingUris","");  //since its a new insert, no existing uri
    }

    request.getSession(true);
%>
<v:jsonset var="semesterClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>
<v:jsonset var="buildingClass">http://vivo.library.cornell.edu/ns/0.1#Building</v:jsonset>

<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?moniker
      WHERE {  ?newCourse vitro:moniker ?moniker }
</v:jsonset>
<v:jsonset var="courseNameExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?name
      WHERE {  ?newCourse rdfs:label ?name }
</v:jsonset>
<v:jsonset var="courseDescExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?desc
      WHERE {  ?newCourse vitro:description ?desc }
</v:jsonset>
<v:jsonset var="courseHeldInExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?extBuilding
      WHERE {  ?newCourse vivo:eventHeldInFacility ?extBuilding }
</v:jsonset>
<v:jsonset var="courseSemesterExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?extSem
      WHERE {  ?newCourse vivo:SemesterCourseOccursInSemester  ?extSem }
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
          vitro:moniker     ?moniker;
          vitro:description ?courseDescription;
          rdfs:label        ?courseName.

    ?newCourse
          vivo:eventHeldInFacility            ?heldIn;
          vivo:SemesterCourseOccursInSemester ?semester.
</v:jsonset>

<c:set var="editjson" scope="session">
  {
    "formUrl" : "${formUrl}",
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ ],
    "newResources"  : { "newCourse" : "default" },
    "urisInScope"   : {"person" : "${subjectUriJson}"
                        ${existingUris} },
    "literalsInScope": { },
    "urisOnForm"    : ["semester","heldIn"],
    "literalsOnForm":  [ "courseDescription", "courseName", "moniker" ],
    "sparqlForLiterals" : { },
    "sparqlForUris":{  },
    "entityToReturnTo" : "${subjectUriJson}" ,
    "sparqlForExistingLiterals":{
        "courseDescription" : "${courseDescExisting}",
        "courseName"        : "${courseNameExisting}",
        "moniker"        : "${monikerExisting}" },
    "sparqlForExistingUris" : {
        "heldIn" : "${courseHeldInExisting}",
        "semester":"${courseSemesterExisting}"
    },
    "basicValidators" : {"courseName" : ["nonempty" ],
                         "courseDescription" : ["nonempty" ] },
    "optionsForFields" : { "semester" : "${semesterClass}",
                           "heldIn"   : "${buildingClass}" },
    "fields" : {
      "moniker" : {
         "newResource"      : "false",
         "type"             : "select",
         "queryForExisting" : { },
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
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : { }
      },
      "semester" : {
         "newResource"      : "false",
         "type"             : "select",
         "queryForExisting" : { },
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "${semesterClass}"
      },
      "heldIn" : {
         "newResource"      : "false",
         "type"             : "select",
         "queryForExisting" : { },
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "${buildingClass}"
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

        if( objectUri != null ){
            Model model =  (Model)application.getAttribute("jenaOntModel");
            prepareForEditOfExisting(editConfig,model,session);
            editConfig.getUrisInScope().put("newCourse",objectUri); //makes sure we reuse objUri
        }
    //}

    System.out.println("basicValidators " + editConfig.getBasicValidators());

    /* get some data to make the form more useful */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    String personUri = editConfig.getUrisInScope().get("person");
    Individual subject = wdf.getIndividualDao().getIndividualByURI(personUri);
    if( subject == null ) throw new Error("could not find subject '" + personUri + "'");
    request.setAttribute("subjectName",subject.getName());

    /* these are used by pre and post form fragements */
    request.setAttribute("title", "create a new semester course for " + subject.getName());
%>

<jsp:include page="${preForm}"/>

        <form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
            <p/><v:input type="text" label="course title" id="courseName" />
            <p/><v:input type="select" label="semester" id="semester" />
            <p/><v:input type="select" label="held in location" id="heldIn" />
            <p/><v:input type="select" label="credit value of course" id="moniker" />
            <p/><v:input type="textarea" label="course description" id="courseDescription" rows="5" />
            <p/>
            <input type="submit" value="Create new course"/>
            
            <c:url value="/entity" var="editCancel" >
                <c:param name="uri" value="${param.subjectUri}"/>
            </c:url>
            <button type="button" onclick="javascript:document.location.href='${editCancel}'">cancel</button>

        </form>

<jsp:include page="${postForm}"/>


 <%!/* copy of method in personAuthorOf.jsp, need to find better place fo these to live. */
  private void prepareForEditOfExisting( EditConfiguration editConfig, Model model, HttpSession session){
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
