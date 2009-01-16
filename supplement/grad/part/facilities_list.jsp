<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<%-- Given a facilities tab URI, get the list of facilities in that tab --%>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
  <listsparql:select model="${applicationScope.jenaOntModel}" var="facilities" group="<${param.group}>">
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
    PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
    SELECT ?uri ?label ?url ?anchor ?blurb ?description 
    WHERE
    {
    ?tabConnector
    vitro:involvesTab
    ?group .
    
    ?tabConnector
    vitro:involvesIndividual
    ?uri .

    OPTIONAL { ?uri rdfs:label ?label }
    OPTIONAL { ?uri vitro:blurb ?blurb }
    OPTIONAL { ?uri vitro:description ?description }
    OPTIONAL { ?uri vitro:primaryLink ?facilityLinks . ?facilityLinks vitro:linkURL ?url . ?facilityLinks vitro:linkAnchor ?anchor }
    }
    ORDER BY ?label
    LIMIT 400
  </listsparql:select>
 </sparql:sparql>
 </sparql:lock>
          
<c:forEach  items="${facilities}" var="facility" varStatus="count">
    <li>
        <h4 class="facilityName"><a class="facilityPage" title="visit the ${facility.anchor.string}" href="<str:decodeUrl>${facility.url.string}</str:decodeUrl>">${facility.label.string}</a></h4>
        <div class="description">
            <c:if test="${empty facility.description.string}">${facility.blurb.string}</c:if>
            ${facility.description.string}
        </div>
    </li>
</c:forEach>
