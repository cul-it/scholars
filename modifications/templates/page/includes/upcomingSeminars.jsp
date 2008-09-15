<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="org.joda.time.DateTime" %>
<%@ page import="org.joda.time.Period" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
  DateTime now = new DateTime();
  DateTime almostNow = now.minus(Period.hours(1));
  request.setAttribute("now", "\"" + almostNow.toString("yyyy-MM-dd'T'HH:mm:ss") + "\"" );
  request.setAttribute("now2", new Date());
%>

<sparql:lock model="${applicationScope.jenaOntModel}" > 
<sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs" now="${now}" >
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
          ?talkUri vivo:eventHeldInFacility ?place .


          ?place rdfs:label ?location .

         }
         FILTER( xsd:dateTime(?now) >= xsd:dateTime(?sunrise) && xsd:dateTime(?now) <= xsd:dateTime(?timekey) )
        }
        ORDER BY ?timekey
        LIMIT 5
    </sparql:select>
    
    <fmt:setLocale value="en_US"/>    
    
    <c:set var="prevDate" value="" />
    
    <c:forEach  items="${rs.rows}" var="talk" begin="0" varStatus="status">
        <fmt:parseDate var="seminarTimekey" value="${talk.timekey.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
        <fmt:formatDate var="seminarDate" value="${seminarTimekey}" pattern="EEEE', 'MMM'. 'd' 'yyyy" />
        <fmt:formatDate var="seminarTime" value="${seminarTimekey}" pattern="h:mm a" />
        <fmt:formatDate var="todaysDate" value="${now2}" pattern="EEEE', 'MMM'. 'd' 'yyyy" />
        <fmt:formatDate var="calendarStart" value="${seminarTimekey}" pattern="yyyyMMdd'T'HHmm'-0400'" />
        <fmt:formatDate var="calendarEnd" value="${seminarTimekey}" pattern="yyyyMMdd" />
        
        <c:url var="seminarLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
        
        <c:if test="${prevDate != seminarDate}">
            <c:if test="${status.count != 1}">
                </ul>
            </c:if>
            <c:choose>
                <c:when test="${todaysDate == seminarDate}">
                    <h5>Today</h5>
                </c:when>
                <c:otherwise>
                    <h5>${seminarDate}</h5>
                </c:otherwise>
            </c:choose>
                <ul>
        </c:if>       
        
        <li class="vevent">
            <abbr title="${calendarStart}" class="dtstart"><span class="abbrStart">${seminarTime}</span></abbr>
            <!-- <span class="abbrEnd"><abbr title="${calendarEnd}" class="dtend"> &amp;ndash; &amp;#63;</abbr></span> -->
            <p class="summary"><a href="${seminarLink}" class="url">${talk.label.string}</a></p> 
       </li>
       
       <c:if test="${status.count == 5}">
            </ul>
       </c:if>
       
       <c:set var="prevDate" value="${seminarDate}" />
    
    </c:forEach>
</sparql:sparql>
</sparql:lock>