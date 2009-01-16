<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ include file="part/resources.jsp" %>

<c:set var="URI">${namespace}${param.uri}</c:set>
<c:set var="encodedURI"><str:encodeUrl>${URI}</str:encodeUrl></c:set>
<c:set var="fieldName">
	<c:import url="part/label.jsp"><c:param name="uri" value="${URI}"/></c:import>
</c:set>

<c:if test="${!empty param.uri}">
    <c:set var="metaDescription">
    	<c:import url="part/metadescriptions.jsp">
    	    <c:param name="uri" value="${URI}"/>
    	    <c:param name="type" value="field"/>
    	</c:import>
    </c:set>
</c:if>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fields"/>
    <jsp:param name="metaURI" value="${encodedURI}"/>
    <jsp:param name="metaDescription" value="${metaDescription}"/>
    <jsp:param name="titleText" value="Graduate Field of ${fieldName} | Cornell University  "/>
</jsp:include>

<div id="contentWrap">
	<div id="content">
        
        <c:choose>
            <%------ INDIVIDUAL FIELD PAGE ------%>
            <c:when test="${not empty param.uri}">
                <c:import url="templates/fieldEntity.jsp">
                    <c:param name="uri" value="${URI}" />
                </c:import>
            </c:when>
        
            <%------ FIELDS INDEX PAGE REDIRECT------%>
            <c:otherwise>
                <c:redirect url="/fieldsindex/"/>
            </c:otherwise>
        </c:choose>
        
	<!-- content div closed in fieldEntity template -->
</div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>