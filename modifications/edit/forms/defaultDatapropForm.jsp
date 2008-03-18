<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils"%>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%
    //final Log log = LogFactory.getLog("clones.vivo.modifications.edit.forms.defaultDatapropForm.jsp");
	org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("edu.cornell.mannlib.vitro.jsp.edit.forms.defaultDatapropForm.jsp");
	log.info("Starting defaultDatapropForm.jsp");
	
    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");

    String datapropKeyStr = request.getParameter("datapropKey");
    int dataHash=0;
    try {
        dataHash = Integer.parseInt(datapropKeyStr);
        log.debug("dataHash is " + dataHash);
    } catch (NumberFormatException ex) {
        throw new JspException("Cannot decode incoming datapropKey String value "+datapropKeyStr+" as an integer hash in defaultDatapropForm.jsp");
    }

    //this should be moved to editREquestDispatch.jsp? what does it do?
    request.getSession(true);

    DataProperty prop = (DataProperty)request.getAttribute("predicate");
    if( prop == null ) throw new Error("In defaultDatapropForm.jsp, could not find predicate " + predicateUri);
    request.setAttribute("propertyName",prop.getPublicName());

    Individual subject = (Individual)request.getAttribute("subject");
    if( subject == null ) throw new Error("In defaultDatapropForm.jsp, could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    String rangeDatatypeUri = prop.getRangeDatatypeURI();
    request.setAttribute("rangeDatatypeUriJson", MiscWebUtils.escape(rangeDatatypeUri));

    DataPropertyStatement dataproperty = (DataPropertyStatement)request.getAttribute("dataproperty");
    if( dataproperty != null ){
        String rangeDatatype = dataproperty.getDatatypeURI();
        if( rangeDatatype == null ){
            request.setAttribute("rangeDatatypeUriJson","");
        }else{
            request.setAttribute("rangeDatatypeUriJson",rangeDatatype);
        }
        String rangeLang = dataproperty.getLanguage();
        if( rangeLang == null )
            request.setAttribute("rangeLangJson", "");
        else
            request.setAttribute("rangeLangJson", rangeLang);

    }

%>
<v:jsonset var="n3ForEdit"  >
    ?subject ?predicate ?editedLiteral.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl"      : "${formUrl}",
    "editKey"      : "${editKey}",

    "subject"   : ["subject",   "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}"],
    "object"    : ["editedLiteral","","DATAPROPHASH"],

    "datapropKey"  : "${dataHash}",

    "n3required"                : ["${n3ForEdit}"],
    "n3optional"                : [ ],
    "newResources"              : { },
    "urisInScope"               : { },
    "literalsInScope"           : { },
    "urisOnForm"                : [ ],
    "literalsOnForm"            : ["editedLiteral"],
    "sparqlForLiterals"         : { },
    "sparqlForUris"             : { },
    "entityToReturnTo"          : "${subjectUriJson}",
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris"     : { },
    "basicValidators"           : { "editedLiteral" : ["nonempty"] ,
                                    "predicate"     : ["nonempty"] ,
                                    "subject"       : ["nonempty"] } ,
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
                                       "rangeDatatypeUri" : "${rangeDatatypeUriJson}"  ,
                                       "rangeLang" : "${rangeLangJson}",
                                       "literalOptions"   : [ ] ,
                                       "assertions"       : ["${n3ForEdit}"]
                                     }
                                  }
  }
</c:set>

<%
    if( log.isDebugEnabled()) log.debug(request.getAttribute("editjson"));

    EditConfiguration editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
    EditConfiguration.putConfigInSession(editConfig, session);

    String formTitle   =""; // don't add local page variables to the request
    String submitLabel ="";

    if( datapropKeyStr != null && datapropKeyStr.trim().length() > 0  ) {
        editConfig.setDatapropKey( datapropKeyStr );
        Model model =  (Model)application.getAttribute("jenaOntModel");
        editConfig.prepareForUpdate(request,model);
        formTitle   = "Change value for &quot;"+prop.getPublicName()+"&quot; data property for "+subject.getName();
        submitLabel = "save change";
    } else {
        formTitle   ="Enter new &quot;"+prop.getPublicName()+"&quot; data property for "+subject.getName();
        submitLabel ="save entry";
    }
%>
<%--the following  parameters configure the tinymce textarea --%>
<jsp:include page="${preForm}">
    <jsp:param name="height" value="2"/>
    <jsp:param name="width" value="95%"/>
    <jsp:param name="buttons" value="bold,italic,underline,separator,link,bullist,numlist,separator,sub,sup,charmap,separator,undo,redo,separator,removeformat,cleanup,help,code"/>
    <jsp:param name="toolbarLocation" value="bottom"/>
</jsp:include>

<h2><%=formTitle%></h2>
<form action="<c:url value="/edit/processDatapropRdfForm.jsp"/>" >
    <v:input type="textarea" id="editedLiteral" rows="2"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>



