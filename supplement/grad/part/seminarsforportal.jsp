<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          xmlns:fmt="http://java.sun.com/jsp/jstl/fmt"
          xmlns:fn="http://java.sun.com/jsp/jstl/functions"
          version="2.0" >

<jsp:directive.page import="org.joda.time.DateTime" />
<jsp:directive.page contentType="text/xml; charset=UTF-8" />
<jsp:directive.page session="false" />

<jsp:scriptlet>
  DateTime now = new DateTime();
  request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\"" );
</jsp:scriptlet>

<sparql:sparql>
  <sparql:select model="${applicationScope.jenaOntModel}" var="rs"
                 now="${now}" >
    <![CDATA[

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

          ]]>
    </sparql:select>
    <fmt:setLocale value="en_US"/>    
        <ul>
            <c:forEach  items="${rs.rows}" var="talk" begin="0" varStatus="status">
                <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd" />
                <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0500'" />
                <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />
                
                <c:url var="seminarLink" value="/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                <c:url var="seminarHostLink" value="/entity"><c:param name="uri" value="${talk.person}"/></c:url>
                <c:set var="firstName" value="${fn:substringAfter(talk.hostname.string,',')}"/>
                <c:set var="lastName" value="${fn:substringBefore(talk.hostname.string,',')}"/>

                <c:set var="cleanClass"><c:if test="${status.count eq 2}">clean</c:if></c:set>
                
                <li class="vevent ${cleanClass}">
                    <span class="abbrStart floatLeft"><abbr title="${calendarStart}" class="dtstart">${seminarDate}</abbr></span>
                    <!-- <span class="abbrEnd"><abbr title="${calendarEnd}" class="dtend"> &amp;ndash; &amp;#63;</abbr></span> -->
                    <c:if test="${not empty talk.hostname.string}">
                        <p class="host floatRight"><a href="${seminarHostLink}">${fn:trim(firstName)}&amp;nbsp;${lastName}</a></p>
                    </c:if>
                    <p class="summary"><a href="${seminarLink}" class="url">${talk.label.string}</a></p> 
                    <p class="location">${talk.location.string}</p>
                    <p class="description">${talk.blurb.string}</p>
               </li>
            
            </c:forEach>
        </ul>
    </sparql:sparql>

</jsp:root>
