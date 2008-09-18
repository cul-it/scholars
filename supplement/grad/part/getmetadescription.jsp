<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<c:if test="${param.type == 'faculty'}">
    <sparql:sparql>
      <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        SELECT ?statement
        WHERE { ?uri vivo:overviewStatement ?statement }
        LIMIT 1
      </listsparql:select>
    </sparql:sparql>

    <str:truncateNicely lower="0" upper="200">${rs[0].statement.string}</str:truncateNicely>
</c:if>

<c:if test="${param.type == ('department' || 'field')}">
    <sparql:sparql>
      <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
        PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        SELECT ?description
        WHERE { ?uri vitro:description ?description }
        LIMIT 1
      </listsparql:select>
    </sparql:sparql>

    <str:truncateNicely lower="0" upper="180">${rs[0].description.string}</str:truncateNicely>
</c:if>

