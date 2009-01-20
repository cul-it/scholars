<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:choose>
	<c:when test="${!empty individual}">
		| <%-- will be something to render, so put in the pipe --%>
	    <c:if test="${!empty individualURL}">
	        <%-- NOTE not the individual.url; explicitly set in the including file to control whether to render as a link --%>
  			<c:url var="entUrl" value="${individualURL}" />
  			<a class="externalLink" href='<c:out value="${entUrl}"/>'>
        </c:if>
        <c:choose>
	        <c:when test="${!empty individual.timekey}">
                <fmt:parseDate  var="eventTimekey" value="${individual.timekey}" pattern="EEE MMM dd HH:mm:ss zzz yyyy" parseLocale="en-US"/>
                <%-- <fmt:formatDate var="eventDateTime" value="${eventTimekey}" pattern="EEE' 'M'/'d'/'yy' 'h:mm' 'a" /> --%>
                <fmt:formatDate var="eventDateTime" value="${eventTimekey}" type="both" dateStyle="short" timeStyle="short" />
                ${eventDateTime}
            </c:when>
            <c:otherwise>
            	${individual.anchor}
            </c:otherwise>
        </c:choose>
        <c:if test="${!empty individualUrl}">
           	</a>
        </c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
