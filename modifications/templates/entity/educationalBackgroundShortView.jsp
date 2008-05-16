<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>

<c:choose>
	<c:when test="${!empty objPropStmt}">
		<c:set var="gradyear" value="${objPropStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#yearDegreeAwarded'].dataPropertyStatements[0].data}"/>
		<c:set var="degree" value="${objPropStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#preferredDegreeAbbreviation'].dataPropertyStatements[0].data}"/>
		<c:set var="institution" value="${objPropStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#institutionAwardingDegree'].dataPropertyStatements[0].data}"/>
		<c:set var="major" value="${objPropStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#majorFieldOfDegree'].dataPropertyStatements[0].data}"/>
		<c:out value="${gradyear} : ${degree}, ${institution}"/>
		<c:if test="${!empty major }">, ${major}</c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
