<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
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
if (keywordStmts.size()>1) {
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
   
    <c:if test="${showSelfEdits || showCuratorEdits}">
        <c:import url="${dashboardPropsListJsp}">
       	    <%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
        	<c:param name="unassignedPropsGroupName" value=""/>
        </c:import>
    </c:if>
    
    <c:if test="${(!empty entity.anchor) || (!empty entity.linksList)}">
        <div id="dashboardExtras">
            <h3>Links</h3>
            <ul class="profileLinks">
                <c:if test="${!empty entity.anchor}">
                    <c:choose>
                        <c:when test="${!empty entity.url}">
                            <c:url var="entityUrl" value="${entity.url}" />
                            <li><a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a></li>
                        </c:when>
                        <c:otherwise><li>${entity.anchor}</li></c:otherwise>
                    </c:choose>
                </c:if>
                <c:if test="${!empty entity.linksList }">
                    <c:forEach items="${entity.linksList}" var='link'>
                        <c:url var="linkUrl" value="${link.url}" />
                        <li><a class="externalLink" href="<c:out value="${linkUrl}"/>">${link.anchor}</a></li>
                    </c:forEach>
                </c:if>
            </ul>

            <c:if test="${!empty keywordStatements}">
            <h3 class="secondary">Keywords</h3>
                <ul class="keywords">
    	            <c:forEach items="${keywordStatements}" var="dataPropertyStmt">
        	            <li>
        	                <c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${dataPropertyStmt}" icons="false"/></c:if>
        	                ${dataPropertyStmt.data}
        	            </li>
                    </c:forEach>
                </ul>
            </c:if>    
        </div>
    </c:if>
</div>