<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%
    System.out.println("starting datapropStmtDelete.jsp:");
    if( session == null)
        throw new Error("need to have session");
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {%>
        <c:redirect url="/about.jsp"/>
<%  }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String datapropKey  = request.getParameter("datapropKey");
    int dataHash = 0;
    if (datapropKey!=null && datapropKey.trim().length()>0) {
        try {
        	dataHash = Integer.parseInt(datapropKey);
        	//System.out.println("read dataHash as "+dataHash+" in datapropStmtDelete.jsp");
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey value "+datapropKey+" as an integer hash in datapropStmtDelete.jsp");
        }
    }
    
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    DataProperty prop = wdf.getDataPropertyDao().getDataPropertyByURI(predicateUri);
    if( prop == null ) throw new Error("In datapropStmtDelete.jsp, could not find property " + predicateUri);
    request.setAttribute("propertyName",prop.getPublicName());
    
    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    String dataValue=null;
    DataPropertyStatement dps=EditConfiguration.findDataPropertyStatementViaHashcode(subject,predicateUri,dataHash);
    if (dps!=null) {
        dataValue = dps.getData().trim();
    	if( request.getParameter("y") != null ) { //do the delete
            System.out.println("In datapropStmtDelete.jsp, doing the delete of \nsubject: "+subjectUri+"\npredicate: "+predicateUri+"\ndata: "+dps.getData());
        	wdf.getDataPropertyStatementDao().deleteDataPropertyStatement(dps);%>
        	<c:url var="redirectUrl" value="../entity">
	    		<c:param name="uri" value="${param.subjectUri}"/>
			</c:url>
    		<c:redirect url="${redirectUrl}"/>
<%      } else { %>
			<jsp:include page="${preForm}"/>
			<form action="editDatapropStmtRequestDispatch.jsp" method="get">
    			<h4>You are attempting to delete the data property statement "${subjectName}" <i>${propertyName}"</i> "<%=dataValue%>"</h4>
    			<input type="hidden" name="subjectUri"   value="${param.subjectUri}"/>
    			<input type="hidden" name="predicateUri" value="${param.predicateUri}"/>
    			<input type="hidden" name="datapropKey"  value="${param.datapropKey}"/>
    			<input type="hidden" name="y"            value="1"/>
    			<input type="hidden" name="cmd"          value="delete"/>
    			<v:input type="submit" id="submit" value="Delete" cancel="${param.subjectUri}" />
			</form>
			<jsp:include page="${postForm}"/>
<%		}
   	 } else {
           throw new Error("In datapropStmtDelete.jsp, no match via hashcode to existing datatype property "+predicateUri+" for subject "+subject.getName()+"\n");
     }%>
     