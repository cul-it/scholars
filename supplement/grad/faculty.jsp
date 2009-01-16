<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ include file="part/resources.jsp" %>

<c:choose><%-- This is a temporary patch to account for entities outside of the usual VIVO namespace --%>
    <c:when test="${fn:contains(param.uri,'HRI3')}">
    	<c:set var="URI">${namespace_hri3}${fn:substringAfter(param.uri,'HRI3')}</c:set>
    </c:when>
    <c:when test="${fn:contains(param.uri,'HRI2')}">
    	<c:set var="URI">${namespace_hri2}${fn:substringAfter(param.uri,'HRI2')}</c:set>
    </c:when>
    <c:otherwise>
    	<c:set var="URI">${namespace}${param.uri}</c:set>
    </c:otherwise>
</c:choose> 

<c:set var="encodedURI"><str:encodeUrl>${URI}</str:encodeUrl></c:set>
<c:set var="facultyName">
	<c:import url="part/label.jsp"><c:param name="uri" value="${URI}"/></c:import>
</c:set>

<%-- parse out first and last names --%>
<c:set var="firstName" value="${fn:substringAfter(facultyName,',')}"/>
<c:set var="lastName" value="${fn:substringBefore(facultyName,',')}"/>

<%-- build a page title using the constructed name --%>
<c:set var="pageTitle">
    <c:if test="${!empty param.uri}">${firstName}${' '}${lastName} | Cornell University</c:if>
    <c:if test="${empty param.uri}">Index of Faculty | Cornell University</c:if>
</c:set>

<%-- generate a meta description for the document's head tag --%>
<c:if test="${!empty param.uri}">
    <c:set var="metaDescription">
    	<c:import url="part/metadescriptions.jsp">
    	    <c:param name="uri" value="${URI}"/>
    	    <c:param name="type" value="faculty"/>
    	</c:import>
    </c:set>
</c:if>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="faculty"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
    <jsp:param name="metaDescription" value="${metaDescription}"/>
</jsp:include>

<%-- get a list of all faculty in life sciences fields --%>
<sparql:lock model="${applicationScope.jenaOntModel}">
<sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          PREFIX owl: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#>
          SELECT DISTINCT ?personUri ?personLabel ?netid ?cornellEmail ?nonCornellEmail ?moniker
          WHERE {
            ?group rdf:type vivo:fieldCluster .
            ?group vivo:hasAssociated ?field .

            ?field vivo:hasFieldMember ?personUri .
                                
              OPTIONAL { ?personUri rdfs:label ?personLabel }
              OPTIONAL { ?personUri owl:netId ?netid }
              OPTIONAL { ?personUri vivo:CornellemailnetId ?cornellEmail }
              OPTIONAL { ?personUri vivo:nonCornellemail ?nonCornellEmail }
              OPTIONAL { ?personUri vitro:moniker ?moniker }
              
          FILTER (!regex(?moniker, "emeritus", "i"))
          } ORDER BY ?personLabel
          LIMIT 3000
    </sparql:select>

        <div id="contentWrap">
            
            <%------ INDIVIDUAL FACULTY PAGE ------%>
            <c:choose>
                <c:when test="${not empty param.uri}">
                    <div id="content">
                        <c:import url="templates/personEntity.jsp">
                            <c:param name="uri" value="${URI}" />
                        </c:import>
                    <%-- div closed in the imported template --%>
                </c:when>
                
                <%------ FACULTY INDEX PAGE ------%>
                <c:otherwise>
                    
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
                        
                            <table class="index span-23" cellspacing="0"="3" cellspacing="0"="0" border="1" summary="A list of all faculty members involved with graduate work in Life Sciences at Cornell">
                                <thead>
                                  <tr>
                                      <th class="col-1">Name</th>
                                      <th class="col-2">Email</th>
                                  </tr>
                                </thead>
                                
                                <tbody id="A">
                            
                                    <c:set var="prevFirstLetter" value="A"/>
                                    <c:set var="realCounter" value="0"/>
                            
                                    <c:forEach items="${rs.rows}" var="row" varStatus="counter">
                                        <c:set var="facultyName" value="${row.personLabel.string}"/>
                                        <c:set var="facultyUri" value="${row.personUri}"/>
                                        <%-- <c:set var="facultyHref" value="/faculty/${fn:substringAfter(row.personUri,'#')}"/> --%>
    						            <c:set var="facultyHref">
    						                <c:import url="part/build_person_href.jsp"><c:param name="uri" value="${facultyUri}"/></c:import>
    						            </c:set>
                                        <c:set var="netid" value="${row.netid.string}"/>
                                        <c:set var="cornellEmail" value="${row.cornellEmail.string}"/>
                                        <c:set var="nonCornellEmail" value="${row.nonCornellEmail.string}"/>
                                
                                        <c:set var="firstLetter"><str:left count="1"><str:upperCase>${row.personLabel.string}</str:upperCase></str:left></c:set>
                                        
                                        <%-- Insert tbody wrappers when first letter of last name changes --%>
                                         <c:if test="${prevFirstLetter != firstLetter}">
                                             </tbody>
                                             <tbody id="${firstLetter}">
                                             <c:set var="prevFirstLetter" value="${firstLetter}"/>
                                         </c:if>

                                                <%-- have to check for duplicate result set rows due to people with multiple email addresses --%>
                                                <%-- basically ignoring secondary email addresses here if we have a valid netid --%>
                                                <c:if test="${thisPerson != facultyUri}">
                                                    <c:set var="thisPerson" value="${facultyUri}"/>
                                                    <c:choose>
                                                        <c:when test="${counter.first == true}"><tr class="first"></c:when>
                                                        <c:when test="${counter.last == true}"><tr class="last"></c:when>
                                                        <c:otherwise><tr></c:otherwise>
                                                    </c:choose>
                                                        <td><a class="person" href="${facultyHref}" title="view profile">${facultyName}</a></td>
                                                        <td><c:choose>
                                                                <c:when test="${!empty netid}"><a href="mailto:${netid}">${netid}${'@cornell.edu'}</a></c:when>
                                                                <c:when test="${!empty cornellEmail}"><a href="mailto:${cornellEmail}">${cornellEmail}</a></c:when>
                                                                <c:when test="${!empty nonCornellEmail}"><a href="mailto:${nonCornellEmail}">${nonCornellEmail}</a></c:when>
                                                                <c:otherwise></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                            
                                                    <c:set var="realCounter" value="${realCounter + 1}"/>
                                                </c:if>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="2">Total: ${realCounter}</td>
                                    </tr>
                                </tfoot >
                            </table>

                    </div><!-- content -->
                </c:otherwise>
            </c:choose>
        </div> <!-- contentWrap -->
      
</sparql:sparql>
</sparql:lock>
      
<hr/>
<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>