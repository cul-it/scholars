<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- Given a faculty/department/field URI, build a reasonable chunk of text for a meta description tag --%>

<c:if test="${param.type == 'faculty'}">
    <sparql:lock model="${applicationScope.jenaOntModel}" >
        <sparql:sparql>
          <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX core: <http://vivoweb.org/ontology/core#>
              SELECT ?statement ?focus
              WHERE { 
                OPTIONAL { ?uri core:overview ?statement }
                OPTIONAL { ?person core:hasResearcherRole ?researchActivity .
                              ?researchActivity core:description ?focus }
              }
              LIMIT 1
          </listsparql:select>
        </sparql:sparql>
    </sparql:lock>
    
    <c:set var="statement"><str:truncateNicely lower="0" upper="180">${rs[0].statement.string}</str:truncateNicely></c:set>
    <c:set var="focus"><str:truncateNicely lower="0" upper="180">${rs[0].focus.string}</str:truncateNicely></c:set>
    
    <c:choose>
        <c:when test="${!empty statement && fn:length(statement) > 40}">
            <c:set var="description" value="${statement}"/>
        </c:when>
        <c:when test="${!empty focus && fn:length(focus) > 40}">
            <c:set var="description" value="${focus}"/>
        </c:when>
        <c:otherwise>
            <c:set var="description" value=""/>
        </c:otherwise>
    </c:choose>
    
    <str:removeXml>${description}</str:removeXml>
</c:if>

<c:if test="${param.type == ('department' || 'field')}">
    <sparql:lock model="${applicationScope.jenaOntModel}" >
        <sparql:sparql>
          <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
            PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
            PREFIX core: <http://vivoweb.org/ontology/core#>
            SELECT ?description
            WHERE { ?uri core:description ?description }
            LIMIT 1
          </listsparql:select>
        </sparql:sparql>
    </sparql:lock>
    
    <str:truncateNicely lower="0" upper="180"><str:removeXml>${rs[0].description.string}</str:removeXml></str:truncateNicely>
</c:if>

