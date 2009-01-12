<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:fn="http://java.sun.com/jsp/jstl/functions"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

<!-- given a graduate field cluster, produce a list of graduate fields with links -->

  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />
    
    <sparql:lock model="${applicationScope.jenaOntModel}" >
    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs" group="&lt;${param.uri}&gt;">
      <![CDATA[

          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          SELECT DISTINCT ?field ?fieldLabel ?groupLabel
          WHERE
          {

          ?group
          vivo:hasAssociated
          ?field .

          ?field
          vivo:hasFieldMember
          ?person .

          OPTIONAL { ?field rdfs:label ?fieldLabel }
          OPTIONAL { ?group rdfs:label ?groupLabel }
          }
          ORDER BY ?fieldLabel
          LIMIT 200

          ]]>
    </sparql:select>

      <c:forEach items="${rs.rows}" var="row">
        <c:set var="classForField" value="${fn:substringAfter(row.field,'#')}"/>
            <li class="${classForField}">
                <a href="/fields/${classForField}">${row.fieldLabel.string}</a>
            </li>
      </c:forEach>

  </sparql:sparql>
  </sparql:lock>
</jsp:root>

