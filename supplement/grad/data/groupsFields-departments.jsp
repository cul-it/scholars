<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="deptsInField" field="<${param.uri}>">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        SELECT DISTINCT ?deptUri ?deptLabel
        WHERE
        {
        ?person
        vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
        ?field .

        ?person
        vivo:holdFacultyAppointmentIn
        ?deptUri .

        ?deptUri
        rdf:type vivo:AcademicDepartment ;
        rdfs:label ?deptLabel .
        }
        ORDER BY ?deptLabel
        LIMIT 2000
    </listsparql:select>
</sparql:sparql>

<json:array name="Departments">

<c:forEach items="${deptsInField}" var="dept">
     <json:object>
         <json:property name="Label" value="${dept.deptLabel.string}"/>
         <json:property name="URI" value="${dept.deptUri}"/>
     </json:object>
</c:forEach>

</json:array>