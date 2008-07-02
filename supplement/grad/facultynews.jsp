<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="newsindex"/>
    <jsp:param name="titleText" value="Life Sciences News | Cornell University"/>
</jsp:include>

<div id="contentWrap">
	<div id="content">

        <jsp:directive.page import="org.joda.time.DateTime" />
        <jsp:directive.page session="false" />

        <jsp:scriptlet>
               DateTime now = new DateTime();
               request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\"" );
        </jsp:scriptlet>
        
        <sparql:sparql>
        <sparql:select model="${applicationScope.jenaOntModel}" var="rs" now="${now}" >

                     PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                     PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                     PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
                     PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                     PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                     SELECT DISTINCT ?news ?newsLabel ?blurb ?sourceLink ?newsThumb ?moniker ?sunrise
                     WHERE
                     {

                     ?group
                     rdf:type
                     vivo:fieldCluster .

                     ?group
                     vivo:hasAssociated
                     ?field .

                     ?field
                     vivo:AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember
                     ?person .

                     ?news
                       vivo:featuresPerson2 ?person ;
                       vitro:sunrise ?sunrise ;
                       vitro:primaryLink ?link ;
                       vitro:blurb ?blurb ;
                       rdfs:label ?newsLabel .

                       ?link vitro:linkURL ?sourceLink .

                      OPTIONAL { ?news vitro:imageThumb ?newsThumb }
                      
                      OPTIONAL { ?news vitro:moniker ?moniker }
                      
                      FILTER( xsd:dateTime(?now) > ?sunrise )
                     }
                     ORDER BY DESC(?sunrise)
                     LIMIT 40

           </sparql:select>

           <h2>Cornell Life Sciences News</h2>
               <ul>
                   <c:forEach  items="${rs.rows}" var="item" begin="0" end="40" varStatus="count">
                       <li <c:if test='${count.index mod 2 == 0}'>class="odd"</c:if>>
        			        <c:url var="image" value="/images/${item.newsThumb.string}"/>
                            <c:if test="${!empty item.newsThumb.string}">
                                <a title="full ${item.moniker.string}" href="${item.sourceLink.string}"><img width="150" src="${image}" alt="news photo"/></a>
                            </c:if>
                            <fmt:setLocale value="en_US"/>  
                            <fmt:parseDate var="newsSunrise" value="${item.sunrise.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                            <fmt:formatDate var="newsDate" value="${newsSunrise}" pattern="EEEE', 'MMM'. 'd" />
                            <h3><a title="full ${item.moniker.string}" href="${item.sourceLink.string}">${item.newsLabel.string}</a></h3>
                            <p>${item.blurb.string}</p>
                       </li>
                   </c:forEach>
               </ul>

           </sparql:sparql>
      
	</div> <!-- content -->
</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />