<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
     Display a single Department Entity for the grad portal.

     request.attributes:
     an Entity object with the name "entity"
     **********************************************/
    Individual entity = (Individual)request.getAttribute("entity");
    if (entity == null)
        throw new JspException("gradPortalDeptEntity.jsp expects that request attribute 'entity' be set to the Entity object to display.");
%>

<c:set var='financialAwardPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward' scope="page" />
<c:set var='deptHeadPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasLeadParticipantPerson' scope="page"/>
<c:set var='locationPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorLocatedInFacility' scope="page"/>
<c:set var='sponsorsSeriesPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet' scope="page"/>
<c:set var='facultyMembersPropUri' value='http://vivo.library.cornell.edu/ns/0.1#hasAppointedFaculty' scope="page"/>
<c:set var='hasCoursePropUri' value='' scope="page"/>
<fmt:setLocale value="en_US"/>    

<c:set var='imageDir' value='images' scope="page"/>

<div id='deptPageScreenshot'>
    <%-- <c:import var="deptImgSrc" url="http://localhost/thmbnl/getScreenshot.php">
        <c:param name="deptLink" value="${entity.url}" />
    </c:import> --%>
    
    <c:url var="webSnaprUrl" value="http://images.websnapr.com/">
        <c:param name="url" value="${entity.url}"/>
        <c:param name="size" value="s"/>
    </c:url>
    
    <a href="<c:url value='${entity.url}'/>"><img src="${webSnaprUrl}" alt=""/>${entity.anchor}</a>
    
    <%-- <img src='<c:out value="${deptImgSrc}"/>' title="${entity.anchor}" alt="screenshot" /></a> --%>
        
        
</div>

<%-- TEMPORARY FIX UNTIL CONCENTRATIONS ARE PERMANENTLY EXTRACTED --%>
<c:set var="parsedDescription" value="${entity.description}"/>
<c:if test="${fn:contains(entity.description, 'Concentrations')}">
    <c:set var="parsedDescription" value="${fn:substringBefore(entity.description, 'Concentrations')}"/>
</c:if>

<div id="deptDescription">
    <h2>Department of <span class="sectionLabel">${entity.name}</span></h2>
    <div class="description">${parsedDescription}</div>
</div><!-- deptDescription -->

