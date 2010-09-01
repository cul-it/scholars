<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>

<c:choose>
	<c:when test="${!empty individual}"><%-- individual is the OBJECT of the property referenced -- the Collaborating on Research individual, not the Person or Contract/Grant/Research in Progress --%>
		<c:choose>
			<c:when test="${!empty predicateUri}">
			    <c:choose>
				    <c:when test="${predicateUri == 'http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitPracticeOrPerformance'}"><%-- SUBJECT is a Person, show the research --%>
				        <c:set var="objSort" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitPracticeOrPerformanceResponse'].objectPropertyStatements[0].object.dataPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#yearOfDate'].dataPropertyStatements[0].data}"/>
					    <c:set var="objName" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitPracticeOrPerformanceResponse'].objectPropertyStatements[0].object.name}"/>
					    <c:set var="objLabel" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitPracticeOrPerformanceResponse'].objectPropertyStatements[0].object.dataPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#responseInternalType'].dataPropertyStatements[0].data}"/>
					    <c:set var="objUri" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitPracticeOrPerformanceResponse'].objectPropertyStatements[0].object.URI}"/>
				    </c:when>
				    <c:when test="${predicateUri == 'http://vitro.mannlib.cornell.edu/ns/reporting#hasExhibitingPracticingOrPerforming'}"><%-- SUBJECT is a Exhibit, Practice or Performance; show the person --%>
				    	<c:choose>
				    		<c:when test="${!empty individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitorPractitionerOrPerformer']}">
				    		    <c:set var="objSort" value=""/>
					    		<c:set var="objName" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitorPractitionerOrPerformer'].objectPropertyStatements[0].object.name}"/>
					    		<c:set var="objLabel" value="${individual.moniker}"/><%-- Exhibitor --%>
					    		<c:set var="objUri" value="${individual.objectPropertyMap['http://vitro.mannlib.cornell.edu/ns/reporting#linkedExhibitorPractitionerOrPerformer'].objectPropertyStatements[0].object.URI}"/>
					    	</c:when>
					    	<c:otherwise>
					    	    <c:set var="objSort" value=""/>
					    		<c:set var="objName" value="${individual.name}"/>
					    		<c:set var="objLabel" value="${individual.moniker}"/>
					    		<c:set var="objUri" value="${individual.URI}"/>
					    	</c:otherwise>
					    </c:choose>
				    </c:when>
				    <c:otherwise>
				        <c:set var="objName" value="unknown predicate"/>
				        <c:set var="objLabel" value=""/>
				        <c:set var="objUri" value="${predicateUri}"/>
				    </c:otherwise>
			    </c:choose>
			    <c:choose>
			    	<c:when test="${!empty objUri}">
			            <c:url var="objLink" value="/entity"><c:param name="uri" value="${objUri}"/></c:url>
		                ${objSort}&nbsp;<a href="<c:out value="${objLink}"/>"><p:process>${objName}</p:process></a> | ${objLabel}
		            </c:when>
		            <c:otherwise>
		                <p:process>${objSort} ${objName} | ${objLabel}</p:process>
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
