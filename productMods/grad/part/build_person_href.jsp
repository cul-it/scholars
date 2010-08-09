<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ include file="resources.jsp" %>

<c:choose>
    <c:when test="${fn:contains(param.uri, namespace_hri3)}">
        <c:out value="/faculty/HRI3${fn:substringAfter(param.uri,'/individual/')}"/>
    </c:when>
    <c:when test="${fn:contains(param.uri, namespace_hri2)}">
        <c:out value="/faculty/HRI2${fn:substringAfter(param.uri,'/individual/')}"/>
    </c:when>
    <c:otherwise>
        <c:out value="/faculty/${fn:substringAfter(param.uri,'/individual/')}"/>
    </c:otherwise>
</c:choose>