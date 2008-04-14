<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="faculty"/>
</jsp:include>
        
        <div id="contentWrap">
            
            <div id="content" class="faculty">
                                
                <h2>Meet our Faculty</h2>

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
                                <c:url var="facultyHref" value="/entity"><c:param name="uri" value="${person.person}"/></c:url>
                                <c:set var="cornellEmail" value="${fn:replace(person.netid.string, '@', '(at)')}"/>
                                <c:set var="nonCornellEmail" value="${fn:replace(person.otherid.string, '@', '(at)')}"/>
                                <c:set var="imageThumb" value="${person.thumb.string}"/>
                                
                                <c:set var="firstLetter"><str:left count="1"><str:upperCase>${person.personLabel.string}</str:upperCase></str:left></c:set>
                                        
                                        <%-- When encountering a duplicate, only store the address --%>
                                        <c:if test="${prevFacultyUri == facultyUri}">
                                            <c:set var="secondCornellEmail" value="${prevCornellEmail}"/>
                                        </c:if>
                                        
                                        <%-- Then append it as an additional address --%>
                                        <c:if test="${prevFacultyUri != facultyUri && counter.first != true}">
                                        
                                            <tr>
                                                <td <c:if test="${counter.index == 1}">class="firstRow"</c:if>><a href="${prevFacultyHref}" title="view profile in VIVO">${prevFacultyName}</a>
                                                    <%--Icons inserted inside span via JavaScript --%>
                                                    <c:if test="${not empty prevImageThumb}"><span class="localsnapr" title="${prevImageThumb}"> </span></c:if></td>
                                                <td class="email">${prevCornellEmail}<c:if test="${empty prevCornellEmail}">${prevNonCornellEmail}</c:if>
                                                    <c:if test="${!empty secondCornellEmail}">, ${secondCornellEmail}</c:if>
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
        
            <div id="sidebar" class="faculty">

            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />