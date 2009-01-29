<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="part/resources.jsp" %>

<c:choose>
    <c:when test="${!empty param.uri}">
    	<c:set var="activeAreaID">${param.uri}</c:set>
    	<c:set var="activeAreaURI">${namespace}${param.uri}</c:set>
    </c:when>
    <c:otherwise>
    	<c:remove var="activeAreaID"/>
    	<c:remove var="activeAreaURI"/>
    </c:otherwise>
</c:choose>

<c:set var="activeAreaLabel">
    <c:import url="part/label.jsp"><c:param name="uri" value="${activeAreaURI}"/></c:import>
</c:set>

<c:set var="pageTitle">
    <c:if test="${!empty param.uri}">Life Sciences Research Areas | Cornell University</c:if>
    <c:if test="${empty param.uri}">Life Sciences Research Areas | Cornell University</c:if>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="researchareas"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
    <jsp:param name="metaDescription" value="${metaDescription}"/>
</jsp:include>
        
<sparql:lock model="${applicationScope.jenaOntModel}">
<sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">
      PREFIX fn:  <http://www.w3.org/2005/xpath-functions#>
      PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT DISTINCT ?areaUri ?areaLabel
      WHERE {
          ?group rdf:type vivo:fieldCluster .
          ?group vivo:hasAssociated ?field .
          ?field vivo:hasFieldMember ?personUri .
          ?personUri vivo:PersonHasResearchArea ?areaUri .
          ?areaUri rdfs:label ?areaLabelRaw .
          LET (?areaLabel := str(?areaLabelRaw))
      } ORDER BY fn:lower-case(?areaLabel)
      LIMIT 1000
</sparql:select>

        
        <hr/>
        
        <div id="contentWrap">
            <div id="content">
                    
                    <div id="areaList" class="span-8 last">
                        
                        <h2>Research Areas</h2>
                        <em class="hide">Hold shift to select multiple</em>
                        
                        <div>
                            <c:choose>
                                <c:when test="${empty param.uri}">
                                    <div id="statusBox" class="empty"><p></p></div>
                                    <%-- <p><em>Select research areas to see applicable Fields</em></p> --%>
                                </c:when>
                                <c:otherwise>
                                    <div id="statusBox">
                                        <p>currently selected:</p>
                                        <ul class="selectedAreas">
                                            <li class="${activeAreaID}"><strong>${activeAreaLabel}</strong> (<a class="toggle remove" href="/researchareas/">remove</a>)</li>
                                        </ul>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div id="scrollBox">
                                <%-- <c:set var="total" value="${fn:length(rs)}"/> --%>
                                <ul>
                                    <c:forEach items="${rs.rows}" var="row">
                                        <c:set var="areaID" value="${fn:substringAfter(row.areaUri,'#')}"/>
                                        <c:if test="${param.options == 'showfaculty'}"><c:set var="facultyVisibilityParameter" value="showfaculty"/></c:if>
                                        <li id="${areaID}">
                                        <c:choose>
                                            <c:when test="${areaID == activeAreaID}"><a class="selected" href="/researchareas/${areaID}">${row.areaLabel.string}</a></c:when>
                                            <c:otherwise><a href="/researchareas/${areaID}/${facultyVisibilityParameter}">${row.areaLabel.string}</a></c:otherwise>
                                        </c:choose>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </div>
                            <div class="bottom"></div>
                        </div>
                        
                    </div>
                    
                    <c:if test="${param.options == 'showfaculty'}"><c:set var="showfaculty" value="yes"/></c:if>
                    <c:if test="${param.options != 'showfaculty'}"><c:set var="showfaculty" value="no"/></c:if>
                    
                    <c:choose>
                        <c:when test="${!empty activeAreaID}">
                            <div id="fields" class="span-15 last">
                                <c:if test="${!empty param.home}">
                                    <div class="description span-14">
                                        <p><em>This page lets you identify Graduate Fields and faculty involved with specific types of research. Below are Graduate Fields that involve research in <strong>${activeAreaLabel}.</strong></em></p>
                                        <noscript><p><strong>NOTE: To select multiple areas you need to enable JavaScript in your browser.</strong></p></noscript>
                                    </div>
                                </c:if>
                                <c:import url="part/researchareas_content.jsp">
                                    <c:param name="id" value="${activeAreaID}"/>
                                    <c:param name="type" value="singleArea"/>
                                    <c:param name="showfaculty" value="${showfaculty}"/>
                                </c:import>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div id="fields" class="span-15 last">
                        
                                <div class="description span-14">
                                    <p>This page lets you identify Graduate Fields that involve specific types of research. You can also find out which faculty are conducting that research.</p>
                                    <p>Try selecting an area from the list. Select more than one to find faculty conducting unique combinations of research.</p>
                                    <noscript><p><strong>NOTE: To select multiple areas you need to enable JavaScript in your browser.</strong></p></noscript>
                                </div>
                                <%-- <h3>All Life Sciences Graduate Fields</h3>
                                                                <c:import url="part/fields_list.jsp">
                                                                    <c:param name="type" value="all"/>
                                                                    <c:param name="columns" value="no"/>
                                                                </c:import> --%>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    
                    
            </div><!-- content -->
        </div> <!-- contentWrap -->

</sparql:sparql>
</sparql:lock>
<hr/>
<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>