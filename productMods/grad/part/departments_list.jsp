<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

<c:if test="${param.type == 'field'}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>">
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
            PREFIX core: <http://vivoweb.org/ontology/core#>
            SELECT DISTINCT ?deptUri ?deptLabel ?personUri
            WHERE {
                ?fieldUri vivo:hasFieldMember ?personUri .
                ?personUri core:personInPosition ?facultyPosition .
                      ?facultyPosition core:positionInOrganization ?deptUri .
                OPTIONAL {?personUri rdfs:label ?personLabel}
                ?deptUri rdf:type core:AcademicDepartment ;
                  rdfs:label ?deptLabel .
            } ORDER BY ?deptLabel ?personLabel
            LIMIT 1000
        </listsparql:select>
    
            <c:set var="thisDept" value=""/>
        
            <c:forEach items="${rs}" var="row">
            <c:set var="counter" value="0"/>
                <c:if test="${thisDept != row.deptUri}">
                    <c:set var="thisDept" value="${row.deptUri}"/>
                    <c:forEach  items="${rs}" var="people">
                        <c:if test="${thisDept == people.deptUri}"><c:set var="counter" value="${counter+1}"/></c:if>
                    </c:forEach>
                    <c:set var="deptID" value="${fn:substringAfter(row.deptUri,'/individual/')}"/>
                    <li><a href="/departments/${deptID}" title="">${row.deptLabel.string}</a> <%-- <em>&mdash; ${counter} faculty from this department</em> --%></li>
                </c:if>
            </c:forEach>
            
    </sparql:sparql>
    </sparql:lock>
</c:if>

<c:if test="${param.type == 'person'}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" personUri="<${param.uri}>">
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
            PREFIX core: <http://vivoweb.org/ontology/core#>
            SELECT DISTINCT ?deptUri ?deptLabel
            WHERE {
                ?personUri core:personInPosition ?facultyPosition .
                      ?facultyPosition core:positionInOrganization ?deptUri .
                ?deptUri rdf:type core:AcademicDepartment ;
                  rdfs:label ?deptLabel .
            } ORDER BY ?deptLabel
            LIMIT 200
        </listsparql:select>
    
            <c:forEach  items="${rs}" var="row">
                <c:set var="deptID" value="${fn:substringAfter(row.deptUri,'/individual/')}"/>
                <li><a href="/departments/${deptID}" title="">${row.deptLabel.string}</a></li>
            </c:forEach>
            
    </sparql:sparql>
    </sparql:lock>
</c:if>
