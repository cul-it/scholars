<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="eventindex"/>
    <jsp:param name="titleText" value="Life Sciences Events | Cornell University"/>
</jsp:include>

<div id="contentWrap">
	<div id="content">

        <jsp:directive.page import="org.joda.time.DateTime" />
        <jsp:directive.page session="false" />

        <jsp:scriptlet>
               DateTime now = new DateTime();
               request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\"" );
               
               DateTime past = now.plusDays(-90);
               request.setAttribute("past", "\"" + past.toDateTimeISO().toString() + "\"" );
        </jsp:scriptlet>
        
        <sparql:sparql>
          <listsparql:select model="${applicationScope.jenaOntModel}" var="upcoming" now="${now}" >
                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                SELECT DISTINCT ?talkUri ?blurb ?label ?timekey ?hostname ?location ?person
                WHERE
                {
                ?talkUri
                  rdf:type vivo:LectureSeminarOrColloquium ;
                  rdf:type vitro:Flag1Value1Thing ;
                  vitro:timekey ?timekey ;
                  vitro:sunrise ?sunrise ;
                  vitro:blurb   ?blurb ;
                  rdfs:label ?label .

                 OPTIONAL{
                  ?talkUri
                      vivo:eventHasHostPerson ?person ;
                      vivo:eventHeldInFacility ?place .

                  ?person rdfs:label ?hostname .

                  ?place rdfs:label ?location .

                 }
                 FILTER( xsd:dateTime(?now) > ?sunrise  && xsd:dateTime(?now) < ?timekey )
                }
                ORDER BY ?timekey
                LIMIT 2
            </listsparql:select>
              
            <listsparql:select model="${applicationScope.jenaOntModel}" var="past" now="${now}" past="${past}" >
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                  SELECT DISTINCT ?talkUri ?blurb ?label ?timekey ?hostname ?location ?person
                  WHERE
                  {
                  ?talkUri
                    rdf:type vivo:LectureSeminarOrColloquium ;
                    rdf:type vitro:Flag1Value1Thing ;
                    vitro:timekey ?timekey ;
                    vitro:sunrise ?sunrise ;
                    vitro:blurb   ?blurb ;
                    rdfs:label ?label .

                   OPTIONAL{
                    ?talkUri
                        vivo:eventHasHostPerson ?person ;
                        vivo:eventHeldInFacility ?place .

                    ?person rdfs:label ?hostname .
                    
                    ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?field .

                    ?field rdf:type vivo:GraduateField .
                    
                    ?field vivo:associatedWith ?group . 
                    
                    ?group rdf:type vivo:fieldCluster .

                    ?place rdfs:label ?location .

                   }
                   FILTER( xsd:dateTime(?now) > ?timekey  && xsd:dateTime(?past) < ?timekey )
                  }
                  ORDER BY DESC(?timekey)
                  LIMIT 30
              </listsparql:select>
              
            <fmt:setLocale value="en_US"/>
            <h2>Cornell Life Sciences Events</h2>
            
            <h3>Upcoming Events</h3>
            
            <c:choose>
            <c:when test="${fn:length(upcoming) < 3}">
                <p>There are currently no Life Sciences events listed. New lectures, seminars and colloquia will be posted here as the academic semester approaches.</p>
            </c:when>
                <c:otherwise>
                    <ul>
                        <c:forEach  items="${upcoming}" var="talk" begin="0" varStatus="status">
                            <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                            <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd' 'yyyy' - 'hh:mm a" />
                            <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                            <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />

                            <c:url var="seminarLink" value="/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                            <c:url var="seminarHostLink" value="/entity"><c:param name="uri" value="${talk.person}"/><c:param name="name" value="${talk.hostname}"/></c:url>
                            <c:set var="firstName" value="${fn:substringAfter(talk.hostname.string,',')}"/>
                            <c:set var="lastName" value="${fn:substringBefore(talk.hostname.string,',')}"/>

                            <c:set var="cleanClass"><c:if test="${status.count eq 2}">clean</c:if></c:set>

                            <li class="vevent">
                            <dl>
                                <dt class="summary"><a href="${seminarLink}" class="url">${talk.label.string}</a></dt>
                                <dd>Date: <abbr title="${calendarStart}" class="dtstart">${seminarDate}</abbr></span></dd>
                                <!-- <span class="abbrEnd"><abbr title="${calendarEnd}" class="dtend"> &amp;ndash; &amp;#63;</abbr></span> -->
                                <c:if test="${not empty talk.hostname.string}">
                                    <dd>Hosted by: <a class="host" href="${seminarHostLink}">${fn:trim(firstName)}&nbsp;${lastName}</a></dd>
                                </c:if>
                                <c:if test="${not empty talk.location.string}">
                                    <dd>Location: <span class="location">${talk.location.string}</span></dd>
                                </c:if>
                                <c:if test="${not empty talk.blurb.string}">
                                    <dd>Speakers: <span class="description">${talk.blurb.string}</span></dd>
                                </c:if>
                            </dl>
                           </li>

                        </c:forEach>
                    </ul>
                    </c:otherwise>
                </c:choose>
                
                
                <h3>Past Events</h3>
                <ul>
                    <c:forEach  items="${past}" var="talk" begin="0" varStatus="status">
                        <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                        <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd' 'yyyy' - 'hh:mm a" />
                        <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                        <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />

                        <c:url var="seminarLink" value="/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                        <c:url var="seminarHostLink" value="faculty.jsp"><c:param name="uri" value="${talk.person}"/></c:url>
                        <c:set var="firstName" value="${fn:substringAfter(talk.hostname.string,',')}"/>
                        <c:set var="lastName" value="${fn:substringBefore(talk.hostname.string,',')}"/>

                        <c:set var="cleanClass"><c:if test="${status.count eq 2}">clean</c:if></c:set>

                        <li class="vevent">
                        <dl>
                            <dt class="summary"><a href="${seminarLink}" class="url">${talk.label.string}</a></dt>
                            <dd>Date: <abbr title="${calendarStart}" class="dtstart">${seminarDate}</abbr></span></dd>
                            <!-- <span class="abbrEnd"><abbr title="${calendarEnd}" class="dtend"> &amp;ndash; &amp;#63;</abbr></span> -->
                            <c:if test="${not empty talk.hostname.string}">
                                <dd>Hosted by: <a class="host" href="${seminarHostLink}">${fn:trim(firstName)}&nbsp;${lastName}</a></dd>
                            </c:if>
                            <c:if test="${not empty talk.location.string}">
                                <dd>Location: <span class="location">${talk.location.string}</span></dd>
                            </c:if>
                            <c:if test="${not empty talk.blurb.string}">
                                <dd>Speakers: <span class="description">${talk.blurb.string}</span></dd>
                            </c:if>
                        </dl>
                       </li>

                    </c:forEach>
                </ul>
            </sparql:sparql>
      
	</div> <!-- content -->
</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />