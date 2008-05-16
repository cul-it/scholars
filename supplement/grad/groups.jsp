<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="groups"/>
    <jsp:param name="titleText" value="${param.label} - Life Sciences Graduate Programs at Cornell"/>
</jsp:include>
        
        <c:if test="${empty param.uri}">
            <c:redirect url="gradfieldsIndex.jsp"/>
        </c:if>
        
        <div id="contentWrap">
        
        <!-- <div id="breadcrumbs" class="small">
            <ol>
                <li class="first"><a class="first" href="index.jsp">Home</a></li>
                <li class="second">${param.groupLabel}</li>
            </ol>
        </div>  -->
        
            <div id="content">

                    <h2 class="groupLabel ${param.class}">${param.label}</h2>

                    <h3>Graduate Fields in this area</h3>
                    <ul class="fields">
                        <jsp:include page="part/listfields.jsp">
                            <jsp:param name="uri" value="${param.uri}"/>
                        </jsp:include>  
                    </ul>
                    
                    <div id="groupList" class="small">
                        <sparql:sparql>
                          <listsparql:select model="${applicationScope.jenaOntModel}" var="gradGroupings">
                            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                            PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                            SELECT ?group ?groupLabel
                            WHERE
                            {
                            ?group rdf:type vivo:fieldCluster
                            OPTIONAL { ?group rdfs:label ?groupLabel }
                            }
                            ORDER BY ?groupLabel
                            LIMIT 200
                          </listsparql:select>

                          <h3>Other Areas</h3>
                          <ul class="groupings">
                              <c:forEach  items="${gradGroupings}" var="grad">
                                <c:if test="${grad.group != param.uri}">
                                  <c:set var="classForGrouping" value="${fn:substringAfter(grad.group,'#')}"/>
                      	          <c:url var="gradhref" value="groups.jsp">
                                      <c:param name="label" value="${grad.groupLabel.string}"/>
                                      <c:param name="uri" value="${grad.group}"/>
                                      <c:param name="groupLabel" value="${grad.groupLabel.string}"/>
                                      <c:param name="groupClass" value="${classForGrouping}"/>
                                  </c:url>
                                  <li class="${classForGrouping}"><a href="${gradhref}">${grad.groupLabel.string}</a></li>
                              </c:if>
                            </c:forEach>
                          </ul>

                        </sparql:sparql>
                    </div>
                    
            </div><!-- content -->

        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />