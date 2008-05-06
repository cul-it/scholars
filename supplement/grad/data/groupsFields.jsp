<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="groupsFieldsDepts">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        SELECT DISTINCT ?group ?groupLabel ?field ?fieldLabel ?fieldDescription
        WHERE {

        ?group 
        rdf:type vivo:fieldCluster ;
        rdfs:label ?groupLabel .

        ?group 
        vivo:hasAssociated
        ?field .

        ?field
        vivo:AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember
        ?person .

        OPTIONAL { ?field vitro:description ?fieldDescription }
        OPTIONAL { ?field rdfs:label ?fieldLabel }
        }
        ORDER BY ?groupLabel ?fieldLabel
        LIMIT 2000
    </listsparql:select>
</sparql:sparql>

<json:object prettyPrint="true">
     <json:array name="Groups">
     
    <c:forEach items="${groupsFieldsDepts}" var="grad" varStatus="counter">
        
        <c:if test="${grad.group != previousUri}">
            <c:set var="activeUri" value="${grad.group}"/>
             <json:object>
                 <json:property name="ID" value="${fn:substringAfter(grad.group,'#')}"/>
                 <json:property name="Label" value="${grad.groupLabel.string}"/>
                 <json:property name="URI" value="${grad.group}"/>
                 <json:array name="Fields">
                    <c:forEach items="${groupsFieldsDepts}" var="grad2">
                        <c:set var="fieldID" value="${fn:substringAfter(grad2.field,'#')}"/>
                        <c:if test="${grad2.group == activeUri}">
                            <json:object>
                                <json:property name="ID" value="${fieldID}"/>
                                <json:property name="Label" value="${grad2.fieldLabel.string}"/>
                                <json:property name="URI" value="${grad2.field}"/>
                                <json:property name="Description" value="${grad2.fieldDescription.string}" escapeXml="false"/>
                                <c:import url="groupsFields-departments.jsp">
                                    <c:param name="uri" value="${grad2.field}"/>
                                </c:import>
                            </json:object>   
                        </c:if>
                    </c:forEach>
                 </json:array>
             </json:object>
        </c:if>
        <c:set var="previousUri" value="${grad.group}"/>
        
</c:forEach>
    
    </json:array>
</json:object>
