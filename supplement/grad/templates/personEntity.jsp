<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/random-1.0" prefix="rand" %>

<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
     Display a single Person Entity for the grad portal.

     request.attributes:
     an Entity object with the name "entity"
     **********************************************/
    Individual entity = (Individual)request.getAttribute("entity");
    if (entity == null)
        throw new JspException("personEntity.jsp expects that request attribute 'entity' be set to the Entity object to display.");
%>

<fmt:setLocale value="en_US"/>    

<c:set var="researchFocus" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#researchFocus'].dataPropertyStatements[0].data}"/>
<c:set var="overviewStatement" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#overviewStatement'].dataPropertyStatements[0].data}"/>
<c:set var="selectedPubs" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#publications'].dataPropertyStatements[0].data}"/>
<c:set var="researchAreas" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#PersonHasResearchArea'].objectPropertyStatements}"/>
<c:set var="primaryInvestigator" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#PersonPrimaryInvestigatorOfFinancialAward'].objectPropertyStatements}"/>
<c:set var="authorOf" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#authorOf'].objectPropertyStatements}"/>
<c:set var="teaches" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#PersonTeacherOfSemesterCourse'].objectPropertyStatements}"/>

<c:set var="gradFields" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#memberOfGraduateField'].objectPropertyStatements}"/>
<c:set var="departments" value="${entity.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#holdFacultyAppointmentIn'].objectPropertyStatements}"/>
<c:set var="education" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#educationalBackground'].dataPropertyStatements[0].data}"/>
<c:set var="awards" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#awardsAndDistinctions'].dataPropertyStatements[0].data}"/>

<c:set var='imageDir' value='../images' scope="page"/>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
<listsparql:select model="${applicationScope.jenaOntModel}" var="contact" person="<${param.uri}>">
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#>
      SELECT DISTINCT ?netid ?phone ?address ?HRnetID
      WHERE
      {
      ?person vivo:CornellemailnetId ?netid . 
      OPTIONAL { ?person vivo:nonCornellemail ?otherid }
      OPTIONAL { ?person hr:CampusPhone ?phone }
      OPTIONAL { ?person hr:Address1 ?address }
      OPTIONAL { ?person hr:netId ?HRnetID }
      }
      LIMIT 1
</listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:forEach items="${contact}" var="faculty" begin="0" end="0">
    <c:set var="cornellEmail" value="${faculty.netid.string}"/>
    <c:set var="otherEmail" value="${faculty.otherid.string}"/>
</c:forEach>

<div id="overview">
    <c:choose>
        <c:when test="${!empty entity.imageThumb}">
            <c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
            <img src="<c:out value="${imageSrc}"/>" alt="profile photo" width="150"/>
            <c:if test="${!empty entity.citation}">
                <%-- <div class="citation">${entity.citation}</div>--%>
            </c:if>
        </c:when>
        <c:otherwise>
            <img src="/resources/images/profile_missing.gif" title="photo unavailable" alt="photo unavailable" width="150"/>
        </c:otherwise>
    </c:choose>
    <c:set var="firstName" value="${fn:substringAfter(entity.name,',')}"/>
    <c:set var="lastName" value="${fn:substringBefore(entity.name,',')}"/>
    <h2>${firstName}&nbsp;${lastName}</h2>
    <em>${entity.moniker}</em>
    <p class="clear">
        <c:if test="${!empty overviewStatement}">
            <div class="description">${overviewStatement}</div>
        </c:if>
        <c:if test="${!empty researchAreas}">
            <div class="description">
                <strong>Primary Interests:</strong> 
                <c:forEach var="areas" items="${researchAreas}" varStatus="count">
                    <c:if test="${count.last == false}">${areas.object.name}; </c:if>
                    <c:if test="${count.last == true}">${areas.object.name}</c:if>
                </c:forEach>
            </div>
        </c:if>
        <c:if test="${!empty researchFocus}">
            <div class="description"><h4>Research Focus:</h4>${researchFocus}</div>
        </c:if>
</div>

