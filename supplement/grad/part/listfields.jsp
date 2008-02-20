<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

<!-- given a graduate field cluster, produce a list of graduate fields with links -->

  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />
    

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs"
	            fieldCluster="&lt;${param.uri}&gt;">
      <![CDATA[

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              SELECT ?gradFieldUri ?gradFieldLabel
              WHERE
              {
              ?fieldCluster vivo:hasAssociated ?gradFieldUri.
              OPTIONAL { ?gradFieldUri rdfs:label ?gradFieldLabel }
              }
              ORDER BY ?gradFieldLabel
              LIMIT 200

          ]]>
    </sparql:select>

    <ul class="fields">
      <c:forEach  items="${rs.rows}" var="gradfield">
            <li>
                <c:url var="fieldhref" value="singlefields.jsp">
                    <c:param name="uri" value="${gradfield.gradFieldUri}"/>
                    <c:param name="fieldLabel" value="${gradfield.gradFieldLabel.string}"/>
                    <c:param name="groupLabel" value="${param.groupLabel}"/>
                    <c:param name="groupUri" value="${param.uri}"/>
                    <c:param name="groupClass" value="${param.groupClass}"/>       
                </c:url>
                <a href="${fieldhref}">${gradfield.gradFieldLabel.string}</a>
            </li>
      </c:forEach>
    </ul>

  </sparql:sparql>
</jsp:root>

