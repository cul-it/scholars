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

<c:set var='departmentsPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasAffiliatedOrganizedEndeavor' scope="page"/>
<c:set var='facultyMembersPropUri' value='http://vivo.library.cornell.edu/ns/0.1#AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember' scope="page"/>

<div id="fieldDescription">
    <h2>Graduate field of <span class="sectionLabel">${entity.name}</span></h2>
    <div class="description">${entity.description}</div>
</div><!-- fieldDescription -->

<div class="wrapper">
    
    <div id="fieldDepartments">
        
        <%-- Estimating size of Overview column --%>
        <c:set var="counter" value="0"/>
        
        <%-- <c:if test='${not empty entity.objectPropertyMap[departmentsPropUri].objectPropertyStatements}'>
            <h3>Departments</h3>
            <ul>
                <c:forEach items='${entity.objectPropertyMap[departmentsPropUri].objectPropertyStatements}' var="departments" varStatus="itemCount">
                    <c:if test="${itemCount.last == true}"><c:set var="counter">${counter + itemCount.index}</c:set></c:if>
                    <c:url var="href" value="/entity">
                        <c:param name="uri" value="${departments.object.URI}"/>
                    </c:url>
                    <li><a href="${href}" title="">${departments.object.name}</a></li>
                </c:forEach>
            </ul>
        </c:if> --%>
    
        <h3>Departments</h3>
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
                    vivo:CornellFacultyMemberInOrganizedEndeavor
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
     
    <div id="fieldFaculty">
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
    
            <ul class="facultyList">
                <span class="colOne">
                    <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" varStatus="facultyCount" begin="0" end="${facultyColumnSize - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
                </span>
            
            <c:if test="${(facultyTotal-(facultyColumnSize-1)) gt 0}">
                <span class="colTwo">
                    <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" begin="${facultyColumnSize}" end="${facultyColumnSize * 2 - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
                </span>
            </c:if>
        
            <c:if test="${(facultyTotal-(facultyColumnSize*2)) gt 0}">
                <span class="colThree">
                     <c:forEach items='${entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements}' var="Faculty" varStatus="facultyCount" begin="${facultyColumnSize * 2 }">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Faculty.object.URI}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Faculty.object.name}</a>
                        </li>
                    </c:forEach>
                </span>
            </c:if>
            </ul>
    </div><!-- fieldFaculty -->
    
</div><!-- wrapper -->

<div class="wrapper">
    <h3>Research Areas</h3>
        <sparql:sparql>
            <sparql:select model="${applicationScope.jenaOntModel}" var="rs" field="<${param.uri}>">
                PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                SELECT DISTINCT ?areaUri ?areaLabel
                WHERE
                {
                ?person
                <http://vivo.library.cornell.edu/ns/0.1#AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative>
                ?field .

                ?areaUri
                <http://vivo.library.cornell.edu/ns/0.1#ResearchAreaOfPerson>
                ?person .

                OPTIONAL { ?areaUri rdfs:label ?areaLabel }
                }
                ORDER BY regex(?areaLabel , "i" ) 
                LIMIT 200
            </sparql:select>
                <ul>
                    <c:forEach  items="${rs.rows}" var="area" varStatus="itemCount">
                        <c:if test="${itemCount.last == true}">
                            <c:set var="counter">${counter + itemCount.index}</c:set>
                        </c:if>
                        <li><c:url var="href" value="/entity"><c:param name="uri" value="${area.areaUri}"/></c:url><a href="${href}" title="">${area.areaLabel.string}</a></li>
                    </c:forEach>
                </ul>
        </sparql:sparql>
        
</div><!-- wrapper2 -->
<%-- <c:if test='${not empty entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements}'>
    <div id="deptResearch" class="wrapper">           
    
        <h3>Administers Projects</h3>
                <c:set var="researchAreasTotal" value='${fn:length(entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements)}'/>
                    <ul>
                        <c:forEach items='${entity.objectPropertyMap[financialAwardPropUri].objectPropertyStatements}' var="project" begin="0" end="">
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${project.object.URI}"/>
                            </c:url>
                            <li><a href="${href}" title="learn more about this project in VIVO">${project.object.name}</a></li>
                        </c:forEach>
                    </ul>
    </div><!-- deptResearch -->
</c:if> --%>

<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>