<c:if test="${!empty authorOf}">
<div id="faculty-publications">
    <h3>Publications</h3>
    <c:set var="firstName" value="${fn:trim(firstName)}"/>
    <c:if test="${fn:contains(lastName,' ')}">
        <c:set var="lastName" value="${fn:substringBefore(lastName,' ')}"/>
    </c:if>
    <c:set var="firstInitial" value="${fn:substring(firstName,0,1)}"/>
    <c:if test="${fn:contains(firstName,' ')}">
        
        <c:set var="mindex" value="${fn:indexOf(firstName,' ')+1}"/>
        <c:set var="middleInitial" value="${fn:substring(firstName,mindex,mindex+1)}"/>
    </c:if>
    <c:url var="pubmedHref" value="http://www.ncbi.nlm.nih.gov/sites/entrez">
        <c:param name="db" value="pubmed"/>
        <c:param name="cmd" value="Search"/>
        <c:param name="itool" value="pubmed_AbstractPlus"/>
        <c:param name="term" value="${lastName} ${firstInitial}${middleInitial}"/>
    </c:url>
    
    <c:url var="pubmedHref2" value="http://www.ncbi.nlm.nih.gov/pubmed">
        <c:param name="db" value="pubmed"/>
        <c:param name="cmd" value="Search"/>
        <c:param name="itool" value="pubmed_AbstractPlus"/>
        <c:param name="term" value='"${lastName} ${firstInitial}${middleInitial}" [au]'/>
    </c:url>
    
    <a id="pubmedLink" href="${pubmedHref2}">Full PubMed results</a>
    <ul>
        <c:forEach var="publications" items="${authorOf}">
            <sparql:lock model="${applicationScope.jenaOntModel}" >
            <sparql:sparql>
            <listsparql:select model="${applicationScope.jenaOntModel}" var="publicationLinks" publication="<${publications.object.URI}>">
                  PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                  SELECT DISTINCT ?linkUrl
                  WHERE
                  {
                  ?publication vitro:additionalLink ?links . 
                  OPTIONAL { ?links vitro:linkURL ?linkUrl }
                  }
                  LIMIT 10
            </listsparql:select>
            </sparql:sparql>
            </sparql:lock>

            <c:choose>
                <c:when test="${!empty publicationLinks}">
                    <c:set var="pubHref">
                        <c:forEach var="pub" items="${publicationLinks}" begin="0" end="0"><str:decodeUrl>${pub.linkUrl.string}</str:decodeUrl></c:forEach>
                    </c:set>
                </c:when>
                <c:otherwise>
                    <c:url var="pubHref" value="http://vivo.cornell.edu/entity">
                        <c:param name="uri" value="${publications.object.URI}"/>
                    </c:url>
                </c:otherwise>
            </c:choose>
            
            <li><a title="more about this publication" href="${pubHref}">${publications.object.name}</a></li>

        </c:forEach>
        <c:if test="${!empty selectedPubs}"><div>${selectedPubs}</div></c:if>
    </ul>
</div>
</c:if>

<c:if test="${!empty primaryInvestigator}">
<div id="faculty-research">
    <h3>Research Grants</h3>
    <ul>
        <c:forEach var="research" items="${primaryInvestigator}">
        <c:url var="grantHref" value="http://vivo.cornell.edu/entity">
            <c:param name="uri" value="${research.object.URI}"/>
        </c:url>    
            <li><a title="more about this in VIVO" href="${grantHref}">${research.object.name}</a></li>
        </c:forEach>
    </ul>
</div>
</c:if>

<c:if test="${!empty teaches}">
<div id="faculty-teaching">
    <h3>Teaching</h3>
    <ul>
        <c:forEach var="courses" items="${teaches}">
        <c:url var="courseHref" value="http://vivo.cornell.edu/entity">
            <c:param name="uri" value="${courses.object.URI}"/>
        </c:url>    
            <li><a title="more about this in VIVO" href="${courseHref}">${courses.object.name}</a>
                <p>${courses.object.description}</p>
            </li>
        </c:forEach>
    </ul>
</div>
</c:if>

</div> <!-- content -->

