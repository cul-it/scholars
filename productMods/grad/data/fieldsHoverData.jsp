<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="groupFields" group="<${param.uri}>">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        PREFIX core: <http://vivoweb.org/ontology/core#>
        SELECT DISTINCT ?field ?fieldLabel ?fieldDescription
        WHERE {
          ?group rdf:type vivo:fieldCluster ;
            vivo:hasAssociated ?field .
          ?field vivo:hasFieldMember ?person .
          OPTIONAL { ?field vitro:description ?fieldDescription }
          OPTIONAL { ?field rdfs:label ?fieldLabel }
        }
        ORDER BY ?fieldLabel
        LIMIT 2000
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<json:object prettyPrint="true">
    <json:array name="Fields" >
<c:forEach items="${groupFields}" var="group">

         <json:object>
             <json:property name="ID" value="${fn:substringAfter(group.field,'/individual/')}"/>
             <json:property name="Label" value="${group.fieldLabel.string}"/>
             <json:property name="URI" value="${group.field}"/>
             <json:property name="Description" value="${group.fieldDescription.string}" escapeXml="false"/>
                <c:import url="fieldsHoverData-departments.jsp">
                    <c:param name="uri" value="${group.field}"/>
                </c:import>
         </json:object>

    <c:set var="previousUri" value="${group.field}"/>
        
</c:forEach>
    </json:array>
</json:object>
