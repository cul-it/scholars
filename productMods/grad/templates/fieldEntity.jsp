<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>

<!-- <sparql:lock model="${applicationScope.jenaOntModel}"> -->
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="field" fieldUri="<${param.uri}>">
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      PREFIX core: <http://vivoweb.org/ontology/core#>
      SELECT DISTINCT ?fieldLabel ?description ?primaryLinkAnchor ?primaryLinkURL ?otherLinkAnchor ?otherLinkURL ?gsid ?degree ?degreeLabel ?degreeAbbr
      WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
          ?fieldUri rdfs:label ?fieldLabel .
          OPTIONAL { ?fieldUri core:description ?description }
          OPTIONAL { ?fieldUri vitro:primaryLink ?primaryLink. ?primaryLink vitro:linkAnchor ?primaryLinkAnchor . ?primaryLink vitro:linkURL ?primaryLinkURL }
          OPTIONAL { ?fieldUri vitro:additionalLink ?otherLink. ?otherLink vitro:linkAnchor ?otherLinkAnchor . ?otherLink vitro:linkURL ?otherLinkURL }
          OPTIONAL { ?fieldUri vivo:gradschoolID ?gsid }
          OPTIONAL { ?fieldUri core:offersDegree ?degree . ?degree rdfs:label ?degreeLabel . ?degree core:abbreviation ?degreeAbbr }
      }
      }
      LIMIT 50
    </listsparql:select>
</sparql:sparql>
<!-- </sparql:lock> -->

<c:set var="fieldName" value="${field[0].fieldLabel.string}"/>
<c:set var="description" value="${field[0].description.string}"/>
<c:set var="primaryURL"><str:decodeUrl>${field[0].primaryLinkURL.string}</str:decodeUrl></c:set>
<c:set var="primaryAnchor" value="${field[0].primaryLinkAnchor.string}"/>

<%-- <c:set var="contactEmail" value="test@cornell.edu"/> --%>

<%-- <c:if test="${!empty contactEmail}"><c:set var="linkListClass" value="first"/></c:if> this just allows a class to be added to the external links UL, controlling borders in the sidebar --%> 

<%-- Getting application deadlines from a custom Dapper/Pipes feed --%>
<c:set var="gradschoolID" value="${field[0].gsid.string}"/>
<c:catch var="RSSerror">
    <c:import var="gradschoolRSS" url="http://feeds.feedburner.com/CornellGradFieldDeadlines" charEncoding="UTF-8" />
    <x:parse var="gs" doc="${gradschoolRSS}"/>
    <x:forEach select="$gs//channel/item">
        <c:set var="currentID"><x:out select="guid" /></c:set>
        <%-- NOTE: the field parameter below is added to track outbound clicks --%>
        <c:url var="applyLink" value="http://www.gradschool.cornell.edu/">
            <c:param name="p" value="1"/>
            <c:param name="field" value="${entity.name}"/>
        </c:url>
        <c:if test="${currentID == gradschoolID}">
            <c:set var="deadline"><x:out select="description" /></c:set>
            <c:set var="applyButtonUrl" value="${applyLink}"/>
        </c:if>
    </x:forEach>
