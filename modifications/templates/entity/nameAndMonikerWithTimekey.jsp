<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>

<c:choose>
	<c:when test="${!empty individual}">
        <a class="propertyLink" href='<c:out value="${individual.URI}"/>'><p:process><c:out value="${individual.name}"/></p:process></a>
        <c:if test="${!empty individual.moniker}">
            <p:process><c:out value="| ${individual.moniker}"/></p:process>
        </c:if>
		<c:if test="${!empty individual.timekey}">		    
            <fmt:parseDate  var="eventTimekey" value="${individual.timekey}" pattern="EEE MMM dd HH:mm:ss zzz yyyy" />
            <fmt:formatDate var="eventDate" value="${eventTimekey}" pattern="MMM'. 'd', 'yyyy" />
            <fmt:formatDate var="eventTime" value="${eventTimekey}" pattern="h:mm a" />
            | ${eventDate} | ${eventTime}
        </c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