<div class="wrapper">
    
    <div id="deptOverview">
        <%-- Estimating size of Overview column --%>
        <c:set var="counter" value="0"/>
        
        <c:if test='${not empty entity.objectPropertyMap[deptHeadPropUri].objectPropertyStatements}'>
            <h3>Headed by</h3>
            <ul>
                <c:forEach items='${entity.objectPropertyMap[deptHeadPropUri].objectPropertyStatements}' var="headPerson" varStatus="itemCount">
                    <c:if test="${itemCount.last == true}"><c:set var="counter">${counter + itemCount.index + 3}</c:set></c:if>
                    <c:url var="href" value="/entity">
                        <c:param name="uri" value="${headPerson.object.URI}"/>
                    </c:url>
                    <li><a href="${href}" title="view profile in VIVO">${headPerson.object.name}</a></li>
                </c:forEach>
            </ul>
        </c:if>
    
        <c:if test='${not empty entity.objectPropertyMap[locationPropUri].objectPropertyStatements}'>
            <h3>Located in</h3>
            <ul>
                <c:forEach items='${entity.objectPropertyMap[locationPropUri].objectPropertyStatements}' var="location" varStatus="itemCount">
                    <c:if test="${itemCount.last == true}"><c:set var="counter">${counter + itemCount.index + 3}</c:set></c:if>
                    <c:url var="href" value="/entity">
                        <c:param name="uri" value="${location.object.URI}"/>
                    </c:url>
                    <li><a href="${href}" title="more about this location in VIVO">${location.object.name}</a></li>
                </c:forEach>
            </ul>
        </c:if>

        <c:if test='${not empty entity.objectPropertyMap[sponsorsSeriesPropUri].objectPropertyStatements}'>
            <h3>Sponsors series</h3>
            <ul>
                <c:forEach items='${entity.objectPropertyMap[sponsorsSeriesPropUri].objectPropertyStatements}' var="series" varStatus="itemCount">
                    <c:if test="${itemCount.last == true}"><c:set var="counter">${counter + itemCount.index + 2}</c:set></c:if>
                    <c:url var="href" value="/entity">
                        <c:param name="uri" value="${series.object.URI}"/>
                    </c:url>
                    <li><a href="${href}" title="views events from this series">${series.object.name}</a></li>
                </c:forEach>
            </ul>
        </c:if>

        <h3>Part of graduate fields</h3>
        <!-- <em>Select a Field to highlight participating faculty</em> -->
            <sparql:sparql>
                <sparql:select model="${applicationScope.jenaOntModel}" var="rs" dept="<${param.uri}>">
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  SELECT DISTINCT ?fieldUri ?fieldLabel
                  WHERE
                  {
                  ?person vivo:holdFacultyAppointmentIn ?dept .

                  ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?fieldUri .

                  ?fieldUri rdf:type vivo:GraduateField .
                  
                  ?group vivo:hasAssociated ?fieldUri ;
                  rdf:type vivo:fieldCluster .
                  
                  OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                  }
                  ORDER BY ?fieldLabel
                  LIMIT 2000
                </sparql:select>
                    <ul>
                        <c:forEach  items="${rs.rows}" var="fields" varStatus="itemCount">
                            <c:if test="${itemCount.last == true}">
                                <c:set var="counter">${counter + itemCount.index + 2}</c:set>
                            </c:if>
                            <li><c:url var="href" value="fields.jsp"><c:param name="uri" value="${fields.fieldUri}"/><c:param name="fieldLabel" value="${fields.fieldLabel.string}"/></c:url><a href="${href}" title="more about this field">${fields.fieldLabel.string}</a></li>
                        </c:forEach>
                    </ul>
            </sparql:sparql>
    </div><!-- deptOverview -->     
     
    <div id="deptFaculty">
            <h3>Faculty</h3>     
            
            <c:set var="facultyTotal" value='${fn:length(entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements)}' />
            
            <%--This calculates ideal column lengths based on total items--%>
            <c:choose>
                <c:when test="${(facultyTotal mod 3) == 0}">
                    <c:set var="colSize" value="${(facultyTotal div 3)}" />
                    <fmt:parseNumber var="facultyColumnSize" value="${colSize}" type="number" integerOnly="true" />
                </c:when>
                <c:otherwise>
                    <c:set var="colSize" value="${(facultyTotal div 3) + 1}" />
                    <fmt:parseNumber var="facultyColumnSize" value="${colSize}" type="number" integerOnly="true" />
                </c:otherwise>
            </c:choose>
            
            <%--If the Overview list is longer than a single faculty column, change the column size--%>
            <c:if test="${facultyColumnSize lt counter}"><c:set var="facultyColumnSize" value="${counter}"/></c:if>
            
            <%--Prevent orphaned items--%>
            <c:if test="${(facultyTotal - facultyColumnSize) eq 1}"><c:set var="facultyColumnSize" value="${facultyColumnSize + 1}"/></c:if>
    
            <ul class="colOne">
                    <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" varStatus="facultyCount" begin="0" end="${facultyColumnSize - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
            </ul>
            
            <c:if test="${(facultyTotal-(facultyColumnSize-1)) gt 0}">
                <ul class="colTwo">
                    <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" begin="${facultyColumnSize}" end="${facultyColumnSize * 2 - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
                </ul>
            </c:if>
        
            <c:if test="${(facultyTotal-(facultyColumnSize*2)) gt 0}">
                <ul class="colThree">
                     <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" varStatus="facultyCount" begin="${facultyColumnSize * 2 }">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
                </ul>
            </c:if>
    </div><!-- deptFaculty -->
    
</div><!-- wrapper -->

<c:if test='${not empty entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements}'>
<div id="deptProjects" class="wrapper">           
    
    <h3>Administers Projects</h3>
            <c:set var="projectsTotal" value='${fn:length(entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements)}'/>
            <c:set var="maxProjects" value="10" />
            <c:if test="${maxProjects le (projectsTotal + 5)}"><c:set var="maxProjects" value="${maxProjects + 10}" /></c:if>
                <ul>
                    <c:forEach items='${entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements}' var="project" begin="0" end="${maxProjects - 1}">
                        <c:url var="href" value="/entity">
                            <c:param name="uri" value="${project.object.URI}"/>
                        </c:url>
                        <li><a href="${href}" title="more about this project in VIVO">${project.object.name}</a></li>
                    </c:forEach>
                </ul>
            <c:if test="${projectsTotal gt maxProjects}">
                <span class="toggleLink" title="full list of projects">${projectsTotal-maxProjects} more</span>
                <ul id="moreProjects" class="collapsed" style="display: none;">
                    <c:forEach items='${entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements}' var="project" begin="${maxProjects}">
                        <c:url var="href" value="/entity">
                            <c:param name="uri" value="${project.object.URI}"/>
                        </c:url>
                        <li><a href="${href}" title="more about this project in VIVO">${project.object.name}</a></li>
                    </c:forEach>
                </ul>
            </c:if>
</div><!-- deptProjects -->
</c:if>

    <%--<div>--%>
         <%--Courses--%>
        <%--<ul>--%>
        <%--<c:forEach items='${entity.objectPropertyMap["${hasCoursePropUri}"].objetPropertyStatements}}' var="project">--%>
            <%--<li>${headPerson.name}</li>--%>
        <%--</c:forEach>--%>
        <%--</ul>--%>
    <%--</div>--%>



<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>