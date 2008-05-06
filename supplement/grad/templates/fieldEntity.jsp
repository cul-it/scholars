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
     Display a single Department Entity for the grad portal.

     request.attributes:
     an Entity object with the name "entity"
     **********************************************/
    Individual entity = (Individual)request.getAttribute("entity");
    if (entity == null)
        throw new JspException("gradPortalDeptEntity.jsp expects that request attribute 'entity' be set to the Entity object to display.");
%>

<c:set var='departmentsPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasAffiliatedOrganizedEndeavor' scope="page"/>
<c:set var='facultyMembersPropUri' value='http://vivo.library.cornell.edu/ns/0.1#AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember' scope="page"/>
<c:set var='researchFocusURI' value='http://vivo.library.cornell.edu/ns/0.1#researchFocus'/>
<c:set var='imageDir' value='../images/' scope="page"/>



<div id="fieldDescription">
    <h2>Graduate Field of <span class="sectionLabel">${entity.name}</span></h2>
    <div class="description">${entity.description}</div>
</div><!-- fieldDescription -->
      
<div id="fieldFaculty">
        <h3>Meet our Faculty</h3>
        
        <%--Set the estimated size of the Overview list--%>
        <c:set var="counter">${counter + itemCount.index + 2}</c:set>
        
        <c:set var="facultyTotal" value='${fn:length(entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements)}' />
        
        <%--This calculates ideal column lengths based on total items--%>
        <c:choose>
            <c:when test="${(facultyTotal mod 2) == 0}"><%--For lists that will have even column lengths--%>
                <c:set var="colSize" value="${(facultyTotal div 2)}" />
                <fmt:parseNumber var="facultyColumnSize" value="${colSize}" type="number" integerOnly="true" />
            </c:when>
            <c:otherwise><%--For uneven columns--%>
                <c:set var="colSize" value="${(facultyTotal div 2) + 1}" />
                <fmt:parseNumber var="facultyColumnSize" value="${colSize}" type="number" integerOnly="true" />
            </c:otherwise>
        </c:choose>
                
        <ul>
            <div class="colOne">
                <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" varStatus="facultyCount" begin="0" end="${facultyColumnSize - 1}">
                <c:set var="facultyID" value="${fn:substringAfter(Faculty.object.URI,'#')}"/>
                <li id="${facultyID}">
                    <c:choose>
                        <c:when test="${!empty Faculty.object.imageThumb}">
                            <img align="left" alt="" src="${imageDir}${Faculty.object.imageThumb}"/>
                        </c:when>
                        <c:otherwise>
                            <img alt="" src="images/profile_missing.gif"/>
                        </c:otherwise>
                    </c:choose>
                        <c:url var="href" value="/entity">
                            <c:param name="uri" value="${Faculty.object.URI}"/>
                        </c:url>
                        <strong><a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a></strong>
                        <em>${Faculty.object.moniker}</em>
                </li>
                </c:forEach>
            </div>
        
            <div class="colTwo">
                <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" begin="${facultyColumnSize}">
                <c:set var="facultyID" value="${fn:substringAfter(Faculty.object.URI,'#')}"/>
                <li id="${facultyID}">
                    <c:choose>
                        <c:when test="${!empty Faculty.object.imageThumb}">
                            <img align="left" alt="" src="${imageDir}${Faculty.object.imageThumb}"/>
                        </c:when>
                        <c:otherwise>
                            <img alt="" src="images/profile_missing.gif"/>
                        </c:otherwise>
                    </c:choose>

                        <c:url var="href" value="/entity">
                            <c:param name="uri" value="${Faculty.object.URI}"/>
                        </c:url>
                        <strong><a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a></strong>
                        <em>${Faculty.object.moniker}</em>
                </li>
                </c:forEach>
            </div>    
        </ul>
</div><!-- fieldFaculty -->

</div> <!-- content -->

<div id="sidebar">
    
<c:set var="randomPerson">
    <rand:number id="random1" range="1-100"/>
    <jsp:getProperty name="random1" property="random"/>
</c:set>

<fmt:parseNumber var="chosenFaculty" value="${(facultyTotal * (randomPerson/100) ) - 1}" integerOnly="true"/>

<%-- Test that the random faculty member has a research focus --%>
<c:forEach var="chosen" items="${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}" begin="0" end="${facultyTotal}">
    <c:if test="${empty entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements[chosenFaculty].object.dataPropertyMap[researchFocusURI].dataPropertyStatements[0].data}">
        <c:set var="randomPerson">
            <rand:number id="random1" range="1-100"/>
            <jsp:getProperty name="random1" property="random"/>
        </c:set>
        <fmt:parseNumber var="chosenFaculty" value="${(facultyTotal * (randomPerson/100) ) - 1}" integerOnly="true"/>
    </c:if>
