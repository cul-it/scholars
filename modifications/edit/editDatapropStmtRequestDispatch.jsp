<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.RdfLiteralHash" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.HashMap" %>
<%
    org.apache.commons.logging.Log log = org.apache.commons.logging.LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.editDatapropStmtRequestDispatch");
    //Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.editDatapropStmtRequestDispatch");
%>
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

    String url= "/edit/editDatapropStmtRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());


    String datapropKeyStr = request.getParameter("datapropKey");
    int dataHash = 0;
    if( datapropKeyStr != null ){
        try {
            dataHash = Integer.parseInt(datapropKeyStr);
            request.setAttribute("datahash", dataHash);
            log.debug("Found a datapropKey in parameters and parsed it to int: " + dataHash);
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey value "+datapropKeyStr+" as an integer hash in editDatapropStmtRequestDispatch.jsp");
        }
    }

    DataPropertyStatement dps = null;
    if( dataHash != 0) {
        dps = RdfLiteralHash.getDataPropertyStmtByHash( subject ,dataHash);

        if (dps==null) {
            log.error("No match to existing data property \""+predicateUri+"\" statement for subject \""+subjectUri+"\" via key "+datapropKeyStr);
            throw new Error("In editDatapropStmtRequest.jsp, no match to existing data property \""+predicateUri+"\" statement for subject \""+subjectUri+"\" via key "+datapropKeyStr+"\n");
        }
        request.setAttribute("dataprop", dps );
    }



    if( log.isDebugEnabled() ){
        log.debug("predicate for DataProperty from reuqest is " + dataproperty.getURI() + " with rangeDatatypeUri of '" + dataproperty.getRangeDatatypeURI() + "'");
        if( dps == null )
            log.debug("no exisitng DataPropertyStatement statement was found, making a new statemet");
        else{
            log.debug("Found an existing DataPropertyStatement");

            if( log.isDebugEnabled()){
                String msg = "existing datapropstmt: ";
                msg += " subject uri: <"+dps.getIndividualURI() + ">\n";
                msg += " prop uri: <"+dps.getDatapropURI() + ">\n";
                msg += " prop data: \"" + dps.getData() + "\"\n";
                msg += " datatype: <" + dps.getDatatypeURI() + ">\n";
                msg += " hash of this stmt: " + RdfLiteralHash.makeRdfLiteralHash(dps);
                log.debug(msg);
            }
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
