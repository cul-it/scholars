<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/random-1.0" prefix="rand" %>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="faculty" personUri="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          PREFIX vitropublic: <http://vitro.mannlib.cornell.edu/ns/vitro/public#>
          PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?personLabel ?prefName ?moniker ?overviewStatement ?researchFocus ?background ?publications ?image ?cornellEmail ?otherEmail ?netid ?primaryLinkAnchor ?primaryLinkURL ?otherLinkAnchor ?otherLinkURL
          WHERE {
            SERVICE <http://sisler.mannlib.cornell.edu:8081/openrdf-sesame/repositories/courses2> {
              ?personUri rdfs:label ?personLabel .
              OPTIONAL { ?personUri core:overview ?overviewStatement }
              OPTIONAL { ?personUri core:hasResearcherRole ?researchActivity .
                             ?researchActivity core:description ?researchFocus .}
              OPTIONAL { ?personUri vivo:educationalBackground ?background }
              OPTIONAL { ?personUri vivo:publications ?publications }
              OPTIONAL {
                   ?personUri vitropublic:mainImage ?mainImage .
                   ?mainImage vitropublic:thumbnailImage ?thumbnail .
                   ?thumbnail vitropublic:downloadLocation ?downloadLocation .
              }
              OPTIONAL { ?personUri vitro:moniker ?moniker }
              OPTIONAL { ?personUri vitro:primaryLink ?primaryLink. ?primaryLink vitro:linkAnchor ?primaryLinkAnchor . ?primaryLink vitro:linkURL ?primaryLinkURL }
              OPTIONAL { ?personUri vitro:additionalLink ?otherLink . ?otherLink vitro:linkAnchor ?otherLinkAnchor . ?otherLink vitro:linkURL ?otherLinkURL }
              OPTIONAL { ?personUri vivo:CornellemailnetId ?cornellEmail }
              OPTIONAL { ?personUri vivo:nonCornellemail ?otherEmail }
              OPTIONAL { ?personUri hr:PrefName ?prefName }
              OPTIONAL { ?personUri hr:netId ?netid }
            }
            LET (?image := str(?downloadLocation))
          }
          LIMIT 50
    </listsparql:select>
    
    <listsparql:select model="${applicationScope.jenaOntModel}" var="grants" personUri="<${param.uri}>">
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?grantLabel ?grantUri 
          WHERE {
            SERVICE <http://sisler.mannlib.cornell.edu:8081/openrdf-sesame/repositories/courses2> {
              ?personUri core:principalInvestigatorOn ?grantUri .
              ?grantUri rdfs:label ?grantLabel .
            }
          }
          LIMIT 50
    </listsparql:select>
    
    <listsparql:select model="${applicationScope.jenaOntModel}" var="pubs" personUri="<${param.uri}>">
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?pubUri ?pubLabel ?pubLinkAnchor ?pubLinkURL
          WHERE {
            SERVICE <http://sisler.mannlib.cornell.edu:8081/openrdf-sesame/repositories/courses2> {
              ?personUri core:authorInAuthorship ?authorship .
                    ?authorship core:linkedInformationResource ?pubUri .
              ?pubUri rdfs:label ?pubLabel .
              OPTIONAL { ?pubUri vitro:additionalLink ?pubLink . ?pubLink vitro:linkURL ?pubLinkURL . ?pubLink vitro:linkAnchor ?pubLinkAnchor }
            }
          }
          LIMIT 50
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:set var="netid" value="${faculty[0].netid.string}"/>
<c:set var="cornellEmail" value="${faculty[0].cornellEmail.string}"/>
<c:set var="otherEmail" value="${faculty[0].otherEmail.string}"/>
<c:set var="profileImage" value="${faculty[0].image.string}"/>
<c:set var="primaryURL"><str:decodeUrl>${faculty[0].primaryLinkURL.string}</str:decodeUrl></c:set>
<c:set var="primaryAnchor" value="${faculty[0].primaryLinkAnchor.string}"/>
<%-- <c:set var="fullName" value="${faculty[0].prefName.string}"/> --%>
<c:set var="fullName" value="${faculty[0].personLabel.string}"/>
<c:set var="moniker" value="${faculty[0].moniker.string}"/>
<c:set var="overviewStatement" value="${faculty[0].overviewStatement.string}"/>
<c:set var="researchFocus" value="${faculty[0].researchFocus.string}"/>
<c:set var="background" value="${faculty[0].background.string}"/>
<c:set var="selectedPubs" value="${faculty[0].publications.string}"/>


