<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="faculty" person="<${param.uri}>">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        SELECT DISTINCT ?name ?moniker ?email ?image
        WHERE {

        ?person rdfs:label ?name .
        
        OPTIONAL { ?person vitro:imageThumb ?image }
        OPTIONAL { ?person vitro:moniker ?moniker }
        OPTIONAL { ?person vivo:CornellemailnetId ?email }
        
        }
        LIMIT 1
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:forEach var="person" items="${faculty}" begin="0" end="0">
    <c:url var="imageSrc" value="../images/${person.image.string}"/>
    <img src="${imageSrc}" alt=""/>
    <h4>${person.name.string}</h4>
    <em>${person.moniker.string}</em>
</c:forEach>