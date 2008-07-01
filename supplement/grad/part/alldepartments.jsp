<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page import="java.net.URLDecoder" %>

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
              SELECT DISTINCT ?deptUri ?deptLabel ?deptLocation ?deptLocationLabel ?deptPageUrl ?campusLabel
              WHERE
              {
                  ?group rdf:type vivo:fieldCluster .

                  ?group vivo:hasAssociated ?field .
              
                  ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?field .

                  ?person vivo:holdFacultyAppointmentIn ?deptUri .

                  ?deptUri rdf:type vivo:AcademicDepartment .

              OPTIONAL { ?deptUri rdfs:label ?deptLabel }
              OPTIONAL { ?deptUri vivo:OrganizedEndeavorLocatedInFacility ?deptLocation . ?deptLocation rdfs:label ?deptLocationLabel }
              OPTIONAL { ?deptUri vitro:primaryLink ?deptLinksUri . ?deptLinksUri vitro:linkURL ?deptPageUrl }
              OPTIONAL { ?deptUri vivo:OrganizedEndeavorLocatedOnCampus ?campus . ?campus rdfs:label ?campusLabel }
              }
              ORDER BY ?deptLabel
              LIMIT 2000
    </sparql:select>
    
    <table cellspacing="0" summary="A list of all departments connected with graduate studies in Life Sciences at Cornell.">
        
      <thead>
        <tr>
            <th>Department</th>
            <th>Location</th>
            <th class="deptLink">Web page</th>
        </tr>
      </thead>
        <tbody>
            <c:forEach  items="${rs.rows}" var="dept" varStatus="counter">
                <c:url var="deptHref" value="departments.jsp"><c:param name="uri" value="${dept.deptUri}"/><c:param name="deptLabel" value="${dept.deptLabel.string}"/></c:url>
                <c:url var="deptLocationHref" value="/entity"><c:param name="uri" value="${dept.deptLocation}"/></c:url>
                <c:set var="deptPageLink" value="${dept.deptPageUrl.string}"/>
                    <tr>
                        <td class="deptName <c:if test='${counter.index == 0}'>firstRow</c:if>"><a href="${deptHref}" title="more about this department">${dept.deptLabel.string}</a></td>
                        <c:choose>
                            <c:when test="${!empty dept.deptLocationLabel.string}">
                                <td><%-- <a href="${deptLocationHref}" title="more about this location in VIVO"> --%>${dept.deptLocationLabel.string}<%-- </a> --%></td>
                            </c:when>
                            <c:otherwise>
                                <td><c:if test="${fn:contains(dept.campusLabel.string, 'New York')}">Weill Medical Center, New York City</c:if></td>
                            </c:otherwise>
                        </c:choose>
                        
                        <td class="deptLink"><a class="websnapr" href="<str:decodeUrl>${deptPageLink}</str:decodeUrl>" title="">Department Web page</a></td>
                    </tr>                    
            </c:forEach>
        </tbody>
    </table>

    </sparql:sparql>
