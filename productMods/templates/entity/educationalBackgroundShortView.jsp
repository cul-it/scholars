<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:choose>
	<c:when test="${!empty individual}">
        <span style="color:black;"> <% /* TODO: Un-kluge this. For some reason this short view was showing up gray */ %>
		<c:set var="gradyear" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#yearDegreeAwarded'].dataPropertyStatements[0].data}"/>
		<c:set var="degree" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#preferredDegreeAbbreviation'].dataPropertyStatements[0].data}"/>
		<c:set var="institution" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#institutionAwardingDegree'].dataPropertyStatements[0].data}"/>
		<c:set var="major" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#majorFieldOfDegree'].dataPropertyStatements[0].data}"/>
		<c:if test="${!empty gradyear }"><c:out value="${gradyear} : "/></c:if>
		<c:out value="${degree}"/>
		<c:if test="${!empty institution }"><c:out value=", ${institution}"/></c:if>
		<c:if test="${!empty major }"><c:out value=", ${major}"/></c:if>
        </span>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