</c:catch>

        <div id="overview" class="span-15">
            
            <h2 class="label"><span>Graduate Field of </span>${fieldName}</h2>
            
            <c:if test="${!empty field[0].degree}">
                <p><strong>Degrees offered: </strong>
                <c:forEach items="${field}" var="degree" varStatus="count">
                   ${degree.degreeAbbr.string}<c:if test="${count.last!=true}">, </c:if>
                </c:forEach></p>
            </c:if>
        
            ${description}<%-- could test to see if the description contains p tags --%>
        
            <c:if test="${empty RSSerror && !empty deadline}">
                <p class="apply">
                    <a id="applyButton" class="left" title="Graduate School application page" href="${applyButtonUrl}">Apply Now</a>
                    <span><strong>Deadline:</strong> ${deadline}</span>
                </p>
            </c:if>
        
        </div><!-- overview -->
        
        <%---------- SIDEBAR ----------%>     
        <div id="sidebar" class="resourceBar span-8 last right">
            <h3>Pages you need to visit</h3>
            
            <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                <c:param name="url" value="${linkURL}"/>
                <c:param name="size" value="s"/>
            </c:url>
            
            <%-- EXTERNAL LINKS --%>
            <ul class="externalLinks">
                <li><%-- first build the lone primary link --%>
                    <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                        <c:param name="url" value="${primaryURL}"/>
                        <c:param name="size" value="t"/>
                    </c:url>
                    
                    <%-- if the URL contains 'gradschool' change the anchor text --%>
                    <c:choose>
                        <c:when test="${fn:contains(primaryURL,'gradschool')}"><c:set var="linkText">Tuition &amp; admission  requirements</c:set></c:when>
                        <c:otherwise><c:set var="linkText">${primaryAnchor}</c:set></c:otherwise>
                    </c:choose>
                    
                    <a title="graduate school web page" href="${primaryURL}">
                        <img class="left" src="${webSnaprUrl}" alt="page"/>
                        <span class="left span-4">${linkText}</span>
                    </a>
                </li>
                
                <%-- then go through each additional link --%>
                <c:forEach var="row" items="${field}">
                
                    <%-- testing that this link hasn't already been generated already since the result set could have multiple rows with the same links --%>
                    <c:if test="${prevLink != row.otherLinkURL}">
                    
                        <c:set var="otherLinkUrl"><str:decodeUrl>${row.otherLinkURL.string}</str:decodeUrl></c:set>
                        <c:set var="otherLinkAnchor">${row.otherLinkAnchor.string}</c:set>
                        <li>
                            <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                                <c:param name="url" value="${otherLinkUrl}"/>
                                <c:param name="size" value="t"/>
                            </c:url>
                            
                            <%-- if the anchor contains 'Graduate Field of' it's probably the official page, change the anchor text --%>
                            <c:choose>
                                <c:when test="${fn:contains(otherLinkAnchor,'Graduate Field of')}"><c:set var="linkText">Official ${fieldName} Web page</c:set></c:when>
                                <c:when test="${fn:contains(otherLinkAnchor,'Graduate Program in')}"><c:set var="linkText">Official ${fieldName} Web page</c:set></c:when>
                                <c:otherwise><c:set var="linkText">${otherLinkAnchor}</c:set></c:otherwise>
                            </c:choose>
                            
                            <a title="graduate school web page" href="${otherLinkUrl}">
                                <img class="left" src="${webSnaprUrl}" alt="page"/>
                                <span class="left span-4">${linkText}</span>
                            </a>
                        </li>
                    </c:if>
                    <c:set var="prevLink" value="${row.otherLinkURL}"/>
                </c:forEach>
            </ul>
            <c:if test="${!empty contactEmail}">
                <div id="contact" class="resourceBar-item last-item" >
                    <h3 class="separator">Questions?</h3>
                    <p><a href="mailto:${contactEmail}">${contactEmail}</a></p>
                    <%-- <c:if test="${empty contactEmail}">&nbsp;</c:if> --%>
                </div>
            </c:if>
            <div class="bottom"></div><%-- this div is necessary to cap the bottom of the sidebar --%>
        </div>
    
        <%---------- FACULTY ----------%>    
        <div id="meetTheFaculty" class="section">
            <h3>Meet the Faculty</h3>
            <div class="span-15">
                <div id="statusBox" class="empty"><p></p></div>
                <div id="people" >
                    <c:import var="facultyList" url="part/faculty_list.jsp">
                        <c:param name="uri" value="${param.uri}"/>
                        <c:param name="type" value="field"/>
                    </c:import>
                    ${facultyList}
                </div>
            </div>
        
            <%---------- RESEARCH AREAS ----------%>   
            <div id="areaList" class="span-8 last">
                 <c:import var="researchAreas" url="part/researchareas_list.jsp">
                    <c:param name="uri" value="${param.uri}"/>
                    <c:param name="type" value="field"/>
                </c:import>
                <h3>Research Areas</h3>
                <p><em>Select areas to see participating faculty<br/> Hold shift to select multiple</em></p>
                <noscript><em>NOTE: You need to enable JavaScript in your browser to select multiple</em></noscript>
                <div id="scrollBox">
                    <c:if test="${!empty researchAreas}">
                        <ul class="researchAreaList">${researchAreas}</ul>
                    </c:if>
                </div>
                <div class="bottom"></div>
            </div>
        </div>
        
        <%---------- DEPARTMENT LIST ----------%>     
        
        <c:import var="deptList" url="part/departments_list.jsp">
            <c:param name="uri" value="${param.uri}"/>
            <c:param name="type" value="field"/>
        </c:import>
        <div id="departments" class="span-15 section">
            <c:if test="${!empty deptList}">
                <h3>Departments where faculty are based</h3>
                <ul class="deptList">${deptList}</ul>
            </c:if>
        </div>

</div><!-- content --><%-- div opened in fields.jsp --%>
