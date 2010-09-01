<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="deptsInField" field="<${param.uri}>">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        PREFIX core: <http://vivoweb.org/ontology/core#>
        SELECT DISTINCT ?deptUri ?deptLabel
        WHERE {
          ?person vivo:memberOfGraduateField ?field .
          ?person core:personInPosition ?facultyPosition .
            ?facultyPosition core:positionInOrganization ?deptUri .
          ?deptUri rdf:type core:AcademicDepartment ;
            rdfs:label ?deptLabel .
        }
        ORDER BY ?deptLabel
        LIMIT 2000
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<json:array name="Departments">

<c:forEach items="${deptsInField}" var="dept">
     <json:object>
         <json:property name="Label" value="${dept.deptLabel.string}"/>
         <json:property name="URI" value="${dept.deptUri}"/>
     </json:object>
</c:forEach>

</json:array>