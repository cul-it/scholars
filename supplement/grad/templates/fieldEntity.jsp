<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

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
            
            <c:set var="counter">${counter + itemCount.index + 2}</c:set>
            <c:set var="facultyTotal" value='${fn:length(entity.objectPropertyMap[facultyMembersPropUri].objectPropertyStatements)}' />
            
            <%--This calculates ideal column lengths based on total items--%>
            <c:choose>
                <c:when test="${(facultyTotal mod 3) == 0}"><%--For lists that will have even column lengths--%>
                    <c:set var="colSize" value="${(facultyTotal div 3)}" />
                    <fmt:parseNumber var="facultyColumnSize" value="${colSize}" type="number" integerOnly="true" />
                </c:when>
                <c:otherwise><%--For uneven columns--%>
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

        <ul class="researchAreaList">
                <span class="colOne">
                    <c:forEach items='${researchResults}' var="Research" varStatus="researchCount" begin="0" end="${researchColumnSize - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Research['areaUri']}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Research['areaLabel'].string}</a>
                        </li>
                    </c:forEach>
                </span>
        
            <c:if test="${(researchTotal-(researchColumnSize-1)) gt 0}">
                <span class="colTwo">
                    <c:forEach items='${researchResults}' var="Research" begin="${researchColumnSize}" end="${researchColumnSize * 2 - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Research['areaUri']}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Research['areaLabel'].string}</a>
                        </li>
                    </c:forEach>
                </span>
            </c:if>
    
            <c:if test="${(researchTotal-(researchColumnSize*2)) gt 0}">
                <span class="colThree">
                     <c:forEach items='${researchResults}' var="Research" begin="${researchColumnSize * 2}" end="${researchColumnSize * 3 - 1}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Research['areaUri']}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Research['areaLabel'].string}</a>
                        </li>
                    </c:forEach>
                </span>
            </c:if>
            
            <c:if test="${(researchTotal-(researchColumnSize*3)) gt 0}">
                <span class="colFour">
                     <c:forEach items='${researchResults}' var="Research" begin="${researchColumnSize * 3}">
                        <li>
                            <c:url var="href" value="/entity">
                                <c:param name="uri" value="${Research['areaUri']}"/>
                            </c:url>
                            <a href="${href}" title="view profile in VIVO">${Research['areaLabel'].string}</a>
                        </li>
                    </c:forEach>
                </span>
            </c:if>
        </ul>

        <%-- <ul>
            <c:forEach  items="${researchResults}" var="area" varStatus="itemCount" begin="0" end="${researchColumnSize - 1}">
                <li><c:url var="href" value="/entity"><c:param name="uri" value="${area['areaUri']}"/></c:url><a href="${href}" title="">${area['areaLabel'].string}</a></li>
            </c:forEach>
        </ul> --%>
        
</div><!-- wrapper2 -->

<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>