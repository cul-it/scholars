<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<%-- Given a field, department, or field+researcharea URI, get a multi-column faculty list with thumbnails --%>

<c:set var="imageDir" value="/../images/" />

<c:if test="${param.type == 'field'}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
    
        <c:choose>
            <c:when test="${param.filter == 'singleArea'}">
                <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>" areaUri="<${param.areaUri}>">
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                  SELECT DISTINCT ?personUri ?personLabel ?image ?moniker
                  WHERE {
                      ?fieldUri vivo:hasFieldMember ?personUri .
                      ?personUri vivo:PersonHasResearchArea ?areaUri .
                      ?personUri rdfs:label ?personLabel .
                      ?personUri rdf:type vivo:FacultyMember .
                          OPTIONAL { ?personUri vitro:imageThumb ?image }
                          OPTIONAL { ?personUri vitro:moniker ?moniker }
                  FILTER (!regex(?moniker, "emeritus", "i"))
                  } ORDER BY ?personLabel
                  LIMIT 1000
                </listsparql:select>
            </c:when>
            <c:otherwise>
                <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>">
                  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                  PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                  SELECT DISTINCT ?personUri ?personLabel ?image ?moniker
                  WHERE {
                      ?fieldUri vivo:hasFieldMember ?personUri .
                      ?personUri rdfs:label ?personLabel .
                      ?personUri rdf:type vivo:FacultyMember .
                          OPTIONAL { ?personUri vitro:imageThumb ?image }
                          OPTIONAL { ?personUri vitro:moniker ?moniker }
                  FILTER (!regex(?moniker, "emeritus", "i"))
                  } ORDER BY ?personLabel
                  LIMIT 1000
                </listsparql:select>
            </c:otherwise>
        </c:choose>

        <c:set var="facultyTotal" value='${fn:length(rs)}' />

        <%--This calculates ideal column lengths based on total items--%>
        <c:choose>
            <c:when test="${(facultyTotal mod 2) == 0}"><%--For lists that will have even column lengths--%>
                <c:set var="colSize" value="${(facultyTotal div 2)}" />
                <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
            </c:when>
            <c:otherwise><%--For uneven columns--%>
                <c:set var="colSize" value="${(facultyTotal div 2) + 1}" />
                <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
            </c:otherwise>
        </c:choose>
        
        <c:if test="${param.visibility == 'show'}"><c:remove var="hiddenClass"/></c:if>
        <c:if test="${param.visibility == 'hide'}"><c:set var="hiddenClass" value="hide"/></c:if>
        
        <ul class="facultyList span-7 ${hiddenClass}">
            <c:forEach items='${rs}' var="Faculty" begin="0" end="${colSize-1}">
                <c:set var="facultyID" value="${fn:substringAfter(Faculty.personUri,'#')}"/>
                <c:set var="facultyHref">
	                <c:import url="part/build_person_href.jsp"><c:param name="uri" value="${Faculty.personUri}"/></c:import>
	            </c:set>
                <li id="${facultyID}">
                    <c:choose>
                        <c:when test="${!empty Faculty.image.string}">
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="${imageDir}${Faculty.image.string}"/></a>
                        </c:when>
                        <c:otherwise>
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="/resources/images/profile_missing.gif"/></a>
                        </c:otherwise>
                    </c:choose>
                    <strong><a href="${facultyHref}" title="view profile">${Faculty.personLabel.string}</a></strong>
                    <em>${Faculty.moniker.string}</em>
                </li>
            </c:forEach>
        </ul>
    
        <ul class="facultyList span-7 ${hiddenClass}">
            <c:forEach items='${rs}' var="Faculty" begin="${colSize}">
                <c:set var="facultyID" value="${fn:substringAfter(Faculty.personUri,'#')}"/>
                <c:set var="facultyHref">
	                <c:import url="part/build_person_href.jsp"><c:param name="uri" value="${Faculty.personUri}"/></c:import>
	            </c:set>
                <li id="${facultyID}">
                    <c:choose>
                        <c:when test="${!empty Faculty.image.string}">
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="${imageDir}${Faculty.image.string}"/></a>
                        </c:when>
                        <c:otherwise>
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="/resources/images/profile_missing.gif"/></a>
                        </c:otherwise>
                    </c:choose>
                    <strong><a href="${facultyHref}" title="view profile">${Faculty.personLabel.string}</a></strong>
                    <em>${Faculty.moniker.string}</em>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>
    </sparql:lock>
</c:if>

<%-----------------------------------------------------------------------------%>

