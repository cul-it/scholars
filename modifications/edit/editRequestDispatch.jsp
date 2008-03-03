<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.HashMap" %>
<%
    /*
    Decide which form to forward to, set subjectUri, subjectUriJson, predicateUri, and predicateUriJson in request.
    Also get the Individual for the subjectUri and put it in the request scope.

    If objectUri is set as a http parameter, then set objectUri and objectUriJson in request, also get the
    Individual for the objectUri and put it in the request.

    /* *************************************
    Parameters:
        subjectUri
        predicateUri
        objectUri (optional)
        cmd (optional)
        default (true|false)
      ************************************** */

    final String DEFAULT_OBJ_FORM =  "defaultObjPropForm.jsp";
    final String DEFAULT_ERROR_FORM = "error.jsp";
    final String DEFAULT_EDIT_THEME_DIR = "themes/default";

    HashMap<String,String> propUriToForm = null;
    propUriToForm = new HashMap<String,String>();
    propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#PersonTeacherOfSemesterCourse", "personTeacherOfSemesterCourse.jsp");
    propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#authorOf", "personAuthorOf.jsp");

    request.getSession(true);

    /* ********************************************************** */

    if( EditConfiguration.getEditKey( request ) == null ){
        request.setAttribute("editKey",EditConfiguration.newEditKey(session));
    }else{
        request.setAttribute("editKey", EditConfiguration.getEditKey( request ));
    }

     /* Figure out what type of edit is being requested,
        setup for that type of edit OR forward to some
        thing that can do the setup  */

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String defaultParam = request.getParameter("defaultForm");
    String command      = request.getParameter("cmd");

    if( subjectUri == null || subjectUri.trim().length() == 0 )
        throw new Error("subjectUri was empty, it is required by editRequestDispatch");
    if( predicateUri == null || predicateUri.trim().length() == 0)
        throw new Error("predicateUri was empty, it is required by editRequestDispatch");

    request.setAttribute("subjectUri", subjectUri);
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));
    request.setAttribute("predicateUri", predicateUri);
    request.setAttribute("predicateUriJson", MiscWebUtils.escape(predicateUri));

    String objectUri = request.getParameter("objectUri");
    if( objectUri != null){
        request.setAttribute("objectUri", objectUri);
        request.setAttribute("objectUriJson", MiscWebUtils.escape(objectUri));
    }

    /* since we have the URIs lets put the individuals in the request */
    /* get some data to make the form more useful */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("In editRequestDispatch.jsp, could not find subject in model: '" + subjectUri + "'");
    request.setAttribute("subject", subject);

    ObjectProperty objectprop = wdf.getObjectPropertyDao().getObjectPropertyByURI(predicateUri);
    if( objectprop == null ) throw new Error("In editRequestDispatch.jsp, could not find predicate object property in model: '"+predicateUri+"'");
    request.setAttribute("predicate", objectprop);

    if( objectUri != null ){
        Individual object = wdf.getIndividualDao().getIndividualByURI( objectUri );
        if( object == null ) throw new Error("Could not find object in model: '" + objectUri + "'");
        request.setAttribute("object", object);
    }

    /* keep track of what form we are using so it can be returned to after a failed validation */
    String url= "/edit/editRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());

    request.setAttribute("themeDir", "themes/editdefault/");
    request.setAttribute("preForm", "/edit/formPrefix.jsp");
    request.setAttribute("postForm", "/edit/formSuffix.jsp");

    if( "delete".equals(command) ){
        %>  <jsp:forward page="/edit/forms/propDelete.jsp"/>  <%
        return;
    }

    String form = null;
    if( propUriToForm.containsKey( predicateUri )){
        form = propUriToForm.get( predicateUri );
        request.setAttribute("hasCustomForm","true");
    }
    if( form == null || "true".equalsIgnoreCase(defaultParam) ){
        ObjectProperty prop = wdf.getObjectPropertyDao().getObjectPropertyByURI( predicateUri );
        if( prop != null )
            form = DEFAULT_OBJ_FORM;
        else
            form = DEFAULT_ERROR_FORM;
    }
    request.setAttribute("form" ,form);

    if( session.getAttribute("requestedFromEntity") == null )
        session.setAttribute("requestedFromEntity", subjectUri );
%>
<jsp:forward page="/edit/forms/${form}"  />
