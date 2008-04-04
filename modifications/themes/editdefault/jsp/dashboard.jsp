<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<c:set var='imageDir' value='images' />
<c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
<c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
<div id="dashboard"><p>Hello, ${entity.name}</p>
    <c:if test="${!empty entity.imageThumb}">
        <c:if test="${!empty entity.imageFile}">
                <c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
                <a class="image" href="${imageUrl}">
        </c:if>
        <c:url var="imageSrc" value="${imageDir}/${entity.imageThumb}"/>
        <img src="<c:out value="${imageSrc}"/>" alt=""/>
        <c:if test="${!empty entity.imageFile}"></a></c:if>
    </c:if>
<jsp:include page="../../../edit/dashboardPropsList.jsp" flush="true"/>
</div>