<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%
    // Decide which form to forward to, set subjectUri, subjectUriJson, predicateUri, predicateUriJson in request
    // Also get the Individual for the subjectUri and put it in the request scope
    // If a datapropKey is sent it as an http parameter, then set datapropKey and datapropKeyJson in request, and
    // also get the DataPropertyStatement matching the key and put it in the request scope
    /* *************************************
    Parameters:
        subjectUri
        predicateUri
        datapropKey (optional)
        cmd (optional -- deletion)
        default (true|false)
      ************************************** */

    final String DEFAULT_DATA_FORM = "defaultDatapropForm.jsp";
    final String DEFAULT_ERROR_FORM = "error.jsp";
    final String DEFAULT_EDIT_THEME_DIR = "themes/default";

    //final Log log = LogFactory.getLog("clones.vivo.modifications.edit.editDatapropStmtRequestDispatch.jsp");
    org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("edu.cornell.mannlib.vitro.jsp.edit.editDatappropStmtRequestDispatch");

    HashMap<String,String> propUriToForm = null;
    propUriToForm = new HashMap<String,String>();
    // may not need these -- depends on where we go with ordering data property statements in Javascript vs stub entities
    // propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#researchFocus", "personResearchFocus.jsp");
    // propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#teachingFocus", "personTeachingFocus.jsp");

    /* ********************************************************** */

    if( EditConfiguration.getEditKey( request ) == null ){
        request.setAttribute("editKey",EditConfiguration.newEditKey(session));
    }else{
        request.setAttribute("editKey", EditConfiguration.getEditKey( request ));
    }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String defaultParam = request.getParameter("defaultForm");
    String command      = request.getParameter("cmd");

    if( subjectUri == null || subjectUri.trim().length() == 0 ) {
        log.error("required subjectUri parameter missing");
        throw new Error("subjectUri was empty, it is required by editDatapropStmtRequestDispatch");
    }
    if( predicateUri == null || predicateUri.trim().length() == 0) {
        log.error("required subjectUri parameter missing");
        throw new Error("predicateUri was empty, it is required by editDatapropStmtRequestDispatch");
    }
    request.setAttribute("subjectUri", subjectUri);
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));
    request.setAttribute("predicateUri", predicateUri);
    request.setAttribute("predicateUriJson", MiscWebUtils.escape(predicateUri));

    String datapropKeyStr = request.getParameter("datapropKey");
    int dataHash = 0;
    if( datapropKeyStr != null && datapropKeyStr.trim().length()>0 ){
        try {
            dataHash = Integer.parseInt(datapropKeyStr);
            request.setAttribute("datahash", dataHash);
            log.trace("dataHash is " + dataHash);
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey value "+datapropKeyStr+" as an integer hash in editDatapropStmtRequestDispatch.jsp");
        }
        //request.setAttribute("datapropHash",new Integer(dataHash));
        //request.setAttribute("datapropKeyJson",MiscWebUtils.escape(datapropKeyStr));
    } // else creating a new data property

    /* since we have the URIs let's put the individual, data property, and optional data property statement in the request */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) {
        log.error("Could not find subject Individual '"+subjectUri+"' in model");
        throw new Error("editDatapropStmtRequest.jsp: Could not find subject Individual in model: '" + subjectUri + "'");
    }
    request.setAttribute("subject", subject);

    DataProperty dataproperty = wdf.getDataPropertyDao().getDataPropertyByURI( predicateUri );
    if( dataproperty == null ) {
        log.error("Could not find data property '"+predicateUri+"' in model");
        throw new Error("editDatapropStmtRequest.jsp: Could not find DataProperty in model: " + predicateUri);
    }
    request.setAttribute("predicate", dataproperty);

    DataPropertyStatement dps = null;
    if( dataHash != 0) {
        dps=EditConfiguration.findDataPropertyStatementViaHashcode(subject,predicateUri,dataHash);
        if (dps==null) {
            log.error("No match to existing data property \""+predicateUri+"\" statement for subject \""+subjectUri+"\" via key "+datapropKeyStr);
            throw new Error("In editRequestDispatch.jsp, no match to existing data property \""+predicateUri+"\" statement for subject \""+subjectUri+"\" via key "+datapropKeyStr+"\n");
        }
        request.setAttribute("dataprop", dps );
    }

    String url= "/edit/editDatapropStmtRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());

    if( log.isTraceEnabled() ){
        log.trace("predicate is " + dataproperty.getURI() + " with rangeDatatypeUri of '" + dataproperty.getRangeDatatypeURI() + "'");
        if( dps == null )
            log.trace("no exisitng dataPropertyStatement statement was found");
        else{
            log.trace("DataPropertyStatemet " + dps.getData());
            log.trace("  lang " + dps.getLanguage() );
            log.trace("  datatype " + dps.getDatatypeURI());
        }
    }

    request.setAttribute("themeDir", "themes/editdefault/");
    request.setAttribute("preForm", "/edit/formPrefix.jsp");
    request.setAttribute("postForm", "/edit/formSuffix.jsp");

    if( "delete".equals(command) ){ %>
        <jsp:forward page="/edit/forms/datapropStmtDelete.jsp"/>
<%      return;
    }

    String form = null;
    if( propUriToForm.containsKey( predicateUri )){
        form = propUriToForm.get( predicateUri );
        request.setAttribute("hasCustomForm","true");
    }
    if( form == null || "true".equalsIgnoreCase(defaultParam) ){
        if( dataproperty != null ) {
            form = DEFAULT_DATA_FORM;
        } else {
            form = DEFAULT_ERROR_FORM;
        }
    }
    request.setAttribute("form" ,form);

    if( session.getAttribute("requestedFromEntity") == null )
        session.setAttribute("requestedFromEntity", subjectUri );
%>
<jsp:forward page="/edit/forms/${form}"  />
