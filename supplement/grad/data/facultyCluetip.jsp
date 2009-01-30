<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ include file="../part/resources.jsp" %>

<c:choose>
    <c:when test="${!empty param.id}">
        <c:set var="fullURI">${namespace}${param.id}</c:set>
    </c:when>
    <c:otherwise>
        <c:remove var="fullURI"/>
    </c:otherwise>
</c:choose>

<c:set var="imageDir" value="/images/" />

<c:if test="${!empty fullURI}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
    
            <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" personUri="<${fullURI}>">
              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
              SELECT DISTINCT ?personLabel ?areaUri ?areaLabel ?image ?moniker
              WHERE {
                  ?personUri rdfs:label ?personLabel .
                  OPTIONAL {?personUri vivo:PersonHasResearchArea ?areaUri . ?areaUri rdfs:label ?areaLabel }
                      OPTIONAL { ?personUri vitro:imageThumb ?image }
                      OPTIONAL { ?personUri vitro:moniker ?moniker }
              } ORDER BY ?areaLabel
              LIMIT 1000
            </listsparql:select>

    <c:set var="fullName" value="${rs[0].personLabel.string}"/>
    <c:if test="${fn:contains(fullName, ',')}">
        <c:set var="firstName" value="${fn:substringAfter(fullName,',')}"/>
        <c:set var="lastName" value="${fn:substringBefore(fullName,',')}"/>
        <c:set var="fullName">${firstName}${" "}${lastName}</c:set>
    </c:if>

    <h5>${fullName}</h5>
    
    <div class="clueTipWrap">
        <c:choose>
            <c:when test="${!empty rs[0].image.string}">
                <img width="100" alt="" src="${imageDir}${rs[0].image.string}"/>
            </c:when>
            <c:otherwise>
                <img width="100" alt="" src="/resources/images/profile_missing.gif"/>
            </c:otherwise>
        </c:choose>
    
    <c:if test="${!empty rs[0].areaUri}">
        <strong>Research Areas</strong>
        <ul>
            <c:forEach items='${rs}' var="row">
                <c:set var="facultyID" value="${param.id}"/>
                <li>${row.areaLabel.string}</li>
            </c:forEach>
        </ul>
    </c:if>
    </div>
    </sparql:sparql>
    </sparql:lock>
</c:if>
