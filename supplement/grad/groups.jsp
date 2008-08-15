<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="groups"/>
    <jsp:param name="titleText" value="${param.label} | Cornell University"/>
</jsp:include>
        
        <c:if test="${empty param.uri}">
            <c:redirect url="gradfieldsIndex.jsp"/>
        </c:if>
        
        <div id="contentWrap">
        
            <%-- <div id="breadcrumbs" class="small">
                <ol>
                    <li class="first"><a class="first" href="index.jsp">Home</a></li>
                    <li class="second">
                        <c:choose>
                            <c:when test="${!empty param.label}">
                                <c:url var="groupHref" value="groups.jsp">
                                    <c:param name="uri" value="${param.uri}"/>
                                    <c:param name="label" value="${param.label}"/>
                                    <c:param name="class" value="${param.class}"/>
                                </c:url>
                                <span class="second ${param.class}">${param.label}</span>
                            </c:when>
                            <c:otherwise>
                                <span>Graduate Fields</span>
                            </c:otherwise>
                        </c:choose>
                    </li>
                </ol>
            </div> --%> <!-- breadcrumbs -->
        
            <div id="content">

                <h2 class="groupLabel ${param.class}">${param.label}</h2>

                <h3>Graduate Fields in this Area</h3>
                <ul class="fields">
                    <jsp:include page="part/listfields.jsp">
                        <jsp:param name="uri" value="${param.uri}"/>
                    </jsp:include>  
                </ul>
                    
                <sparql:sparql>
                  <listsparql:select model="${applicationScope.jenaOntModel}" var="programs" group="<${param.uri}>">
                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                    PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                    SELECT ?uri ?label ?url ?anchor
                    WHERE
                    {
                    ?group 
                    vivo:hasAssociatedGroup 
                    ?uri .
                    
                    ?uri
                    rdf:type 
                    vivo:ResearchProgramUnitOrCenter ;
                    rdfs:label ?label .
                    
                    OPTIONAL { ?uri vitro:primaryLink ?link . ?link vitro:linkURL ?url . ?link vitro:linkAnchor ?anchor }
                    
                    }
                    ORDER BY ?label
                    LIMIT 200
                  </listsparql:select>
                </sparql:sparql>
               
		<c:if test="${!empty programs}"> 
                <div class="gradEducation">
                    <h3>Related Programs</h3>
                      <ul class="related">
                      <c:forEach  items="${programs}" var="program">
                        <c:choose>
                            <c:when test="${!empty program.url.string}">
                                <c:set var="programHref"><str:decodeUrl>${program.url.string}</str:decodeUrl></c:set>                            </c:when>
                            <c:otherwise>
                                <c:url var="programHref" value="http://vivo.cornell.edu/entity">
                                    <c:param name="uri" value="${program.uri}"/>
                                </c:url>
                            </c:otherwise>
                        </c:choose>
                        <li><a title="${program.anchor.string}" href="${programHref}">${program.label.string}</a></li>
                      </c:forEach>
                      </ul>
                  </div>
                </c:if>
                    
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
                </sparql:sparql>
                
                
                <div class="gradEducation small">
                    <h3>Other Areas</h3>
                      <ul class="groupings">
                      <c:forEach  items="${gradGroupings}" var="grad">
                      <c:if test="${grad.group != param.uri}">
                        <c:set var="classForGrouping" value="${fn:substringAfter(grad.group,'#')}"/>
                            <c:url var="gradhref" value="groups.jsp">
                            <c:param name="uri" value="${grad.group}"/>
                            <c:param name="label" value="${grad.groupLabel.string}"/>
                            <c:param name="class" value="${classForGrouping}"/>
                        </c:url>
                        <li class="${classForGrouping}"><a href="${gradhref}">${grad.groupLabel.string}</a></li>
                      </c:if>
                      </c:forEach>
                      </ul>
                  </div>

                  <div class="gradEducation">
                      <h3>What are Graduate Fields?</h3>
                      <p>Graduate education at Cornell is organized by Fields, which group faculty by common academic interest.  Almost all Fields have an administrative home in a department.  In some cases the faculty comprising the Field are virtually the same as those comprising the department.  In other cases not all the departmental faculty are members of a Field with a home in that department, and many outside-departmental faculty are members.  Generally each Field acts independently in graduate student admissions, e.g. recruiting, selecting, financing, and interviewing prospective students who visit Cornell, although in some cases Fields recruit together.</p>
                      <%-- <p><strong>The first step in applying to Cornell's Graduate School is identifying which Field most closely matches your goals.</strong></p> --%>
                      <p>For more information visit the <a title="Cornell Graduate School Web site" href="http://www.gradschool.cornell.edu/index.php?p=9">Graduate School Web site</a></p>
                  </div>

            </div><!-- content -->

        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />
