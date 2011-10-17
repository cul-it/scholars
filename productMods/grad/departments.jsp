<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ include file="part/resources.jsp" %>

<c:choose><%-- This is a temporary patch to account for entities outside of the usual VIVO namespace --%>
    <c:when test="${fn:contains(param.uri,'org') && !empty param.uri}">
    	<c:set var="URI">${namespace_hri2}${param.uri}</c:set>
    </c:when>
    <c:otherwise>
    	<c:set var="URI">${namespace}${param.uri}</c:set>
    </c:otherwise>
</c:choose>

<c:if test="${!empty param.uri}">
    <c:set var="metaDescription">
    	<c:import url="part/metadescriptions.jsp">
    	    <c:param name="uri" value="${URI}"/>
    	    <c:param name="type" value="department"/>
    	</c:import>
    </c:set>
</c:if>

<c:set var="deptName">
	<c:import url="part/label.jsp"><c:param name="uri" value="${URI}"/></c:import>
</c:set>

<c:set var="pageTitle">
    <c:if test="${!empty param.uri}">Department of ${deptName} | Cornell University</c:if>
    <c:if test="${empty param.uri}">Index of Departments | Cornell University</c:if>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="departments"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
    <jsp:param name="metaDescription" value="${metaDescription}"/>
</jsp:include>
        
        <hr/>
        
        <div id="contentWrap">
            <div id="content">
         
            <c:choose>
                <%-- render an individual department page --%>
                <c:when test="${not empty param.uri}">
                    <c:import url="templates/deptEntity.jsp">
                        <c:param name="uri" value="${URI}" />
                    </c:import>
                </c:when>
            
                <%-- or render a department index page --%>
                <c:otherwise>
<!--                     <sparql:lock
                model="${applicationScope.jenaOntModel}"> -->
                    <sparql:sparql>
    				    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">
        		              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        		              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        		              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        		              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        		              PREFIX core: <http://vivoweb.org/ontology/core#>
        		              SELECT DISTINCT ?deptUri ?deptLabel ?deptPageUrl ?deptPageAnchor ?campus ?campusLabel
                          WHERE {
                            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                              ?group rdf:type vivo:fieldCluster .
                              ?group vivo:hasAssociated ?field .
                              ?person vivo:memberOfGraduateField ?field .
                              ?person core:personInPosition ?facultyPosition .
                              ?facultyPosition core:positionInOrganization ?deptUri .
                              ?deptUri rdf:type core:AcademicDepartment .
                              OPTIONAL { ?deptUri rdfs:label ?deptLabel }
                              OPTIONAL { ?deptUri vivo:locatedOnCampus ?campus . ?campus rdfs:label ?campusLabel }
                              OPTIONAL { ?deptUri vitro:primaryLink ?deptLinksUri . ?deptLinksUri vitro:linkURL ?deptPageUrl . ?deptLinksUri vitro:linkAnchor ?deptPageAnchor }
                            }
                          }
                          ORDER BY ?deptLabel
        		              LIMIT 1000
    				    </sparql:select>

                        <h2>Department Index</h2>

    				    <table class="index span-23" cellspacing="0"="3" cellspacing="0"="0" border="1" summary="A list of all departments connected with graduate studies in Life Sciences at Cornell">

    				      <thead>
    				        <tr>
    				            <th>Department</th>
    				            <th>Location</th>
    				            <th class="deptLink">Web Page</th>
    				        </tr>
    				      </thead>
    				        <tbody>
    				            <c:forEach  items="${rs.rows}" var="dept" varStatus="counter">
    				                <c:url var="deptLocationHref" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${dept.deptLocation}"/></c:url>
    					            <c:set var="deptID" value="${fn:substringAfter(dept.deptUri,'/individual/')}"/>
    				                <c:set var="deptPageLink" value="${dept.deptPageUrl.string}"/>
				                    <tr>
				                        <td><a href="/departments/${deptID}" title="more about this department">${dept.deptLabel.string}</a></td>
				                        <c:choose>
				                            <c:when test="${fn:contains(dept.campusLabel.string,'New York City')}">
				                                <td>New York City</td>
				                            </c:when>
				                            <c:when test="${empty dept.campus}">
				                                <td>Ithaca, NY</td>
				                            </c:when>
				                            <c:otherwise>
				                                <td>${dept.campusLabel.string}</td>
				                            </c:otherwise>
				                        </c:choose>
				                        <td><a class="websnapr" href="<str:decodeUrl>${deptPageLink}</str:decodeUrl>" title="">official web page</a></td>
				                    </tr>                    
    				            </c:forEach>
    				        </tbody>
    				    </table>

				    </sparql:sparql>
<!-- 				    </sparql:lock> -->
                </c:otherwise>
            </c:choose>
                    
            </div><!-- content -->
        </div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>