<c:if test="${param.type == 'department'}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" dept="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          SELECT DISTINCT ?personUri ?personLabel ?image ?grouping ?personLinkAnchor ?personLinkURL ?otherAnchor ?otherURL
          WHERE {
              ?dept vivo:hasEmployeeAcademicFacultyMember ?personUri .
              ?personUri rdfs:label ?personLabel .

                  OPTIONAL { ?personUri vivo:memberOfGraduateField ?fieldUri . ?fieldUri rdf:type vivo:GraduateField . ?fieldUri vivo:associatedWith ?grouping . ?grouping rdf:type vivo:fieldCluster }
                  OPTIONAL { ?personUri vitro:imageThumb ?image }
                  OPTIONAL { ?personUri vitro:moniker ?moniker }
                  OPTIONAL { ?personUri vitro:primaryLink ?primaryLink. ?primaryLink vitro:linkAnchor ?personLinkAnchor . ?primaryLink vitro:linkURL ?personLinkURL }
                  OPTIONAL { ?personUri vitro:additionalLink ?additionalLink. ?additionalLink vitro:linkAnchor ?otherAnchor . ?additionalLink vitro:linkURL ?otherURL }
          FILTER (!regex(?moniker, "emeritus", "i"))
          } ORDER BY ?personLabel
          LIMIT 2000
        </listsparql:select>

            <c:forEach items="${rs}" var="row">
                <c:if test="${thisPerson != row.personUri}">
                    <c:set var="thisPerson" value="${row.personUri}"/>
                    <c:set var="counter" value="${counter+1}"/>
                </c:if>
            </c:forEach>
            <c:set var="facultyTotal" value="${counter}" />
            
            <%--This calculates ideal column lengths based on total items--%>
            <c:choose>
                <c:when test="${(facultyTotal mod 2) == 0}"><%--For lists that will have even column lengths--%>
                    <c:set var="colSize" value="${(facultyTotal div 2)}" />
                    <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
                </c:when>
                <c:otherwise><%--For uneven columns--%>
                    <c:set var="colSize" value="${(facultyTotal div 2) + 1}" />
                    <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
                </c:otherwise>
            </c:choose>
            
            <c:set var="counter" value="0"/>
            
            <ul class="facultyList span-7">
                <c:forEach items="${rs}" var="row">
                    <c:if test="${thisPerson != row.personUri}">
                        <c:set var="thisPerson" value="${row.personUri}"/>
                        <c:set var="counter" value="${counter+1}"/>
                        <li>
                            <c:choose>
                                <c:when test="${empty row.grouping && !empty row.personLinkURL}">
                                    <c:set var="personHref"><str:decodeUrl>${row.personLinkURL.string}</str:decodeUrl></c:set>
                                    <c:set var="linkTitle">${row.personLinkAnchor.string}</c:set>
                                    <c:set var="externalLinkClass" value='class="external"'/>
                                </c:when>
                                <c:when test="${empty row.grouping && !empty row.otherURL}">
                                    <c:set var="personHref"><str:decodeUrl>${row.otherURL.string}</str:decodeUrl></c:set>
                                    <c:set var="linkTitle">${row.otherAnchor.string}</c:set>
                                    <c:set var="externalLinkClass" value='class="external"'/>
                                </c:when>
                                <c:otherwise>
                                    <c:set var="facultyID" value="${fn:substringAfter(row.personUri,'#')}"/>
                                    <c:set var="personHref">
						                <c:import url="part/build_person_href.jsp"><c:param name="uri" value="${row.personUri}"/></c:import>
						            </c:set>
                                    <c:set var="linkTitle">view profile</c:set>
                                    <c:set var="externalLinkClass" value=""/>
                                </c:otherwise>
                            </c:choose>
                            
                            <c:choose>
                                <c:when test="${!empty row.image.string}"><a href="${personHref}" title="${linkTitle}"><img width="25" alt="" src="${imageDir}${row.image.string}"/></a></c:when>
                                <c:otherwise><a href="${personHref}" title="${linkTitle}"><img width="30" alt="" src="/resources/images/profile_missing.gif"/></a></c:otherwise>
                            </c:choose>
                            
                            <a ${externalLinkClass} href="${personHref}" title="${linkTitle}">${row.personLabel.string}</a>
                            <%-- <c:if test="${row.personUri == param.deptHead}"> <em>&mdash; Dept Head</em></c:if> --%>
                            
                        </li>
                        <c:if test="${counter == colSize}">
                            </ul><ul class="facultyList span-7">
                        </c:if>
                    </c:if>
                </c:forEach>
            </ul>
            
    </sparql:sparql>
    </sparql:lock>
</c:if>

<c:if test="${param.type == 'researchare'}">
    <sparql:lock model="${applicationScope.jenaOntModel}">
    <sparql:sparql>
    
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>" areaUri="<${param.areaUri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          SELECT DISTINCT ?personUri ?personLabel ?image ?moniker
          WHERE {
              ?fieldUri vivo:hasFieldMember ?personUri .
              ?personUri vivo:PersonHasResearchArea ?areaUri .
              ?personUri rdfs:label ?personLabel .
                  OPTIONAL { ?personUri vitro:imageThumb ?image }
                  OPTIONAL { ?personUri vitro:moniker ?moniker }
          FILTER (!regex(?moniker, "emeritus", "i"))
          } ORDER BY ?personLabel
          LIMIT 1000
        </listsparql:select>


        <ul class="facultyList span-14 ${hiddenClass}">
            <c:forEach items='${rs}' var="Faculty">
                <c:set var="facultyID" value="${fn:substringAfter(Faculty.personUri,'#')}"/>
                <c:set var="facultyHref">
	                <c:import url="part/build_person_href.jsp"><c:param name="uri" value="${Faculty.personUri}"/></c:import>
	            </c:set>
                <li id="${facultyID}">
                    <c:choose>
                        <c:when test="${!empty Faculty.image.string}">
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="${imageDir}${Faculty.image.string}"/></a>
                        </c:when>
                        <c:otherwise>
                            <a href="${facultyHref}" title="view profile"><img width="44" alt="" src="/resources/images/profile_missing.gif"/></a>
                        </c:otherwise>
                    </c:choose>
                    <strong><a href="${facultyHref}" title="view profile">${Faculty.personLabel.string}</a></strong>
                    <em>${Faculty.moniker.string}</em>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>
    </sparql:lock>
</c:if>