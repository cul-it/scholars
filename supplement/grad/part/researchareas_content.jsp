<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ include file="resources.jsp" %>

<%-- REMOVE THE CATCH TAGS WHEN DONE --%>

<c:choose>
    <c:when test="${!empty param.id}">
        <c:set var="fullURI">${namespace}${param.id}</c:set>
    </c:when>
    <c:otherwise>
        <c:remove var="fullURI"/>
    </c:otherwise>
</c:choose>

<c:if test="${param.showfaculty == 'yes'}"><c:set var="facultyVisibility" value="show"/></c:if>
<c:if test="${param.showfaculty == 'no'}"><c:set var="facultyVisibility" value="hide"/></c:if>

<c:if test="${param.type == 'singleArea' && !empty fullURI}">
<c:catch var="pageError">

    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
            <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" areaUri="<${fullURI}>">
              PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
              SELECT DISTINCT ?fieldUri ?fieldLabel ?personUri ?personLabel
              WHERE {
                  ?areaUri vivo:ResearchAreaOfPerson ?personUri .
                  ?personUri vivo:memberOfGraduateField ?fieldUri .
                  ?fieldUri vivo:associatedWith ?groupUri .
                  ?groupUri rdf:type vivo:fieldCluster .
                      OPTIONAL { ?areaUri rdfs:label ?areaLabel }
                      OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                      OPTIONAL { ?personUri rdfs:label ?personLabel }
              } ORDER BY ?fieldLabel ?personLabel
              LIMIT 1000
            </listsparql:select>
            
    <h3>Applicable Fields</h3>
    
    <ul class="fieldList">
        <c:forEach items="${rs}" var="row">
            <c:if test="${row.fieldUri != thisField}">
                <c:set var="thisField" value="${row.fieldUri}"/>
                    <c:set var="fieldID" value="${fn:substringAfter(row.fieldUri,'#')}"/>
                    <li class="${fieldID}">
                        <h3 class="fields clear"><a href="/fields/${fieldID}">${row.fieldLabel.string}</a></h3>
                        <c:import url="part/faculty_list.jsp">
                            <c:param name="type" value="field"/>
                            <c:param name="uri" value="${row.fieldUri}"/>
                            <c:param name="filter" value="singleArea"/>
                            <c:param name="areaUri" value="${fullURI}"/>
                            <c:param name="visibility" value="${facultyVisibility}"/>
                        </c:import>
                    </li>
            </c:if>
        </c:forEach>
    </ul>
    <div id="toggleBox">
        <c:if test="${facultyVisibility == 'hide'}">
            <p><a class="showThem" href="/researchareas/${param.id}/showfaculty">Show the faculty</a> in each Field who focus on this type of research</p>
        </c:if>
        <c:if test="${facultyVisibility == 'show'}">
            <p><a class="hideThem" href="/researchareas/${param.id}">Hide the faculty lists</a></p>
        </c:if>
    </div>
    </sparql:sparql>
    </sparql:lock>
    
</c:catch>
<c:if test="${!empty pageError}">${pageError}</c:if>
</c:if>
