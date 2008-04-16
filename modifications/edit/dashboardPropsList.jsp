<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Property" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.PropertyGroup" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.KeywordProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.PropertyGroupDao" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.dashboardPropsList.jsp");
%>
<%
boolean showSelfEdits=false;
boolean showCuratorEdits=false;
if( VitroRequestPrep.isSelfEditing(request) ) {
    showSelfEdits=true;
}
if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
	showCuratorEdits=true;
}%>
<c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
<c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
<%
	log.debug("Starting dashboardPropsList.jsp");

	// The goal here is to retrieve a list of object and data properties appropriate for the vclass
	// of the individual, by property group, and sorted the same way they would be in the public interface

	Individual subject = (Individual) request.getAttribute("entity");
	if (subject==null) {
    	throw new Error("Subject individual must be in request scope for dashboardPropsList.jsp");
	}

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
	PropertyGroupDao pgDao = wdf.getPropertyGroupDao();
	ArrayList<Property> mergedList = (ArrayList) request.getAttribute("dashboardPropertyList");
    if (mergedList!=null) {
        String lastGroupName = null;
		int groupCount=0;%>
		<ul id="dashboardNavigation">
<%		for (Property p : mergedList) {
    		String groupName="unspecified";
String localName="unspecified";
    		if (p.getGroupURI()!=null) {
    		        PropertyGroup pg = pgDao.getGroupByURI(p.getGroupURI());
		    	groupName=pg.getName();
	localName = pg.getLocalName();
    		}
		    if (!groupName.equals(lastGroupName)) {
		    	lastGroupName=groupName;
		        ++groupCount;
		        if (groupCount>1) { // close existing group %>
		        	</ul></li>
<%		    	}%>
		    	<li>
		    	<h2><%=groupName%></h2>
		    	<ul class="dashboardCategories">
<%			}%>
			<edLnk:editLinks item="<%=p %>" var="links" />
			<c:if test="${!empty links}">
	            <li class="dashboardProperty"><a href="#<%=localName%>"><%=p.getEditLabel()%></a>
<%				if (showCuratorEdits) {
	    			if (p instanceof ObjectProperty) {
					    ObjectProperty op = (ObjectProperty)p;%>
					    (o<%=p.isSubjectSide() ? op.getDomainDisplayTier() : op.getRangeDisplayTier()%>)
<%			        } else if (p instanceof DataProperty) {
	    			    DataProperty dp = (DataProperty)p;%>
					    (d<%=dp.getDisplayTier() %>)
<%			        } else if (p instanceof KeywordProperty) {
					    KeywordProperty kp = (KeywordProperty)p;%>
					    (k<%=kp.getDisplayRank()%>)
<%			        } else {
					    log.error("unknown class of property "+p.getClass().getName()+" in merging properties for edit list");
				    }
				}%>
	            </li>
	       	</c:if>
<%      }%>
        </ul></li></ul>
<%   }
%>

