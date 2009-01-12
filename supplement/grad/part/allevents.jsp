<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>

<jsp:directive.page import="org.joda.time.DateTime" />

<jsp:scriptlet>
  DateTime now = new DateTime();
  request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\"" );
</jsp:scriptlet>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
  <sparql:select model="${applicationScope.jenaOntModel}" var="rs" now="${now}" through='"2008-05-24T13:26:51.363-04:00"'>


PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
SELECT DISTINCT ?group ?groupName ?event ?eventName ?timekey ?location ?locationName ?host ?hostName ?blurb
WHERE

{

?group 
rdf:type vivo:fieldCluster ;
rdfs:label ?groupName .

?group 
vivo:hasAssociated
?field .

?field
vivo:hasFieldMember
?person .

?person
vivo:employeeOfAsAcademicFacultyMember
?sponsor .

?sponsor
vivo:OrganizedEndeavorSponsorOfAssociatedEnumeratedSet 
?series .

?series
vivo:seminarOrLectureSeriesHasMemberTalk
?event .

?event
rdf:type vivo:LectureSeminarOrColloquium ;
vitro:timekey ?timekey ;
vitro:sunrise ?sunrise ;
vitro:blurb ?blurb ;
rdfs:label ?eventName .

    OPTIONAL{ ?event vivo:eventHasHostPerson ?host . ?host rdfs:label ?hostName }

    OPTIONAL { ?event vivo:eventHeldInFacility ?location . ?location rdfs:label ?locationName }

FILTER( xsd:dateTime(?now) > ?sunrise  && xsd:dateTime(?now) < ?timekey && xsd:dateTime(?through) > ?timekey )
}
ORDER BY ?groupName ?timekey
LIMIT 200
    </sparql:select>
    
        <table summary="Upcoming events and seminars related to graduate studies in Life Sciences at Cornell, organized by area of study">
            <caption>Upcoming Events and Seminars</caption>
            <thead>
                <tr>
                    <th scope="col">Grouping</th>
                    <th scope="col">Date</th>
                    <th scope="col">Title</th>
                    <th scope="col">Location</th>
                    <th scope="col">Host</th>
                    <th scope="col">Blurb</th>
                </tr>
            </thead>
            <tbody>
            
            <c:set var="sectionStriping" value="odd"/>
            
            <c:forEach  items="${rs.rows}" var="talk" begin="0" varStatus="status">
                <fmt:parseDate parseLocale="en_US" var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd" />
                <fmt:formatDate var="timeStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                <fmt:formatDate var="timeEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />
                
                <c:url var="seminarLink" value="/entity"><c:param name="uri" value="${talk.event}"/></c:url>
                <c:url var="seminarHostLink" value="/entity"><c:param name="uri" value="${talk.host}"/></c:url>
                <c:set var="firstName" value="${fn:substringAfter(talk.hostName.string,',')}"/>
                <c:set var="lastName" value="${fn:substringBefore(talk.hostName.string,',')}"/>
                
                <c:if test="${talk.group != prevGroup}">
                <c:choose>
                    <c:when test="${sectionStriping eq 'odd'}"><c:set var="sectionStriping" value="even"/></c:when>
                    <c:when test="${sectionStriping eq 'even'}"><c:set var="sectionStriping" value="odd"/></c:when>
                </c:choose>
                </tbody>
                <thead>
                    <tr>
                    <th>${talk.groupLabel.string}</th>
                    </tr>
                </thead>
                <tbody class="${sectionStriping}">
                </c:if>
                
                <tr>
                    <td>${talk.groupName.string}</td>
                    <td>${seminarDate}</td>
                    <c:url var="seminarLink" value="/entity"><c:param name="uri" value="${talk.event}"/></c:url>
                    <td><a href="${seminarLink}">${talk.eventName.string}</a></td>
                    <td>${talk.locationName.string}</td>
                    <td>${firstName} ${lastName}</td>
                    <td>${talk.blurb.string}</td>
                </tr>
                
                <c:set var="prevGroup" value="${talk.group}"/>
                

            </c:forEach>
            
            </tbody>
        </table>

    </sparql:sparql>
    </sparql:lock>
