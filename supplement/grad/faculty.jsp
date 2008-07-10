<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<c:set var="pageTitle">
    <c:if test="${!empty param.uri}">${param.name} | Cornell University</c:if>
    <c:if test="${empty param.uri}">Index of Faculty | Cornell University</c:if>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="faculty"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
</jsp:include>

        <div id="contentWrap">
            
            <c:choose>
                <c:when test="${not empty param.uri}">
                    <div id="breadcrumbs" class="small">
                        <ol>
                            <li class="first"><a class="first" href="index.jsp">Home</a></li>
                            <c:choose>
                            
                                <%-- arriving from vanilla graduate field--%>
                                <c:when test="${!empty param.groupLabel}">
                                <li class="second">
                                    <c:url var="groupHref" value="groups.jsp">
                                        <c:param name="uri" value="${param.groupUri}"/>
                                        <c:param name="label" value="${param.groupLabel}"/>
                                        <c:param name="class" value="${param.groupClass}"/>
                                    </c:url>
                                    <a class="second ${param.groupClass}" href="${groupHref}">${param.groupLabel}</a>
                                </li>
                                <li class="third">
                                    <c:url var="fieldHref" value="fields.jsp">
                                        <c:param name="uri" value="${param.fieldUri}"/>
                                        <c:param name="fieldLabel" value="${param.fieldLabel}"/>
                                        <c:param name="groupUri" value="${param.groupUri}"/>
                                        <c:param name="groupLabel" value="${param.groupLabel}"/>
                                        <c:param name="groupClass" value="${param.groupClass}"/>
                                    </c:url>
                                    <a class="third" href="${fieldHref}">${param.fieldLabel}</a>
                                </li>
                                <li class="fourth">
                                    ${param.name}
                                </li>
                                </c:when>
                                
                                <%-- arriving from vanilla graduate field--%>
                                <c:when test="${empty param.groupLabel && !empty param.fieldLabel}">
                                <li class="second">
                                    <a class="second" href="gradfieldsIndex.jsp">Graduate Fields</a>
                                </li>
                                <li class="third">
                                    <c:url var="fieldHref" value="fields.jsp">
                                        <c:param name="uri" value="${param.fieldUri}"/>
                                        <c:param name="fieldLabel" value="${param.fieldLabel}"/>
                                    </c:url>
                                    <a class="third" href="${fieldHref}">${param.fieldLabel}</a>
                                </li>
                                <li class="fourth">
                                    ${param.name}
                                </li>
                                </c:when>
                                
                                <%-- arriving from search,faculty index or other --%>
                                <c:otherwise>
                                <li class="second">
                                    <a class="second" href="faculty.jsp">Faculty</a>
                                </li>
                                <li class="third">
                                    ${param.name}
                                </li>
                                </c:otherwise>
                            </c:choose>
                        </ol>
                    </div> <!-- breadcrumbs -->
                    
                
                    <div id="content">
                    
                        <c:import url="/entity">
                            <c:param name="portal" value="1" />
                            <c:param name="uri" value="${param.uri}" />
                            <c:param name="view" value="grad/templates/personEntity.jsp" />
                        </c:import>
                    
                    
                    </c:when>
                    <c:otherwise>
                    <!--noindex-->
                    
                    <div id="content" class="index">
                                
                    <h2>Faculty Index</h2>

                    <div id="indexNav">
                        <a href="#A">A</a>
                        <a href="#B">B</a>
                        <a href="#C">C</a>    
                        <a href="#D">D</a>
                        <a href="#E">E</a>
                        <a href="#F">F</a>
                        <a href="#G">G</a>
                        <a href="#H">H</a>
                        <a href="#I">I</a>
                        <a href="#J">J</a>
                        <a href="#K">K</a>
                        <a href="#L">L</a>    
                        <a href="#M">M</a>
                        <a href="#N">N</a>
                        <a href="#O">O</a>
                        <a href="#P">P</a>
                        <a href="#Q">Q</a>
                        <a href="#R">R</a>
                        <a href="#S">S</a>
                        <a href="#T">T</a>
                        <a href="#U">U</a>    
                        <a href="#V">V</a>
                        <a href="#W">W</a>
                        <a href="#X">X</a>
                        <a href="#Y">Y</a>
                        <a href="#Z">Z</a>
                    </div>
                
                    <sparql:sparql>
                    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">
                          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                          SELECT DISTINCT ?person ?personLabel ?netid ?otherid ?thumb
                          WHERE
                          {
                            ?group
                            rdf:type
                            vivo:fieldCluster .

                            ?group
                            vivo:hasAssociated
                            ?field .

                            ?person
                            vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
                            ?field .
                       
                          OPTIONAL { ?person rdfs:label ?personLabel }
                          OPTIONAL { ?person vivo:CornellemailnetId ?netid }
                          OPTIONAL { ?person vivo:nonCornellemail ?otherid }
                          OPTIONAL { ?person vitro:imageThumb ?thumb }
                          }
                          ORDER BY ?personLabel
                          LIMIT 3000
                    </sparql:select>

                        <%-- Add a noscript to explain email address hiding --%>
                        <table cellspacing="0" summary="A list of all faculty members involved in graduate work in Life Sciences at Cornell.">
                            <thead>
                              <tr>
                                  <th>Name</th>
                                  <th>Email</th>
                              </tr>
                            </thead>
                            <tbody id="A">
                            
                                <c:set var="prevFirstLetter" value="A"/>
                                <c:set var="realCounter" value="0"/>
                            
                                <c:forEach  items="${rs.rows}" var="person" varStatus="counter">
                            
                                    <c:set var="facultyName" value="${person.personLabel.string}"/>
                                    <c:set var="facultyUri" value="${person.person}"/>
                                    <c:url var="facultyHref" value="faculty.jsp"><c:param name="uri" value="${person.person}"/><c:param name="name" value="${person.personLabel.string}"/></c:url>
                                    <c:url var="cluetipHref" value="data/facultyProfile.jsp"><c:param name="uri" value="${person.person}"/></c:url>
                                    <c:set var="cornellEmail" value="${person.netid.string}"/>
                                    <c:set var="nonCornellEmail" value="${person.otherid.string}"/>
                                    <c:set var="imageThumb" value="${person.thumb.string}"/>
                                
                                    <c:set var="firstLetter"><str:left count="1"><str:upperCase>${person.personLabel.string}</str:upperCase></str:left></c:set>
                                        
                                            <%-- When encountering a duplicate, only store the address --%>
                                            <c:if test="${prevFacultyUri == facultyUri}">
                                                <c:set var="secondCornellEmail" value="${prevCornellEmail}"/>
                                            </c:if>
                                        
                                            <%-- Then append it as an additional address --%>
                                            <c:if test="${prevFacultyUri != facultyUri && counter.first != true}">
                                                <tr>
                                                    <td <c:if test="${counter.index == 1}">class="firstRow"</c:if>><a class="person" href="${prevFacultyHref}" title="view profile" <%-- rel="${cluetipHref}" --%>>${prevFacultyName}</a></td>
                                                    <td class="email"><a href="mailto:${prevCornellEmail}">${prevCornellEmail}</a><c:if test="${empty prevCornellEmail}"><a href="mailto:${prevNonCornellEmail}">${prevNonCornellEmail}</a></c:if>
                                                        <c:if test="${!empty secondCornellEmail}">, <a href="mailto:${secondCornellEmail}">${secondCornellEmail}</a></c:if>
                                                    </td>
                                                </tr>
                                            
                                                <%-- Insert tbody wrappers when first letter of last name changes --%>
                                                <c:if test="${prevFirstLetter != firstLetter}">
                                                    </tbody>
                                                    <tbody id="${firstLetter}">
                                                    <c:set var="prevFirstLetter" value="${firstLetter}"/>
                                                </c:if>
                                            
                                                <c:set var="secondCornellEmail" value=""/>
                                                <c:set var="realCounter" value="${realCounter + 1}"/>
                                            </c:if>

                                            <c:set var="prevFacultyName" value="${facultyName}"/>
                                            <c:set var="prevFacultyUri" value="${facultyUri}"/>
                                            <c:set var="prevFacultyHref" value="${facultyHref}"/>
                                            <c:set var="prevCluetipHref" value="${cluetipHref}"/>
                                            <c:set var="prevCornellEmail" value="${cornellEmail}"/>
                                            <c:set var="prevNonCornellEmail" value="${nonCornellEmail}"/>
                                            <c:set var="prevImageThumb" value="${imageThumb}"/>
                                    
                                            <c:if test="${counter.last == true}"><c:set var="totalCount" value="${counter.index + 1}"/></c:if>
                            </c:forEach>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td>Total: ${realCounter}</td>
                                </tr>
                            </tfoot >
                        </table>
                    
                    </sparql:sparql>
                </div><!-- content -->
                <!--/noindex-->
                </c:otherwise>
            </c:choose>
            
            
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />