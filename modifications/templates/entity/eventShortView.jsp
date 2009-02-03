<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<% try{ %>
<c:choose>
	<c:when test="${!empty individual}">
		<fmt:parseDate var="eventDateTime" value="${individual.timekey}" pattern="EEE MMM dd HH:mm:ss ZZZ yyyy" parseLocale="en_US" />
        <%-- fmt:formatDate var="dateTime" value="${eventDateTime}" pattern="EEE' 'M'/'d'/'yy' 'h:mm' 'a" / --%>
        <fmt:formatDate var="dateTime" value="${eventDateTime}" type="both" dateStyle="full" timeStyle="short"/>
		<c:url var="eventLink" value="/entity"><c:param name="uri" value="${individual.URI}"/></c:url>
	    <a class="propertyLink" href="<c:out value="${eventLink}"/>"><p:process>${individual.name}</p:process></a>
    	<%-- <c:if test="${!empty individual.moniker}">
    			| <p:process>${individual.moniker}</p:process>
    	  	 </c:if>
    	--%>
    	<c:if test="${!empty dateTime}">| ${dateTime}</c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
<% } catch( Exception ex){ System.out.println("error in eventShortView.jsp" + ex.getMessage()) ; } %>
