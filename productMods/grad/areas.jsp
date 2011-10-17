<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ include file="part/resources.jsp" %>

<%-- Based on the uri parameter, this JSP will either: 
    1) forward to fieldsindex 
    2) render fields in a grouping 
    3) render a whole list of fields 
--%>

<c:if test="${empty param.uri}">
    <c:redirect url="/fieldsindex/"/>
</c:if>

<%-- For a particular field grouping, use this query --%>
<c:if test="${param.uri != 'allfields'}">
    <c:set var="URI">${namespace}${param.uri}</c:set>
    <c:set var="encodedURI"><str:encodeUrl>${URI}</str:encodeUrl></c:set>
    <c:set var="areaID">${param.uri}</c:set>
    <c:set var="areaName">
    	<c:import url="part/label.jsp"><c:param name="uri" value="${URI}"/></c:import>
    </c:set>

<!--     <sparql:lock model="${applicationScope.jenaOntModel}" > -->
        <sparql:sparql>
            <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" group="<${URI}>">
              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX core: <http://vivoweb.org/ontology/core#>
              SELECT DISTINCT ?fieldUri ?fieldLabel
              WHERE {
                 SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                  ?group vivo:hasAssociated ?fieldUri .
                  ?fieldUri vivo:hasFieldMember ?person .
                  OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                  }
              } ORDER BY ?fieldLabel
              LIMIT 100
            </listsparql:select>
        </sparql:sparql>
<!--     </sparql:lock> -->
</c:if>

<%-- For the entire list of fields use this query --%>
<c:if test="${param.uri == 'allfields'}">
    <c:set var="areaName" value="Life Sciences Graduate Fields"/>

<!--     <sparql:lock model="${applicationScope.jenaOntModel}" > -->
        <sparql:sparql>
            <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX core: <http://vivoweb.org/ontology/core#>
              SELECT DISTINCT ?fieldUri ?fieldLabel
              WHERE {
                SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                  ?group rdf:type vivo:fieldCluster .
                  ?group vivo:hasAssociated ?fieldUri .
                  ?fieldUri vivo:hasFieldMember ?person .
                  OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                }
              } ORDER BY ?fieldLabel
              LIMIT 100
            </listsparql:select>
        </sparql:sparql>
<!--     </sparql:lock> -->
</c:if>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="areas"/>
    <jsp:param name="titleText" value="${areaName} | Cornell University"/>
</jsp:include>

        <div id="contentWrap">
            <div id="content">

                <c:if test="${param.uri != 'allfields'}"><h2 class="${areaID} big">Graduate Fields related to <span>${areaName}</span></h2></c:if>
                <c:if test="${param.uri == 'allfields'}"><h2>All Life Sciences Graduate Fields</h2></c:if>
				
				<c:if test="${param.uri != 'allfields'}"><table cellpadding="3" cellspacing="0"="0" border="1"></c:if>
                <c:if test="${param.uri == 'allfields'}"><table class="complete" cellpadding="3" cellspacing="0" border="1"></c:if>
                    <thead>
                        <tr>
                            <th class="col-1">Field</th>
                            <th class="col-2">Degrees Offered</th>
                            <th class="col-3">Top Research Areas</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${rs}" var="field" varStatus="count">
                            <c:set var="classForField" value="${fn:substringAfter(field.fieldUri,'/individual/')}"/>
                            <c:import var="degrees" url="part/degrees_list.jsp">
                                <c:param name="uri" value="${field.fieldUri}"/>
                            </c:import>
                            <c:import var="topResearchAreas" url="part/researchareas_list.jsp">
                                <c:param name="uri" value="${field.fieldUri}"/>
                                <c:param name="type" value="field-ranked"/>
                            </c:import>
                            <c:choose>
                                <c:when test="${count.first == true}"><tr class="first"></c:when>
                                <c:when test="${count.last == true}"><tr class="last"></c:when>
                                <c:otherwise><tr></c:otherwise>
                            </c:choose>
                                    <td class="fields"><a href="/fields/${classForField}">${field.fieldLabel.string}</a></td>
                                    <td>${degrees}</td>
                                    <td>${topResearchAreas}</td>
                                </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
                <%-- <c:import var="programList" url="part/programs_list.jsp">
                    <c:param name="uri" value="${URI}"/>
                </c:import>
                <c:if test="{!empty programList}">
                    <div class="gradEducation">
                        <h3>Related Programs</h3>
                        <ul class="related">${programList}</ul>
                    </div>
                </c:if> --%>
                
                <c:if test="${param.uri != 'allfields'}">
                    <h3>Don't see what you're looking for?</h3>
                    <p>Try a different subject area below, or see a <a href="/allfields">complete list</a> of Fields instead</p>
    				<ul class="groupings small">
    					<jsp:include page="part/groups_list.jsp">
    	                    <jsp:param name="uri" value="${URI}"/>
    	                </jsp:include>
    				</ul>
				</c:if>

            </div><!-- content -->
        </div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>
