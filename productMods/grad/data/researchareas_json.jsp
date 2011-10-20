<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="researchResults" field="<${param.uri}>">
    PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
    PREFIX core: <http://vivoweb.org/ontology/core#>
    SELECT DISTINCT ?areaUri ?areaLabel ?personUri ?personLabel
    WHERE { 
        ?personUri vivo:memberOfGraduateField ?field . 
        ?areaUri core:researchAreaOf ?personUri . 
        OPTIONAL { ?areaUri rdfs:label ?areaLabel }
        OPTIONAL { ?personUri rdfs:label ?personLabel }  
    } ORDER BY ?areaLabel 
    LIMIT 2000
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<json:object prettyPrint="true">
     <json:array name="research">
     
    <c:forEach items="${researchResults}" var="research" varStatus="counter">
        
        <c:if test="${research.areaUri != previousUri}">
            <c:set var="activeUri" value="${research.areaUri}"/>
             <json:object>
                 <json:property name="ID" value="${fn:substringAfter(research.areaUri,'/individual/')}"/>
                 <json:property name="Label" value="${research.areaLabel.string}"/>
                 <json:property name="URI" value="${research.areaUri}"/>
                 <json:array name="Faculty">
                    <c:forEach items="${researchResults}" var="faculty">
                        <c:set var="facultyID" value="${fn:substringAfter(faculty.personUri,'/individual/')}"/>
                        <c:if test="${faculty.areaUri == activeUri}">
                            <json:property value="${facultyID}"/>
                        </c:if>
                    </c:forEach>
                 </json:array>
             </json:object>
        </c:if>
        <c:set var="previousUri" value="${research.areaUri}"/>
        
</c:forEach>
    
    </json:array>
</json:object>


