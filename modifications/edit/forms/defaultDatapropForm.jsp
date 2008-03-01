<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement"%>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.Field" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ page import="java.util.Map" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils"%>
<%
System.out.println("starting defaultDatapropForm.jsp");
    String objectVarName = "oldDataprop";
    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    
    String datapropKey = request.getParameter("datapropKey");
    if( datapropKey != null){
        System.out.println("found a datapropKey in defaultDatapropForm.jsp:" + datapropKey);
        request.setAttribute("datapropKeyJson", MiscWebUtils.escape(datapropKey));
        // this was existingUris for object property
        request.setAttribute("existingLiterals", ",\""+objectVarName+"\": \""+MiscWebUtils.escape(datapropKey)+"\"");
    }else{
        System.out.println("NO datapropkey found in defaultDatapropForm.jsp");
        // this was existingUris for object property
        request.setAttribute("existingLiterals","");  //since its a new insert, no existing dataprop key
    }

    String v = request.getParameter("subjectUri");
    request.setAttribute("subjectUriJson",MiscWebUtils.escape(v));
    v = request.getParameter("predicateUri");
    request.setAttribute("predicateUriJson",MiscWebUtils.escape(v));

    request.getSession(true);

    /* get some data to make the form more useful */

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    DataProperty prop = wdf.getDataPropertyDao().getDataPropertyByURI(predicateUri);
    if( prop == null ) throw new Error("could not find property " + predicateUri);
    request.setAttribute("propertyName",prop.getPublicName());
    
    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    String rangeDatatypeUri = prop.getRangeDatatypeURI();
    request.setAttribute("rangeDatatypeUriJson", MiscWebUtils.escape(rangeDatatypeUri));
    
    System.out.println("The "+prop.getPublicName()+" data property expects a "+rangeDatatypeUri+" value for individual "+subject.getName());
%>

<v:jsonset var="n3ForEdit"  >
    ?subject ?predicate ?editedLiteral.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl"      : "${formUrl}",
    "editKey"      : "${editKey}",

    "subjectUri"   : "${subjectUriJson}",
    "predicateUri" : "${predicateUriJson}",
    "objectUri"    : "{ }",
    "objectVar"    : "<%=objectVarName%>",
    "datapropKey"  : "${datapropKey}",

    "n3required"                : [ "${n3ForEdit}" ],
    "n3optional"                : [ ],
    "newResources"              : { },
    "urisInScope"               : { "subject"   : "${subjectUriJson}",
                                    "predicate" : "${predicateUriJson}"},
    "literalsInScope"           : { },
    "urisOnForm"                : [ ],
    "literalsOnForm"            : ["editedLiteral"],
    "sparqlForLiterals"         : { },
    "sparqlForUris"             : { },
    "entityToReturnTo"          : "${subjectUriJson}",
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris"     : { },
    "basicValidators"           : { "editedLiteral" : ["nonempty"] ,
                                    "predicate" : ["nonempty"] ,
                                    "subject"   : ["nonempty"] } ,
    "optionsForFields"          : { },
    "fields"                    : { "editedLiteral" : {
                                       "newResource"      : "false",
                                       "type"             : "text",
                                       "queryForExisting" : { },
                                       "validators"       : [ ],
                                       "optionsType"      : "LITERALS",
                                       "subjectUri"       : "${subjectUriJson}",
                                       "subjectClassUri"  : "",
                                       "predicateUri"     : "",
                                       "objectClassUri"   : "",
                                       "rangeDatatypeUri" : "${rangeDatatypeUriJson}",
                                       "literalOptions"   : [ ] ,
                                       "assertions"       : ["${n3ForEdit}"] 
                                     }
								  }
  }
</c:set>

<%  //System.out.println("Starting the EditConfiguration ...");
    EditConfiguration editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
    //System.out.println("Putting the EditConfiguration into the session ...");
    EditConfiguration.putConfigInSession(editConfig, session);
    String formTitle   =""; // don't add local page variables to the request
    String submitLabel ="";
    if( datapropKey != null ){ // these get done on an edit of an existing datatype property statement
        int dataHash=0;
        try {
            dataHash = Integer.parseInt(datapropKey);
            //System.out.println("read datapropKey parameter as "+dataHash+" in defaultDatapropForm.jsp");
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey value "+datapropKey+" as an integer hash in datapropStmtDelete.jsp");
        }
        // Model model =  (Model)application.getAttribute("jenaOntModel");
        // now retrieve the real data property value from the hashed parameter
        DataPropertyStatement dps=EditConfiguration.findDataPropertyStatementViaHashcode(subject,predicateUri,dataHash);
    	if (dps!=null) {
            String literalBeingEdited = dps.getData().trim();
            editConfig.getLiteralsInScope().put("editedLiteral",literalBeingEdited); //makes sure we reuse objUri
            formTitle   = "Change value for &quot;"+prop.getPublicName()+"&quot; data property for "+subject.getName();
            submitLabel = "save change";
    	} else {
    	    throw new Error("In defaultDatapropForm.jsp, no match via hashcode to existing datatype property "+predicateUri+" for subject "+subject.getName()+"\n");
        }
    } else {
        formTitle   ="Enter new &quot;"+prop.getPublicName()+"&quot; data property for "+subject.getName();
        submitLabel ="save entry";
    }
%>

<jsp:include page="${preForm}">
	<jsp:param name="height" value="2"/>
	<jsp:param name="width" value="95%"/>
	<jsp:param name="buttons" value="bold,italic,underline,separator,link,bullist,numlist,separator,sub,sup,charmap,separator,undo,redo,separator,removeformat,cleanup,help,code"/>
	<jsp:param name="toolbarLocation" value="bottom"/>
</jsp:include>
<h3><%=formTitle%></h3>
<form action="<c:url value="/edit/processDatapropRdfForm.jsp"/>" >
	<v:input type="textarea" id="editedLiteral" rows="2"/> 
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>
<jsp:include page="${postForm}"/>
<%
System.out.println("leaving defaultDatapropForm.jsp ...");
%>
<%!/* need to find better place for these to live. */
// tasks of this method:
// add datapropKey to scope under specified var name
// run sparqlForExisting Literals, add to scope
// for the data property (we will work with only 1 at a time:
//   sub values in to the assertion strings and save as retractions,
// what else?

  private void prepareForEditOfExisting( EditConfiguration editConfig, Model model, ServletRequest request, HttpSession session){
      //add datapropKey to literalsInScope
      editConfig.getLiteralsInScope().put(editConfig.getObjectVar(), request.getParameter("datapropKey"));

      // run queries for existing values
      SparqlEvaluate sparqlEval = new SparqlEvaluate(model);

      // not sure whether we're getting the existing via the predicateUri
      Map<String,String> varsToUris =
          sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForExistingUris(),editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
      editConfig.getUrisInScope().putAll( varsToUris );

      Map<String,String> varsToLiterals =
              sparqlEval.sparqlEvaluateToLiterals(editConfig.getSparqlForExistingLiterals(),editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
      editConfig.getLiteralsInScope().putAll(varsToLiterals);

      //build retraction N3 for each Field
      for(String var : editConfig.getFields().keySet() ){
          Field field = editConfig.getField(var);
          List<String> retractions = null;
          retractions = EditConfiguration.subInLiterals(editConfig.getLiteralsInScope(),field.getAssertions());
          retractions = EditConfiguration.subInUris(editConfig.getUrisInScope(), retractions);
          field.setRetractions(retractions);
      }
}%>

