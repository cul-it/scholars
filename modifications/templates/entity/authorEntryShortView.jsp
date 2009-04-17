<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>

<c:choose>
	<c:when test="${!empty individual}"><%-- individual is the OBJECT of the property referenced -- the AuthoringAPublication, not the Person or Publication --%>
		<c:choose>
			<c:when test="${!empty predicateUri}">
			    <c:choose>
				    <c:when test="${predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#linkedAuthoringAPublication'}"><%-- SUBJECT is a Person --%>
					    <c:set var="objName" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#authorEntryFor'].objectPropertyStatements[0].object.name}"/>
					    <c:set var="objLabel" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#authorEntryFor'].objectPropertyStatements[0].object.moniker}"/>
					    <c:set var="pubYear" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#authorEntryFor'].objectPropertyStatements[0].object.dataPropertyMap['http://vivo.mannlib.cornell.edu/ns/ThomsonWOS/0.1#bib_issue_year'].dataPropertyStatements[0].data}"/>
					    <c:set var="objUri" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#authorEntryFor'].objectPropertyStatements[0].object.URI}"/>
				    </c:when>
				    <c:when test="${predicateUri == 'http://vivo.library.cornell.edu/ns/0.1#hasAuthorEntry'}"><%-- SUBJECT is a Publication --%>
				    	<c:choose>
				    		<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#linksInAuthor']}">
					    		<c:set var="objName" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#linksInAuthor'].objectPropertyStatements[0].object.name}"/>
					    		<c:set var="objLabel" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#linksInAuthor'].objectPropertyStatements[0].object.moniker}"/>
					    		<c:set var="objUri" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#linksInAuthor'].objectPropertyStatements[0].object.URI}"/>
					    	</c:when>
					    	<c:otherwise>
					    		<c:set var="objName" value="${individual.name}"/>
					    	</c:otherwise>
					    </c:choose>
				    </c:when>
				    <c:otherwise>
				        <c:set var="objName" value="unknown predicate"/>
				        <c:set var="objUri" value="${predicateUri}"/>
				    </c:otherwise>
			    </c:choose>
			    <c:choose>
			    	<c:when test="${!empty objUri}">
			    	    <c:if test="{!empty pubYear}">${pubYear}: </c:if>
			            <c:url var="objLink" value="/entity"><c:param name="uri" value="${objUri}"/></c:url>
		                <a href="<c:out value="${objLink}"/>"><p:process>${objName}</p:process></a> | <p:process>${objLabel}</p:process>
		            </c:when>
		            <c:otherwise>
		                <p:process>${objName} | ${objLabel}</p:process> 
		            </c:otherwise>
		        </c:choose>
			</c:when>
			<c:otherwise>
				<c:out value="No predicate available for custom rendering ..."/>
			</c:otherwise>
        </c:choose>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
