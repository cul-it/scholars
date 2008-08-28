<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
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
<c:set var='imageDir' value='images' />
<div id="dashboard"<c:if test="${showCuratorEdits || showSelfEdits}"> class="loggedIn"</c:if>>
     
    <c:if test="${showSelfEdits || showCuratorEdits}">
        <c:import url="${dashboardPropsListJsp}"></c:import>
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
        </div>
    </c:if>
    
    <%-- <c:if test="${showCuratorEdits || showSelfEdits}">
        <c:import url="${dashboardPropsListJsp}"></c:import>
    </c:if> --%>
</div>