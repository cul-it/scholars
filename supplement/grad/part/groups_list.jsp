<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

<%-- Get a list of all existing field groupings -- if a group's URI is sent as a parameter, omit that group from the list --%>

<sparql:lock model="${applicationScope.jenaOntModel}" >
    <sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
             PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
             PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
             PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
             PREFIX core: <http://vivoweb.org/ontology/core#>
             SELECT ?groupUri ?groupLabel
             WHERE {
              ?groupUri rdf:type vivo:fieldCluster
              OPTIONAL { ?groupUri rdfs:label ?groupLabel }
             }
             ORDER BY ?groupLabel
             LIMIT 200
    </listsparql:select>

    <c:forEach  items="${rs}" var="row">
        <c:if test="${row.groupUri != param.uri}"><!-- providing the ability to omit a group -->
           <c:set var="areaID" value="${fn:substringAfter(row.groupUri,'#')}"/>
           <li class="${areaID}"><a href="/areas/${areaID}">${row.groupLabel.string}</a></li>
        </c:if>
    </c:forEach>

    </sparql:sparql>  
</sparql:lock>