<div id="sidebar">
    
    <div id="contactInfo">
    <h3>Contact Information</h3>        

        <ul id="profileLinks">
            
            <li>
                <strong>Email:</strong>
                <c:choose>
                    <c:when test="${!empty cornellEmail}"><a title="" href="mailto:${cornellEmail}">${cornellEmail}</a></c:when>
                    <c:otherwise><a title="" href="mailto:${otherEmail}">${otherEmail}</a></c:otherwise>
                </c:choose>
            </li>
            
            <c:if test="${!empty contact[0].HRnetID.string}">
                <li>
                    <c:url var="contactUrl" value="http://www.cornell.edu/search/">
                        <c:param name="tab" value="people"/>
                        <c:param name="netid" value="${contact[0].HRnetID.string}"/>
                    </c:url>
                    <a title="Full Cornell.edu Listing" href="${contactUrl}"><strong>Complete contact info at Cornell.edu</strong></a>
                </li>
            </c:if>            
            
            <c:if test="${!empty entity.linksList || !empty entity.primaryLink}">
                <c:if test="${!empty entity.primaryLink}">
                    <c:url var="linkUrl" value="${entity.url}" />
                    <li class="external"><a title="visit this site" href="<c:out value="${linkUrl}"/>">${entity.anchor}</a></li>
                </c:if>
                <c:if test="${!empty entity.linksList}">
                    <c:forEach items="${entity.linksList}" var='link'>
                        <c:url var="linkUrl" value="${link.url}" />
                        <li class="external"><a title="visit this site" href="<c:out value="${linkUrl}"/>">${link.anchor}</a></li>
                    </c:forEach>
                </c:if>
            </c:if>
        </ul>
            
    </div><!-- contactinfo -->
    <sparql:lock model="${applicationScope.jenaOntModel}" >
    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="gradfields" person="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          SELECT DISTINCT ?fieldUri ?fieldLabel
          WHERE
          {
          ?person vivo:memberOfGraduateField ?fieldUri .

          ?fieldUri rdf:type vivo:GraduateField ;
          rdfs:label ?fieldLabel .
          
          ?group vivo:hasAssociated ?fieldUri ;
          rdf:type vivo:fieldCluster .
          }
          ORDER BY ?fieldLabel
          LIMIT 100
        </listsparql:select>

            <c:if test="${fn:length(gradfields) > 0}">
                <h3>Graduate Fields</h3>
                <ul id="facultyFields">
                <c:forEach items="${gradfields}" var="fields">
		            <c:set var="fieldID" value="${fn:substringAfter(fields.fieldUri,'#')}"/>
                        <li>
                            <a href="/fields/${fieldID}" title="more about this field">${fields.fieldLabel.string}</a>
                        </li>
                </c:forEach>
                </ul>
            </c:if>
    </sparql:sparql>
    </sparql:lock>

<%-- <c:if test="${!empty gradFields}">
    <h3>Graduate Fields</h3>
    <ul id="facultyFields">
        <c:forEach var="fields" items="${gradFields}">
        <c:url var="fieldHref" value="fields.jsp">
            <c:param name="uri" value="${fields.object.URI}"/>
            <c:param name="fieldLabel" value="${fields.object.name}"/>
        </c:url>    
            <li>
                <a title="more about this field" href="${fieldHref}">${fields.object.name}</a>
            </li>
        </c:forEach>
    </ul>
</c:if> --%>

<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="deptRS" person="<${param.uri}>">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        SELECT DISTINCT ?deptUri ?deptLabel
        WHERE
        {

        ?person
        vivo:holdFacultyAppointmentIn
        ?deptUri .

        ?deptUri
         rdf:type
         vivo:AcademicDepartment .

        OPTIONAL { ?deptUri rdfs:label ?deptLabel }
        }
        ORDER BY ?deptLabel
        LIMIT 20
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:if test="${!empty deptRS}">
    <h3>Departments</h3>        
    <ul id="facultyDepts">
        <c:forEach var="dept" items="${deptRS}">
            <li>
                <c:set var="deptID" value="${fn:substringAfter(dept.deptUri,'#')}"/>
	            <a title="more about this department" href="/departments/${deptID}">${dept.deptLabel.string}</a>
            </li>
        </c:forEach>
    </ul>
</c:if>

<c:if test="${!empty education}">
    <h3>Education</h3>
    <div id="education">${education}</div>
</c:if>

<c:if test="${!empty awards}">
    <h3>Awards</h3>
    <div id="awards">${awards}</div>
</c:if>

</div> <!-- sidebar -->

<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>