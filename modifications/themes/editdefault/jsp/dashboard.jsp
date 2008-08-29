<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%  if( VitroRequestPrep.isSelfEditing(request) ){
        request.setAttribute("showSelfEdits","true");
    } %>
    <c:if test="${sessionScope.loginHandler != null &&
             sessionScope.loginHandler.loginStatus == 'authenticated' &&
             sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
        <c:set var="showCuratorEdits" value="true"/>
    </c:if>

<c:set var='imageDir' value='images' />
<c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
<c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
<c:set var='dashboardPropsListJsp' value='/dashboardPropList'/>
<c:set var="firstName" value="${fn:substringAfter(entity.name,',')}"/>
<c:set var="lastName" value="${fn:substringBefore(entity.name,',')}"/>

<div id="dashboard"><p>Hello, ${firstName}&nbsp;${lastName}</p>
    <c:if test="${!empty entity.imageThumb}">
        <c:if test="${!empty entity.imageFile}">
                <c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
                <a class="image" href="${imageUrl}">
        </c:if>
        <c:url var="imageSrc" value="${imageDir}/${entity.imageThumb}"/>
        <img src="<c:out value="${imageSrc}"/>" alt=""/>
        <c:if test="${!empty entity.imageFile}"></a></c:if>
    </c:if>
    <c:if test="${showSelfEdits || showCuratorEdits}">
        <c:import url="${dashboardPropsListJsp}">
        	<%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
        	<c:param name="unassignedPropsGroupName" value=""/>
        </c:import>
    </c:if>
</div>