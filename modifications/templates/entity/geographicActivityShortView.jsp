<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>

<c:choose>
	<c:when test="${!empty individual}">
		<c:set var="startDate" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#timeIntervalResponseStartDate'].dataPropertyStatements[0].data}"/>
		<c:set var="endDate" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#timeIntervalResponseEndDate'].dataPropertyStatements[0].data}"/>
		<c:if test="${!empty startDate}">
		    <c:out value="${startDate}"/>
		    <c:if test="${!empty endDate}">
		        <c:out value=" - ${endDate}"/>
		    </c:if>
		</c:if>
		<c:if test="${!empty predicateUri}">
		    <c:choose>
			    <c:when test="${predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#hasInternationalActivity'}">
				    <c:set var="objName" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#internationalGeographicFocus'].objectPropertyStatements[0].object.name}"/>
				    <c:set var="objUri" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#internationalGeographicFocus'].objectPropertyStatements[0].object.URI}"/>
			    </c:when>
			    <c:when test="${predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#focusOfInternationalActivity'}">
				    <c:set var="objName" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#internationalActivityOf'].objectPropertyStatements[0].object.name}"/>
				    <c:set var="objUri" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#internationalActivityOf'].objectPropertyStatements[0].object.URI}"/>
			    </c:when>
			    <c:otherwise>
			        <c:set var="objName" value="unknown predicate"/>
			        <c:set var="objUri" value="${predicateUri}"/>
			    </c:otherwise>
		    </c:choose>
		    <c:url var="objLink" value="/entity"><c:param name="uri" value="${objUri}"/></c:url>
	        | <a href="<c:out value="${objLink}"/>"><p:process>${objName}</p:process></a>
		</c:if>
	    <c:url var="activityLink" value="/entity"><c:param name="uri" value="${individual.URI}"/></c:url>
	    | <a class="externalLink" href="<c:out value="${activityLink}"/>"><p:process>${individual.name}</p:process></a>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
