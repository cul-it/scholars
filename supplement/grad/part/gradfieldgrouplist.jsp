<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"   
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />

  <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">
      <![CDATA[

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              SELECT ?fieldClusterUri ?clusterLabel
              WHERE
              {
              ?fieldClusterUri rdf:type vivo:fieldCluster
              OPTIONAL { ?fieldClusterUri rdfs:label ?clusterLabel }
              }
              ORDER BY ?clusterLabel
              LIMIT 200

          ]]>
    </sparql:select>
    
    <div> <!-- root tag from gradfieldgrouplist -->
        <ul class="fields">
      <c:forEach  items="${rs.rows}" var="row">
            <li>
                <c:url var="gradhref" value="fields.jsp">
                  <c:param name="label" value="${row.clusterLabel.string}"/>
                  <c:param name="uri" value="${row.fieldClusterUri}"/>
                </c:url>
                <a class="CLASS_BASED_ON_GROUP_NAME" href="${gradhref}">${row.clusterLabel.string}</a>
            </li>
      </c:forEach>
        </ul>
    </div>  <!-- end tag from gradfieldgrouplist -->
  </sparql:sparql>  
</jsp:root>

