<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- first get a list of groupings --%>
<!-- <sparql:lock model="${applicationScope.jenaOntModel}" > -->
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT ?fieldClusterUri ?clusterLabel
          WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?fieldClusterUri rdf:type vivo:fieldCluster
              OPTIONAL { ?fieldClusterUri rdfs:label ?clusterLabel }
              }
          } ORDER BY ?clusterLabel
          LIMIT 200
    </listsparql:select>
</sparql:sparql>
<!-- </sparql:lock> -->

<%-- when a sorting parameter is present, set a session variable to mark it as a preference --%>
<c:choose>
    <c:when test="${param.list == 'alphabetical'}">
        <c:set var="sorting" value="alphabetical" scope="session"/>
    </c:when>
    <c:when test="${param.list == 'grouped'}">
        <c:set var="sorting" value="grouped" scope="session"/>
    </c:when>
</c:choose>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fieldsindex"/>
    <jsp:param name="titleText" value="Life Sciences Graduate Fields | Cornell University"/>
</jsp:include>
		
		<div id="contentWrap">
		    
			<div id="content" class="span-23 last">
								
                <h2>What are Graduate Fields?</h2>
                <p>Graduate education at Cornell is organized by Fields, which group faculty by common academic interest.  Almost all Fields have an administrative home in a department.  In some cases the faculty comprising the Field are virtually the same as those comprising the department. Generally each Field acts independently in graduate student admissions, e.g. recruiting, selecting, financing, and interviewing prospective students who visit Cornell, although in some cases Fields recruit together.</p>
                <p>For more information visit the <a title="Cornell Graduate School Web site" href="http://www.gradschool.cornell.edu/index.php?p=9">Graduate School Web site</a></p>
				
				<div class="headingBox">
    				<h2>Life Sciences Graduate Fields</h2>
    				<c:choose>
        				<c:when test="${param.list == 'alphabetical' || sorting == 'alphabetical'}">
        				    <p>Listed alphabetically &mdash; show <a class="toggle" href="/fieldsindex/?list=grouped">grouped by subject area</a> instead</p>
        				</c:when>
        				<c:otherwise>
        				    <p>Grouped by subject area &mdash; show <a class="toggle" href="/fieldsindex/?list=alphabetical">alphabetical list</a> instead</p>
        				</c:otherwise>
    				</c:choose>
				</div>

                <c:choose>
                    <c:when test="${param.list == 'alphabetical' || sorting == 'alphabetical'}">
                        <c:import url="part/fields_list.jsp">
                            <c:param name="type" value="all"/>
                            <c:param name="columns" value="yes"/>
                        </c:import>
                    </c:when>
                    <c:otherwise>
                        <%-- go through each grouping and import a list of fields --%>
        				<div class="span-11 clear">
                            <c:forEach items="${rs}" var="row" begin="0" end="2" step="1">
                                <c:set var="groupID" value="${fn:substringAfter(row.fieldClusterUri,'/individual/')}"/>
                                <h3 class="${groupID}"><a href="/areas/${groupID}">${row.clusterLabel.string}</a></h3>
                                <ul class="fields">   
                                    <c:import url="part/fields_list.jsp">
                                        <c:param name="uri" value="${row.fieldClusterUri}"/>
                                        <c:param name="type" value="group"/>
                                    </c:import>
                                </ul>
                            </c:forEach>
                        </div>
                        <div class="span-12 last">
                            <c:forEach items="${rs}" var="row" begin="3" step="1">
                              <c:set var="groupID" value="${fn:substringAfter(row.fieldClusterUri,'/individual/')}"/>
                              <h3 class="${groupID}"><a href="/areas/${groupID}">${row.clusterLabel.string}</a></h3>
                              <ul class="fields">   
                                  <c:import url="part/fields_list.jsp">
                                      <c:param name="uri" value="${row.fieldClusterUri}"/>
                                      <c:param name="type" value="group"/>
                                  </c:import>
                              </ul>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
						
			</div><!-- content -->
		</div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp" />
