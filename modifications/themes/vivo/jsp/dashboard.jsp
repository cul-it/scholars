<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Link" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ObjectPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.DataPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatementImpl" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.text.Collator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page errorPage="/error.jsp"%>
<%
if (VitroRequestPrep.isSelfEditing(request)) {
    request.setAttribute("showSelfEdits",Boolean.TRUE );
}

VitroRequest vreq = new VitroRequest(request);
WebappDaoFactory wdf = vreq.getWebappDaoFactory();

ObjectProperty linkObjectProp = wdf.getObjectPropertyDao().getObjectPropertyByURI(VitroVocabulary.ADDITIONAL_LINK);
if (linkObjectProp != null) {%>
	<c:set var="additionalLinkObjectProperty" value="<%=linkObjectProp%>"/>
<%
}

DataProperty keywordDataProp = wdf.getDataPropertyDao().getDataPropertyByURI("http://vivo.library.cornell.edu/ns/0.1#keyword");
if (keywordDataProp != null) {%>
	<c:set var="keywordDataProperty" value="<%=keywordDataProp%>"/>
<%
}

Individual indiv = (Individual)request.getAttribute("entity"); // already tested for null in individualPerson.jsp

//here we get any VIVO keywords (now a regular dataproperty)
List<DataPropertyStatement> dataPropertyStatements = indiv.getDataPropertyStatements();
List<DataPropertyStatement> keywordStmts= new ArrayList<DataPropertyStatement>();
for (DataPropertyStatement dps : dataPropertyStatements) {
    if ("http://vivo.library.cornell.edu/ns/0.1#keyword".equals(dps.getDatapropURI())) {
	    if (dps.getData()!=null && dps.getData().trim().length()>0) {
	        keywordStmts.add(dps);
	    }
    }
}
if (keywordStmts.size()>1) { // now sort the keywords, which do not retain an inherent sort order
	Collections.sort(keywordStmts,new Comparator<DataPropertyStatement>() {
        public int compare( DataPropertyStatement first, DataPropertyStatement second ) {
            if (first==null || first.getData()==null) {
                return 1;
            }
            if (second==null || second.getData()==null) {
                return -1;
            }
            Collator collator = Collator.getInstance();
            return collator.compare(first.getData(),second.getData());
        }
    });
}

%>
<c:set var="keywordStatements" value="<%=keywordStmts%>"/>

<c:if test="${sessionScope.loginHandler != null &&
             sessionScope.loginHandler.loginStatus == 'authenticated' &&
             sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
    <c:set var="showCuratorEdits" value="true"/>
</c:if>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='dashboardPropsListJsp' value='/dashboardPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var='imageDir' value='images' />
<div id="dashboard"<c:if test="${showCuratorEdits || showSelfEdits}"> class="loggedIn"</c:if>>
   
    <c:choose>
        <c:when test="${showSelfEdits || showCuratorEdits}">
            <c:import url="${dashboardPropsListJsp}">
       	        <%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
                <c:param name="unassignedPropsGroupName" value=""/>
                <c:param name="grouped" value="true"/>
                <c:param name="allProps" value="true"/>
            </c:import>
        </c:when>
        <c:otherwise>
            <c:import url="${dashboardPropsListJsp}">
       	        <%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
                <c:param name="unassignedPropsGroupName" value=""/>
                <c:param name="grouped" value="true"/>
                <c:param name="allProps" value="false"/> 
            </c:import>
        </c:otherwise>
    </c:choose>
    
    <c:if test="${(!empty entity.anchor) || (!empty entity.linksList) || showSelfEdits || showCuratorEdits}">
        <div id="dashboardExtras">
            <div id="links">
            <h3>Links</h3>
            <c:if test="${showSelfEdits || showCuratorEdits}">
                <edLnk:editLinks item="${additionalLinkObjectProperty}" icons="false"/>
            </c:if>
                <ul class="profileLinks">
                    <c:if test="${!empty entity.anchor}">
                        <c:choose>
                            <c:when test="${!empty entity.url}">
                                <c:url var="entityUrl" value="${entity.url}" />
                                <li>
                                    <c:if test="${showSelfEdits || showCuratorEdits}">
                                    	<edLnk:editLinks item="${entity.primaryLink.objectPropertyStatement}" icons="false"/>
                                    </c:if>
                                    <a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a>
                                </li>
                            </c:when>
                            <c:otherwise><li>${entity.anchor}</li></c:otherwise>
                        </c:choose>
                    </c:if>
                    <c:if test="${!empty entity.linksList }">
                        <c:forEach items="${entity.linksList}" var='link'>
                            <c:url var="linkUrl" value="${link.url}" />
                            <li>
                                <c:if test="${showSelfEdits || showCuratorEdits}">
                                    <edLnk:editLinks item="${link.objectPropertyStatement}" icons="false"/>
                                </c:if>
                                <a class="externalLink" href="<c:out value="${linkUrl}"/>">${link.anchor}</a>
                            </li>
                        </c:forEach>
                    </c:if>
                </ul>
            </div>

            <c:if test="${!empty keywordStatements}">
                <div id="keywords">
                <h3>Keywords</h3><edLnk:editLinks item="${keywordDataProperty}" icons="false"/>
                    <ul class="keywords">
        	            <c:forEach items="${keywordStatements}" var="dataPropertyStmt">
            	            <li>
            	                <c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${dataPropertyStmt}" icons="false"/></c:if>
            	                ${dataPropertyStmt.data}
            	            </li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>    
        </div><!-- dashboardExtras -->
    </c:if>
</div><!-- dashboard -->