<div id="overview" class="span-15">
    <c:choose>
        <c:when test="${!empty profileImage}">
            <c:url var="imageSrc" value="${profileImage}"/>
            <img class="profile" src="${imageSrc}" alt="profile photo" width="150"/>
        </c:when>
        <c:otherwise>
            <img class="profile" src="/resources/images/profile_missing.gif" title="photo unavailable" alt="photo unavailable" width="150"/>
        </c:otherwise>
    </c:choose>
    
    <c:choose>
        <c:when test="${fn:contains(fullName, ',')}">
            <c:set var="firstName" value="${fn:substringAfter(fullName,',')}"/>
            <c:set var="lastName" value="${fn:substringBefore(fullName,',')}"/>
            <h2 class="label">${firstName}${" "}${lastName}</h2>
        </c:when>
        <c:otherwise>
            <h2 class="label">${fullName}</h2>
        </c:otherwise>
    </c:choose>
    
    <em>${moniker}</em>
    
    
    <p class="clear">
        <%-- <c:if test="${!empty overviewStatement}">
            <div class="description">${overviewStatement}</div>
        </c:if> --%>
        
        <%---------- RESEARCH AREAS ----------%>
        <c:import var="researchAreas" url="part/researchareas_list.jsp">
            <c:param name="uri" value="${param.uri}"/>
            <c:param name="type" value="faculty"/>
        </c:import>
        
        <c:if test="${!empty researchAreas}">
            <div class="span-7">
            <h3>Primary Research Areas</h3> 
            <ul>${researchAreas}</ul>
            </div>
        </c:if>
        
        <%---------- GRADUATE FIELDS ----------%>
        <c:import var="gradFields" url="part/fields_list.jsp">
            <c:param name="uri" value="${param.uri}"/>
            <c:param name="type" value="faculty"/>
        </c:import>
        
        <div class="span-7">
            <h3>Graduate Fields</h3>
            <ul class="fields">${gradFields}</ul>
        </div>
        
        <c:if test="${!empty researchFocus}">
            <div class="bump">
                <h3>Research Focus</h3> ${researchFocus}
            </div>
        </c:if>
        
        <c:if test="${empty researchFocus && !empty overviewStatement}">
            <div class="bump">
                ${overviewStatement}
            </div>
        </c:if>
        
        <c:if test="${!empty background}">
            <div class="bump">
                <h3>Educational Background</h3> ${background}
            </div>
        </c:if>
        
        
</div><!-- overview -->

<div id="sidebar" class="resourceBar span-8 last">
    
    <h3>Other Pages</h3>
    
    <%---------- EXTERNAL LINKS ----------%>
    <ul class="externalLinks">
        <li><%-- first build the lone primary link --%>
            <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                <c:param name="url" value="${primaryURL}"/>
                <c:param name="size" value="t"/>
            </c:url>
            <a title="graduate school web page" href="${primaryURL}">
                <img class="left" src="${webSnaprUrl}" alt="page"/>
                <span class="left span-4">${primaryAnchor}</span>
            </a>
        </li>
        
        <%-- then go through each additional link --%>
        <c:forEach var="row" items="${faculty}">
            
            <%-- testing that this link hasn't already been generated already since the result set could have multiple rows with the same links --%>
            <c:if test="${prevLink != row.otherLinkURL.string}">
            
                <c:set var="otherLinkUrl"><str:decodeUrl>${row.otherLinkURL.string}</str:decodeUrl></c:set>
                <c:set var="otherLinkAnchor">${row.otherLinkAnchor.string}</c:set>
                <li>
                    <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                        <c:param name="url" value="${otherLinkUrl}"/>
                        <c:param name="size" value="t"/>
                    </c:url>
                    <a title="graduate school web page" href="${otherLinkUrl}">
                        <img class="left" src="${webSnaprUrl}" alt="page"/>
                        <span class="left span-4">${otherLinkAnchor}</span>
                    </a>
                </li>
            </c:if>
            <c:set var="prevLink" value="${row.otherLinkURL.string}"/>
        </c:forEach>
    </ul>
    
    <div id="contact" class="resourceBar-item" >
        <c:choose>
            <c:when test="${!empty netid}"><c:set var="emailAddress">${netid}${'@cornell.edu'}</c:set></c:when>
            <c:when test="${!empty cornellEmail}"><c:set var="emailAddress">${cornellEmail}</c:set></c:when>
            <c:when test="${!empty otherEmail}"><c:set var="emailAddress">${otherEmail}</c:set></c:when>
        </c:choose>
        <c:if test="${!empty (netid || cornellEmail || nonCornellEmail)}">
            <p class="separator"><strong class="heading">Email:</strong> <a href="mailto:${emailAddress}">${emailAddress}</a></p>
            <c:if test="${!empty netid}">
                <c:url var="contactHref" value="http://www.cornell.edu/search/">
                    <c:param name="tab" value="people"/>
                    <c:param name="netid" value="${netid}"/>
                </c:url>
                <p id="cornellContact"><a title="cornell people page" href="${contactHref}">Complete contact information</a></p>
            </c:if>
        </c:if>
    </div>
    
    <%---------- DEPARTMENTS ----------%>
    <c:import var="deptList" url="part/departments_list.jsp">
        <c:param name="uri" value="${param.uri}"/>
        <c:param name="type" value="person"/>
    </c:import>
    <c:if test="${!empty deptList}">
    <div id="departments" class="resourceBar-item last-item">
        <h3 class="separator">Departments</h3>
        <ul id="deptList">${deptList}</ul>
    </div>
    </c:if>
    
    <div class="bottom"></div> <%-- this empty div is necessary to cap the bottom of the sidebar --%>

