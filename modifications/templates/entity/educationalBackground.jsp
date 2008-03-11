<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>

<c:set var="objectIndividual" value="${objectPropertyStmt.object}"/>
<c:forEach items='${objectIndividual.dataPropertyStatements}' var='dataPropStmt'>
    URI of data property: ${dataPropStmt.datapropURI }<br/>
	<c:choose>
		<c:when test="${'http://vivo.library.cornell.edu/ns/0.1#yearDegreeAwarded'==dataPropStmt.datapropURI}">
			<c:set var="year" value="${dataPropStmt.data}"/>
		</c:when>
		<c:when test="${'http://vivo.library.cornell.edu/ns/0.1#preferredDegreeAbbreviation'==dataPropStmt.datapropURI}">
			<c:set var="degree" value="${dataPropStmt.data}"/>
		</c:when>
		<c:when test="${'http://vivo.library.cornell.edu/ns/0.1#institutionAwardingDegree'==dataPropStmt.datapropURI}">
			<c:set var="institution" value="${dataPropStmt.data}"/>
		</c:when>
		<c:when test="${'http://vivo.library.cornell.edu/ns/0.1#majorFieldOfDegree'==dataPropStmt.datapropURI}">
			<c:set var="major" value="${dataPropStmt.data}"/>
		</c:when>
	</c:choose>
</c:forEach>
${year} : ${degree}, ${institution}, ${major}
	