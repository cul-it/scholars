<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.net.URLDecoder" %>
<%@ include file="part/resources.jsp" %>

<c:choose>
<c:when test="${fn:contains(param.uri,'org') && !empty param.uri}">
	<c:set var="URI">${namespace_hri2}${param.uri}</c:set>
</c:when>
<c:otherwise>
	<c:set var="URI">${namespace}${param.uri}</c:set>
</c:otherwise>
</c:choose>

<c:if test="${!empty param.uri}">
    <c:set var="metaDescription">
    	<c:import url="part/getmetadescription.jsp">
    	    <c:param name="uri" value="${URI}"/>
    	    <c:param name="type" value="department"/>
    	</c:import>
    </c:set>
</c:if>

<c:set var="deptName">
	<c:import url="part/getlabel.jsp"><c:param name="uri" value="${URI}"/></c:import>
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
        
        <div id="contentWrap">
            <div id="content" class="sevenUnit">
         
            <c:choose>
                <c:when test="${not empty param.uri}">
                    <c:import url="/entity">
                        <c:param name="portal" value="1" />
                        <c:param name="uri" value="${URI}" />
                        <c:param name="view" value="grad/templates/deptEntity.jsp" />
                    </c:import>
                </c:when>
            
                <c:otherwise>
                    <sparql:lock model="${applicationScope.jenaOntModel}">
                    <sparql:sparql>
				    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">

				              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
				              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
				              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
				              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
				              SELECT DISTINCT ?deptUri ?deptLabel ?deptLocation ?deptLocationLabel ?deptLocationUrl ?deptPageUrl ?campusLabel
				              WHERE
				              {
				                  ?group rdf:type vivo:fieldCluster .

				                  ?group vivo:hasAssociated ?field .

				                  ?person vivo:memberOfGraduateField ?field .

				                  ?person vivo:employeeOfAsAcademicFacultyMember ?deptUri .

				                  ?deptUri rdf:type vivo:AcademicDepartment .

				              OPTIONAL { ?deptUri rdfs:label ?deptLabel }
				              OPTIONAL { ?deptUri vivo:locatedInFacility ?deptLocation . ?deptLocation rdfs:label ?deptLocationLabel . ?deptLocation vitro:primaryLink ?deptLocationLink . ?deptLocationLink vitro:linkURL ?deptLocationUrl }
				              OPTIONAL { ?deptUri vitro:primaryLink ?deptLinksUri . ?deptLinksUri vitro:linkURL ?deptPageUrl }
				              OPTIONAL { ?deptUri vivo:locatedOnCampus ?campus . ?campus rdfs:label ?campusLabel }
				              }
				              ORDER BY ?deptLabel
				              LIMIT 2000
				    </sparql:select>

				    <table cellspacing="0" border="1" summary="A list of all departments connected with graduate studies in Life Sciences at Cornell.">

				      <thead>
				        <tr>
				            <th>Department</th>
				            <th>Location</th>
				            <th class="deptLink">Web page</th>
				        </tr>
				      </thead>
				        <tbody>
				            <c:forEach  items="${rs.rows}" var="dept" varStatus="counter">
				                <c:url var="deptLocationHref" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${dept.deptLocation}"/></c:url>
					            <c:set var="deptID" value="${fn:substringAfter(dept.deptUri,'#')}"/>
				                <c:set var="deptPageLink" value="${dept.deptPageUrl.string}"/>
				                    <tr<c:if test='${counter.index mod 2 != 0}'> class="even"</c:if>>
				                        <td class="deptName <c:if test='${counter.index == 0}'>firstRow</c:if>"><a href="/departments/${deptID}" title="more about this department">${dept.deptLabel.string}</a></td>
				                        <c:choose>
				                            <c:when test="${!empty dept.deptLocationLabel.string}">
				                                <td><a href="<str:decodeUrl>${dept.deptLocationUrl.string}</str:decodeUrl>" title="more about this location">${dept.deptLocationLabel.string}</a></td>
				                            </c:when>
				                            <c:otherwise>
				                                <td><c:if test="${fn:contains(dept.campusLabel.string, 'New York')}"><span>Weill Medical Center, New York City</span></c:if></td>
				                            </c:otherwise>
				                        </c:choose>

				                        <td class="deptLink"><a class="websnapr" href="<str:decodeUrl>${deptPageLink}</str:decodeUrl>" title="">Department Web page</a></td>
				                    </tr>                    
				            </c:forEach>
				        </tbody>
				    </table>

				    </sparql:sparql>
				    </sparql:lock>
                </c:otherwise>
            </c:choose>
                    
            </div><!-- content -->
        
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>