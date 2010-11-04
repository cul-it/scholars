<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page errorPage="/error.jsp"%>
<%
if (VitroRequestPrep.isSelfEditing(request)) {
    request.setAttribute("showSelfEdits",Boolean.TRUE );
} %>

<c:if test="${sessionScope.loginHandler != null &&
             sessionScope.loginHandler.loginStatus == 'authenticated' &&
             sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
    <c:set var="showCuratorEdits" value="true"/>
</c:if>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='dashboardPropsListJsp' value='/dashboardPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var='imageDir' value='/images' />
<div id="dashboard"<c:if test="${showCuratorEdits || showSelfEdits}"> class="loggedIn"</c:if>>
    <c:if test="${!empty entity.imageThumb}">
        <c:if test="${!empty entity.imageFile}">
            <c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
            <a class="image" href="${imageUrl}">
        </c:if>
        <c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
        <img class="headshot" src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
        <c:if test="${!empty entity.imageFile}"></a></c:if>
        <c:if test="${!empty entity.citation}"><div class="citation">${entity.citation}</div></c:if>
    </c:if>
    
    <c:choose>
        <c:when test="${!empty entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId'].dataPropertyStatements[0].data}">
            <c:set var="emailAddress" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId'].dataPropertyStatements[0].data}"/>
            <c:set var="netId" value="${fn:substringBefore(emailAddress,'@')}"/>
            <div id="currentContactInfo">
            	<c:url var="CUSearchUrl" value="http://www.cornell.edu/search/index.cfm">
            		<c:param name="tab" value="people"/>
            		<c:param name="netid" value="${netId}"/>
            	</c:url>
            	<a class="externalLink" href="${CUSearchUrl}">Current Contact Info</a>
           	</div>
        </c:when>
        <c:otherwise>
            <c:if test="${!empty entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#nonCornellemail'].dataPropertyStatements[0].data}">
                <c:set var="emailAddress" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#nonCornellemail'].dataPropertyStatements[0].data}"/>
                <c:if test="${fn:containsIgnoreCase(emailAddress,'@med.cornell.edu')}">
          	        <div id="currentContactInfo">
            	        <c:url var="CUMedSearchUrl" value="http://www.cornell.edu/search/index.cfm">
            		        <c:param name="tab" value="people"/>
            		        <c:param name="q" value="${emailAddress}"/>
            	        </c:url>
            	        <a class="externalLink" href="${CUMedSearchUrl}">Current Contact Info</a>
          	        </div>
                </c:if>
            </c:if>
        </c:otherwise>
    </c:choose>
    
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
    <c:if test="${showSelfEdits || showCuratorEdits}">
        <c:import url="${dashboardPropsListJsp}">
        	<%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
        	<c:param name="unassignedPropsGroupName" value=""/>
        </c:import>
    </c:if>
</div>