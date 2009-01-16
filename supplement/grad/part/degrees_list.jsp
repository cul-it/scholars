<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!-- Given a field URI, produce a list of degrees offered -->

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>">
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT DISTINCT ?degreeAbbr
      WHERE {
          ?fieldUri vivo:offersAcademicDegree ?degree . 
          ?degree rdfs:label ?degreeLabel ;
                  vivo:degreeAbbreviation ?degreeAbbr .
      } ORDER BY DESC(?degreeAbbr)
      LIMIT 10
    </sparql:select>

        <c:forEach items="${rs.rows}" var="row" varStatus="count">
            ${row.degreeAbbr.string}<c:if test="${count.last == false}">, </c:if>
        </c:forEach>

</sparql:sparql>
</sparql:lock>
