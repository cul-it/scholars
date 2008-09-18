<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<sparql:sparql>
  <listsparql:select model="${applicationScope.jenaOntModel}" var="programs" group="<${param.uri}>">
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
    PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
    SELECT ?uri ?label ?url ?anchor
    WHERE
    {
    ?group 
    vivo:hasAssociatedGroup 
    ?uri .
    
    ?uri
    rdf:type 
    vivo:ResearchProgramUnitOrCenter ;
    rdfs:label ?label .
    
    OPTIONAL { ?uri vitro:primaryLink ?link . ?link vitro:linkURL ?url . ?link vitro:linkAnchor ?anchor }
    
    }
    ORDER BY ?label
    LIMIT 200
  </listsparql:select>
</sparql:sparql>

<c:if test="${!empty programs}"> 
<div class="gradEducation">
    <h3>Related Programs</h3>
      <ul class="related">
      <c:forEach  items="${programs}" var="program">
        <c:choose>
            <c:when test="${!empty program.url.string}">
                <c:set var="programHref"><str:decodeUrl>${program.url.string}</str:decodeUrl></c:set>                            
			</c:when>
            <c:otherwise>
                <c:url var="programHref" value="http://vivo.cornell.edu/entity">
                    <c:param name="uri" value="${program.uri}"/>
                </c:url>
            </c:otherwise>
        </c:choose>
        <li><a title="${program.anchor.string}" href="${programHref}">${program.label.string}</a></li>
      </c:forEach>
      </ul>
  </div>
</c:if>