<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:choose>
	<c:when test="${!empty individual}">
		<c:if test="${!empty individual.url}">
			<c:url var="link" value="${individual.url}" />
			<a class="externalLink" href="<c:out value="${link}"/>">${individual.anchor}</a>
		</c:if>
		<c:if test="${!empty individual.linksList}">
			<c:forEach items="${individual.linksList}" var="additionalLink">
				<c:url var="extraLink" value="${additionalLink.url}" />
				<a class="externalLink" href="<c:out value="${extraLink}"/>">${additionalLink.anchor}</a>
			</c:forEach>
		</c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