</c:forEach>


    <div id="facultySpotlight">
        <h3>Faculty Spotlight</h3>        
                
                <c:set var="spotlight" value="${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements[chosenFaculty].object}"/>
                
                <c:url var="href" value="/entity"><c:param name="uri" value="${spotlight.URI}"/></c:url>
                <c:url var="thumbSrc" value='${imageDir}${spotlight.imageThumb}'/>
                <c:if test="${empty spotlight.imageThumb}"><c:url var="thumbSrc" value='images/profile_missing.gif'/></c:if>
                <c:set var="firstName" value="${fn:substringAfter(spotlight.name,',')}"/>
                <c:set var="lastName" value="${fn:substringBefore(spotlight.name,',')}"/>
                
                    <img alt="${lastName} photo" src="${thumbSrc}"/>
                    <h4><a href="${href}" title="view profile in VIVO">${fn:trim(firstName)}&nbsp;${lastName}</a></h4>
                    <em>${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements[chosenFaculty].object.moniker}</em>
                    
                    <c:set var="researchFocus" value="${spotlight.dataPropertyMap[researchFocusURI].dataPropertyStatements[0].data}"/>
                    <c:set var="maxBlurbLength" value="500"/>
                    <c:set var="blurbLength"><str:length>${researchFocus}</str:length></c:set>
                    
                    <div class="blurb">
                        <h5>Research Focus:</h5>
                        <c:choose>
                            <c:when test="${blurbLength ge (maxBlurbLength + 400)}">
                                <str:chomp var="chomped" delimiter=" ">
                                    <str:left count="${maxBlurbLength}">${researchFocus}</str:left>
                                </str:chomp>
                                <str:length var="chompLength">${chomped}</str:length>
                                ${chomped}...
                                <a  class="readMore" title="more about this person's research" href="#">read more</a>
                                <%-- <div style="display: none;" class="readMore">
                                    <str:substring start="${chompLength}">${researchFocus}</str:substring>
                                </div> --%>
                            </c:when>
                            <c:otherwise>
                                ${researchFocus}
                            </c:otherwise>
                        </c:choose>
                        
                    </div>

        
    </div> <!-- facultyProfile -->
    
    <div id="fieldDepartments">
    
        <%-- Estimating size of Overview column --%>
        <c:set var="counter" value="0"/>

        <h3>Departments</h3>
        <p>Where faculty members in this field work</p>
            <sparql:sparql>
                <sparql:select model="${applicationScope.jenaOntModel}" var="rs" field="<${param.uri}>">
                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                    SELECT DISTINCT ?deptUri ?deptLabel
                    WHERE
                    {
                    ?person
                    vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
                    ?field .

                    ?person
                    vivo:holdFacultyAppointmentIn
                    ?deptUri .

                    ?deptUri
                     rdf:type
                     vivo:AcademicDepartment .

                    OPTIONAL { ?deptUri rdfs:label ?deptLabel }
                    }
                    ORDER BY ?deptLabel
                    LIMIT 2000
                </sparql:select>
                    <ul>
                        <c:forEach  items="${rs.rows}" var="departments" varStatus="itemCount">
                            <c:if test="${itemCount.last == true}">
                                <c:set var="counter">${counter + itemCount.index}</c:set>
                            </c:if>
                            <li><c:url var="href" value="departments.jsp"><c:param name="uri" value="${departments.deptUri}"/></c:url><a href="${href}" title="">${departments.deptLabel.string}</a></li>
                        </c:forEach>
                    </ul>
            </sparql:sparql>

    </div><!-- fieldDepartments -->


    <div id="researchAreas">
            <sparql:sparql>
                <listsparql:select model="${applicationScope.jenaOntModel}" var="researchResults" field="<${param.uri}>">
                    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                    SELECT DISTINCT ?areaUri ?areaLabel
                    WHERE
                    {
                    ?person
                    vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
                    ?field .

                    ?areaUri
                    vivo:ResearchAreaOfPerson
                    ?person .

                    OPTIONAL { ?areaUri rdfs:label ?areaLabel }
                    }
                    ORDER BY ?areaLabel
                    LIMIT 300
                </listsparql:select>
            </sparql:sparql>

            <c:set var="researchTotal" value="${fn:length(researchResults)}"/>

            <%--This calculates ideal column lengths based on total items--%>
            <c:choose>
                <c:when test="${(researchTotal mod 4) == 0}"><%--For lists that will have even column lengths--%>
                    <c:set var="colSize" value="${(researchTotal div 4)}" />
                    <fmt:parseNumber var="researchColumnSize" value="${colSize}" type="number" integerOnly="true" />
                </c:when>
                <c:otherwise><%--For uneven columns--%>
                    <c:set var="colSize" value="${(researchTotal div 4) + 1}" />
                    <fmt:parseNumber var="researchColumnSize" value="${colSize}" type="number" integerOnly="true" />
                </c:otherwise>
            </c:choose>

            <%--Prevent orphaned items--%>
            <%-- <c:if test="${(researchTotal - researchColumnSize) eq 1 || (researchTotal - researchColumnSize*2) eq 1 || (researchTotal - researchColumnSize*3) eq 1}">
                <c:set var="researchColumnSize" value="${researchColumnSize + 1}"/>
            </c:if> --%>

    <c:if test="${researchTotal gt 0}">
        <h3>Research Areas</h3>
        <p>Select an area to highlight participating faculty</p>
            <ul class="researchAreaList">
                <c:forEach items='${researchResults}' var="Research" varStatus="researchCount">
                    <c:set var="areaID" value="${fn:substringAfter(Research['areaUri'],'#')}"/>
                    <li id="${areaID}">
                        <c:url var="href" value="/entity">
                            <c:param name="uri" value="${Research['areaUri']}"/>
                        </c:url>
                        <a href="${href}" title="view profile in VIVO">${Research['areaLabel'].string}</a>
                    </li>
                </c:forEach>
            </ul>
    </c:if>
    </div> <!-- researchAreas -->

</div> <!-- sidebar -->

<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>