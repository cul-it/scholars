<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

<%-- Given a URI, get a single label for that entity --%>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
  <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?label
    WHERE { 
        # SERVICE <http://sisler.mannlib.cornell.edu:8081/openrdf-sesame/repositories/courses2> { 
            ?uri rdfs:label ?label  
        # }
    }
    LIMIT 1
  </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:out value="${rs[0].label.string}"/>

