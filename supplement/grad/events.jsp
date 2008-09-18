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
               
               DateTime past = now.plusDays(-200);
               request.setAttribute("past", "\"" + past.toDateTimeISO().toString() + "\"" );
               
               DateTime future = now.plusDays(90);
               request.setAttribute("future", "\"" + future.toDateTimeISO().toString() + "\"" );
        </jsp:scriptlet>
        
        <sparql:sparql>
          <listsparql:select model="${applicationScope.jenaOntModel}" var="upcomingEvents" now="${now}" future="${future}" >
                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                SELECT DISTINCT ?talkUri ?blurb ?label ?timekey ?hostname ?location ?person ?linkUrl
                WHERE
                {
                ?talkUri
                  rdf:type vivo:LectureSeminarOrColloquium ;
                  rdf:type vitro:Flag1Value1Thing ;
                  vitro:timekey ?timekey ;
                  vitro:sunrise ?sunrise ;
                  vitro:blurb   ?blurb ;
                  rdfs:label ?label .

                  OPTIONAL { 
                   ?talkUri vivo:eventHasHostPerson ?person .
                   ?person rdfs:label ?hostname .
                   ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?field .
                   ?field rdf:type vivo:GraduateField .
                   ?field vivo:associatedWith ?group . 
                   ?group rdf:type vivo:fieldCluster .
                   }
                   
                   OPTIONAL {
                   ?talkUri vivo:eventHeldInFacility ?place .
                   ?place rdfs:label ?location .
                   }
                   
                   OPTIONAL {
                   ?talkUri vitro:primaryLink ?link . 
                   ?link vitro:linkURL ?linkUrl .
                   }
                 FILTER( xsd:dateTime(?now) > ?sunrise && xsd:dateTime(?now) < ?timekey )
                }
                ORDER BY ?timekey
                LIMIT 15
            </listsparql:select>
              
            <listsparql:select model="${applicationScope.jenaOntModel}" var="pastEvents" now="${now}" past="${past}" >
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                  SELECT DISTINCT ?talkUri ?blurb ?label ?timekey ?hostname ?location ?person ?linkUrl
                  WHERE
                  {
                  ?talkUri
                    rdf:type vivo:LectureSeminarOrColloquium ;
                    rdf:type vitro:Flag1Value1Thing ;
                    vitro:timekey ?timekey ;
                    vitro:sunrise ?sunrise ;
                    vitro:blurb   ?blurb ;
                    rdfs:label ?label .

                   OPTIONAL { 
                    ?talkUri vivo:eventHasHostPerson ?person .
                    ?person rdfs:label ?hostname .
                    ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?field .
                    ?field rdf:type vivo:GraduateField .
                    ?field vivo:associatedWith ?group . 
                    ?group rdf:type vivo:fieldCluster .
                    }
                    
                    OPTIONAL {
                    ?talkUri vivo:eventHeldInFacility ?place .
                    ?place rdfs:label ?location .
                    }
                    
                    OPTIONAL {
                    ?talkUri vitro:primaryLink ?link . 
                    ?link vitro:linkURL ?linkUrl .
                    }
                   FILTER( xsd:dateTime(?now) > ?timekey  && xsd:dateTime(?past) < ?timekey )
                  }
                  ORDER BY DESC(?timekey)
                  LIMIT 15
              </listsparql:select>
              
            <fmt:setLocale value="en_US"/>
            <h2>Cornell Life Sciences Events</h2>
            
            <h3>Upcoming Events</h3>
            
            <c:choose>
            <c:when test="${fn:length(upcomingEvents) < 1}">
                <p>There are currently no events listed. New lectures, seminars and colloquia will be posted here as the academic semester approaches.</p>
            </c:when>
                <c:otherwise>
                    <c:if test="${fn:length(upcomingEvents) < 5}">
                        <p><strong>NOTE:</strong> This list is short due to the time of year. As the academic semester approaches new lectures, seminars and colloquia will be posted here.</p>
                    </c:if>
                    <ul>
                        <c:forEach  items="${upcomingEvents}" var="talk" begin="0" varStatus="status">
                            <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                            <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd' 'yyyy' - 'hh:mm a" />
                            <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                            <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />

                            <c:url var="seminarLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                            <c:url var="seminarHostLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${talk.person}"/><c:param name="name" value="${talk.hostname.string}"/></c:url>
                            <c:set var="firstName" value="${fn:substringAfter(talk.hostname.string,',')}"/>
                            <c:set var="lastName" value="${fn:substringBefore(talk.hostname.string,',')}"/>

                            <c:set var="cleanClass"><c:if test="${status.count eq 2}">clean</c:if></c:set>

                            <li class="vevent">
                            <dl>
                                <dt class="summary"><a href="<str:decodeUrl>${talk.linkUrl.string}</str:decodeUrl>" class="url">${talk.label.string}</a></dt>
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
                
                
                <h3>Recent Events</h3>
                <ul>
                    <c:forEach  items="${pastEvents}" var="talk" begin="0" varStatus="status">
                        <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                        <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd' 'yyyy' - 'hh:mm a" />
                        <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                        <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />

                        <c:url var="seminarLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                        <c:url var="seminarHostLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${talk.person}"/><c:param name="name" value="${talk.hostname.string}"/></c:url>
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