</div> <!-- sidebar -->


<%---------- RESEARCH GRANTS ----------%>
<c:if test="${!empty grants}">
<div id="grants" class="researchBox span-23 clear">
    <h3>Research Grants</h3>
    <ul id="grantsList">
        <c:forEach var="grant" items="${grants}">
            <li>${grant.grantLabel.string}</li>
        </c:forEach>
    </ul>
</div>
</c:if>

<%---------- PUBLICATIONS ----------%>
<c:if test="${!empty selectedPubs}">
    <div id="publications" class="researchBox span-23">
        
        <h3>Selected Publications</h3>
        
        <%-- Here we're parsing the person's name into something more digestable for PubMed's search engine
             firstName and lastName should have already been parsed out above when possible --%>
        <c:choose>
            <c:when test="${!empty firstName && !empty lastName}">
                <c:set var="firstName" value="${fn:trim(firstName)}"/>
                <c:if test="${fn:contains(lastName,' ')}">
                    <c:set var="lastName" value="${fn:substringBefore(lastName,' ')}"/>
                </c:if>
                <c:set var="firstInitial" value="${fn:substring(firstName,0,1)}"/>
                <c:if test="${fn:contains(firstName,' ')}">
                    <c:set var="mindex" value="${fn:indexOf(firstName,' ')+1}"/>
                    <c:set var="middleInitial" value="${fn:substring(firstName,mindex,mindex+1)}"/>
                </c:if>
                <c:set var="authorTerm" value='"${lastName} ${firstInitial}${middleInitial}" [au]'/>
            </c:when>
            <c:otherwise><c:set var="authorTerm" value='"${fullName}" [au]'/></c:otherwise>
        </c:choose>
        <c:url var="pubmedHref" value="http://www.ncbi.nlm.nih.gov/pubmed">
            <c:param name="db" value="pubmed"/>
            <c:param name="cmd" value="Search"/>
            <c:param name="itool" value="pubmed_AbstractPlus"/>
            <c:param name="term" value="${authorTerm}"/>
        </c:url>
        <a id="pubmedLink" href="${pubmedHref}">PubMed Listings</a>
        
        <%---------- LINKED PUBLICATIONS ----------%>
        <%-- <ul id="linkedPubs">
            <c:forEach var="pub" items="${pubs}">
                <c:if test="${thisPub != pub.pubUri}">
                    <c:set var="thisPub" value="${pub.pubUri}"/>
                    <c:choose>
                        <c:when test="${!empty pub.pubLinkURL}">
                            <c:set var="pubHref"><str:decodeUrl>${pub.pubLinkURL.string}</str:decodeUrl></c:set>
                        </c:when>
                        <c:otherwise>
                            <c:url var="pubHref" value="http://vivo.cornell.edu/entity">
                                <c:param name="uri" value="${pub.pubUri}"/>
                            </c:url>
                        </c:otherwise>
                    </c:choose>
                <li><a title="more about this publication" href="${pubHref}">${pub.pubLabel.string}</a></li>
            </c:if>
            </c:forEach>
        </ul> --%>
        
        <%---------- SELECTED PUBLICATIONS ----------%>
        <c:if test="${!empty selectedPubs}">
            <div id="selectedPubs">${selectedPubs}</div>
        </c:if>
    </div>
</c:if>
</div> <!-- content -->
