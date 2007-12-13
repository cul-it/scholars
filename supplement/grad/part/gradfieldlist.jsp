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
              SELECT ?gradFieldUri ?gradFieldLabel
              WHERE
              {
              ?fieldCluster <http://vivo.library.cornell.edu/ns/0.1#hasAssocaited> ?gradFieldUri.
              ?gradFieldUri rdf:type <http://vivo.library.cornell.edu/ns/0.1#GraduateField>.
              OPTIONAL { ?gradFieldUri rdfs:label ?gradFieldLabel }
              }
              ORDER BY ?gradFieldUri
              LIMIT 200

          ]]>
    </sparql:select>

    <div > <!-- root tag from gradfieldgrouplist -->
        <ul>
      <c:forEach  items="${rs.rows}" var="gradfield">
            <li>
                <c:url var="gradhref" value="gradfield.jsp">
                    <c:param name="uri" value="${gradfield.gradFieldUri}"/>
                </c:url>
                <a href="${gradhref}">${gradfield.gradFieldLabel.string}</a>
            </li>
      </c:forEach>
        </ul>
    </div>  <!-- end tag from gradfieldgrouplist -->
  </sparql:sparql>

</jsp:root>
