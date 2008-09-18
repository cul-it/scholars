<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:fn="http://java.sun.com/jsp/jstl/functions"
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
    
    <div class="leftColumn">
      <c:forEach items="${rs.rows}" var="row" begin="0" end="2" step="1">
            <c:set var="groupID" value="${fn:substringAfter(row.fieldClusterUri,'#')}"/>
            <h3 class="groupLabel ${groupID}"><a href="/areas/${groupID}">${row.clusterLabel.string}</a></h3>
            <ul>   
                <c:import url="part/listfields.jsp">
                    <c:param name="uri" value="${row.fieldClusterUri}"/>
                </c:import>
            </ul>
      </c:forEach>
    </div>
    
    <div class="rightColumn">
      <c:forEach items="${rs.rows}" var="row" begin="0" end="2" step="1">
          <c:set var="groupID" value="${fn:substringAfter(row.fieldClusterUri,'#')}"/>
          <h3 class="groupLabel ${groupID}"><a href="/areas/${groupID}">${row.clusterLabel.string}</a></h3>
          <ul>   
              <c:import url="part/listfields.jsp">
                  <c:param name="uri" value="${row.fieldClusterUri}"/>
              </c:import>
          </ul>
      </c:forEach>
     </div>

  </sparql:sparql>  
</jsp:root>

