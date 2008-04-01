<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ page import="java.net.URLDecoder" %>

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
              SELECT DISTINCT ?deptUri ?deptLabel ?deptLocation ?deptLocationLabel ?deptPageUrl
              WHERE
              {
              ?group
              rdf:type
              vivo:fieldCluster .

              ?group
              vivo:hasAssociated
              ?field .
              
              ?person
              vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
              ?field .

              ?person
              vivo:CornellFacultyMemberInOrganizedEndeavor
              ?deptUri .

              ?deptUri
              rdf:type
              vivo:AcademicDepartment .

              OPTIONAL { ?deptUri rdfs:label ?deptLabel }
              OPTIONAL { ?deptUri vivo:OrganizedEndeavorLocatedInFacility ?deptLocation . ?deptLocation rdfs:label ?deptLocationLabel }
              OPTIONAL { ?deptUri vitro:primaryLink ?deptLinksUri . ?deptLinksUri vitro:linkURL ?deptPageUrl }
              
              }
              ORDER BY ?deptLabel
              LIMIT 2000
    </sparql:select>
    
    <table cellspacing="0">
      <thead>
        <tr>
            <td>Department</td>
            <td>Location</td>
            <td class="deptLink">Web page</td>
        </tr>
      </thead>
        <tbody>
            <c:forEach  items="${rs.rows}" var="dept" varStatus="counter">
                <c:url var="deptHref" value="departments.jsp"><c:param name="uri" value="${dept.deptUri}"/></c:url>
                <c:url var="deptLocationHref" value="/entity"><c:param name="uri" value="${dept.deptLocation}"/></c:url>
                <c:set var="deptPageLink" value="${dept.deptPageUrl.string}"/>
                    <tr>
                        <td class="deptName"><a href="${deptHref}" title="more about this department">${dept.deptLabel.string}</a></td>
                        <td><a href="${deptLocationHref}" title="more about this location in VIVO">${dept.deptLocationLabel.string}</a></td>
                        <td class="deptLink"><a href="<str:decodeUrl>${deptPageLink}</str:decodeUrl>" title="Department Web page">Link</a></td>
                    </tr>                    
            </c:forEach>
        </tbody>
    </table>

    </sparql:sparql>
