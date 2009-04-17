<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>

<% try{ %>
<c:choose>
	<c:when test="${!empty individual}">
		<c:if test="${!empty individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#responseLastModified'].dataPropertyStatements[0].data}">
			<fmt:parseDate var="dateTime" value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#responseLastModified'].dataPropertyStatements[0].data}" pattern="yyyy-MM-dd'T'HH:mm:ss" parseLocale="en_US" />
        	<fmt:formatDate var="lastModified" value="${dateTime}" type="both" dateStyle="short"/>
        </c:if>
        <div class="datatypePropertyValue">
            <c:if test="${!empty individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#researchInterests'].dataPropertyStatements[0].data}">
        		<p:process><c:out value="${individual.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#researchInterests'].dataPropertyStatements[0].data}"/></p:process>
            </c:if>
            <c:if test="${!empty lastModified}">&nbsp;<em>${lastModified}</em></c:if>
	    </div>        
 	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
<% } catch( Exception ex){ System.out.println("error in researchStatementShortView.jsp" + ex.getMessage()) ; } %>
