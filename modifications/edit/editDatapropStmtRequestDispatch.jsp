<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="java.util.HashMap" %>
<%
    /* this is just a hard code fisrt attempt, we could get the info out of the model */

    /* *************************************
    Parameters:
        subjectUri
        predicateUri
        default (true|false)
      ************************************** */
    
    final String DEFAULT_DATA_FORM = "defaultDatapropForm.jsp";
    final String DEFAULT_ERROR_FORM = "error.jsp";
    final String DEFAULT_EDIT_THEME_DIR = "themes/default";

    HashMap<String,String> propUriToForm = null;
    propUriToForm = new HashMap<String,String>();
    //propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#researchFocus", "personResearchFocus.jsp");
    //propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#teachingFocus", "personTeachingFocus.jsp");
    
    /* ********************************************************** */

    if( EditConfiguration.getEditKey( request ) == null ){
        request.setAttribute("editKey",EditConfiguration.newEditKey(session));
    }else{
        request.setAttribute("editKey", EditConfiguration.getEditKey( request ));
    }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    //String datapropKey  = request.getParameter("datapropKey");
    String defaultParam = request.getParameter("defaultForm");
    String command      = request.getParameter("cmd");

    if( subjectUri == null || subjectUri.trim().length() == 0 )
        throw new Error("subjectUri was empty, it is required by editDatapropStmtRequestDispatch");
    if( predicateUri == null || predicateUri.trim().length() == 0)
        throw new Error("predicateUri was empty, it is required by editDatapropStmtRequestDispatch");

    String url= "/edit/editDatapropStmtRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());
    //System.out.println("query url from editDatapropStmtRequestDispatch: " + url);

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

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
       	DataProperty prop = wdf.getDataPropertyDao().getDataPropertyByURI( predicateUri );
       	if( prop != null ) {
           	form = DEFAULT_DATA_FORM;
           	//System.out.println("Setting up editing for datatprop "+predicateUri);
       	} else {
           	form = DEFAULT_ERROR_FORM;
           	System.out.println("Could not retrieve data property object for predicateUri "+predicateUri);
       	}
    }
    request.setAttribute("form" ,form);
    
    if( session.getAttribute("requestedFromEntity") == null )
    	session.setAttribute("requestedFromEntity", subjectUri );
%>
<jsp:forward page="/edit/forms/${form}"  />
