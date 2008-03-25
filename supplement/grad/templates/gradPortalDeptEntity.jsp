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

<c:set var='hasFacultyPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasLeadParticipantPerson' scope="page"/>
<c:set var='sponsorsSeriesPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet' scope="page"/>

<c:set var='hasCoursePropUri' value='' scope="page"/>

<c:set var='imageDir' value='images' scope="page"/>

<script>
$(document).ready(function(){

  $("span.toggleLink").click(function () {
    $("ul#moreProjects").slideToggle("medium");
     return false;
  });

});
</script>

            <p>Department of</p>
            <h2>${entity.name}</h2>
            <p>${entity.description}</p>

            <div class='thumbnail'>
                <%--<c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>--%>
                <c:import var="deptImgSrc" url="http://localhost/thmbnl/getScreenshot.php">
                    <c:param name="deptLink" value="http://vivo.cornell.edu" />
                </c:import>
                <img src='<c:out value="${deptImgSrc}"/>' title="${entity.name} Web page" alt="${entity.name} Web page" />
                <br />
                <a href="<c:url value='${entity.url}'/>">${entity.name} web page </a>
            </div>

            <h3>Headed by</h3>
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasLeadParticipantPerson"].objectPropertyStatements}'
                           var="headPerson">
                    <li>${headPerson.object.name}</li>
                </c:forEach>
                </ul>

            <c:if test='${not empty entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorLocatedInFacility"].objectPropertyStatements}'>
            <h3>Located in</h3>
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorLocatedInFacility"].objectPropertyStatements}' var="location">
                    <li>${location.object.name}</li>
                </c:forEach>
                </ul>
            </c:if>

            <c:if test='${not empty entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet"].objectPropertyStatements}'>
            <h3>Sponsors series</h3>
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet"].objectPropertyStatements}' var="series">
                    <li>${series.object.name}</li>
                </c:forEach>
                </ul>
            </c:if>

            <h3>Part of graduate fields</h3>
                <sparql:sparql>
                <sparql:select model="${applicationScope.jenaOntModel}" var="rs" dept="<${param.uri}>">
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  SELECT DISTINCT ?fieldUri ?fieldLabel
                  WHERE
                  {
                  ?person vivo:CornellFacultyMemberInOrganizedEndeavor ?dept .

                  ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?fieldUri .

                  ?fieldUri rdf:type vivo:GraduateField .

                  OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                  }
                  ORDER BY ?fieldLabel
                  LIMIT 2000
                </sparql:select>
                    <ul>
                    <c:forEach  items="${rs.rows}" var="fields">
                        <li><c:url var="href" value="/entity"><c:param name="uri" value="${fields.fieldUri}"/></c:url><a href="${href}">${fields.fieldLabel.string}</a></li>
                    </c:forEach>
                    </ul>
                </sparql:sparql>
                    
                    <%--<c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#kdkdkdkdkddk"].objectPropertyStatements}' var="gfield">--%>
                        <%--<li>${gfield.object.name}</li>--%>
                    <%--</c:forEach>--%>

            <h3>Administers Projects</h3>
            
                <c:set var="projectsTotal" value='${fn:length(entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward"].objectPropertyStatements)}'/>
                <c:set var="maxProjects" value="15" />
                
                <ul>
                    <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward"].objectPropertyStatements}' var="project" begin="0" end="${maxProjects - 1}">
                        <li>${project.object.name}</li>
                    </c:forEach>
                </ul>
                <c:if test="${projectsTotal gt maxProjects}">
                    <span class="toggleLink" title="full list of projects">${projectsTotal-maxProjects} more</a>
                        <ul id="moreProjects" class="collapsed" style="display: none;">
                            <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward"].objectPropertyStatements}' var="project" begin="${maxProjects}">
                                <li>${project.object.name}</li>
                            </c:forEach>
                        </ul>
                </c:if>

            <h3>Faculty</h3>            
                <c:set var="facultyTotal" value='${fn:length(entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasCornellFacultyMember"].objectPropertyStatements)}' />

                <%--This crude method calculates ideal column lengths based on total items--%>
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
                
                <ul class="facultyList">
                    <span class="colOne">
                        <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasCornellFacultyMember"].objectPropertyStatements}' var="Faculty" begin="0" end="${facultyColumnSize - 1}">
                            <li>
                                <c:url var="href" value="/entity">
                                    <c:param name="uri" value="${Faculty.object.name}"/>
                                </c:url>
                                <a href="${href}">${Faculty.object.name}</a>
                            </li>
                        </c:forEach>
                    </span>
                    
                    <span class="colTwo">
                        <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasCornellFacultyMember"].objectPropertyStatements}' var="Faculty" begin="${facultyColumnSize}" end="${facultyColumnSize * 2 - 1}">
                            <li>
                                <c:url var="href" value="/entity">
                                    <c:param name="uri" value="${Faculty.object.name}"/>
                                </c:url>
                                <a href="${href}">${Faculty.object.name}</a>
                            </li>
                        </c:forEach>
                    </span>
                    
                    <span class="colThree">
                         <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasCornellFacultyMember"].objectPropertyStatements}' var="Faculty" begin="${facultyColumnSize * 2 }">
                            <li>
                                <c:url var="href" value="/entity">
                                    <c:param name="uri" value="${Faculty.object.name}"/>
                                </c:url>
                                <a href="${href}">${Faculty.object.name}</a>
                            </li>
                        </c:forEach>
                    </span>
                </ul>
                

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