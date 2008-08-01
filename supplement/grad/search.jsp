<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="searchParam" value=" Results: ${param.querytext}"/>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="search"/>
    <jsp:param name="titleText" value="Search${searchParam}"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">
                
                <form action="search.jsp" method="get" name="gs" id="search-form"> 
                    <h2><label for="search-form-query">Search</label></h2>
                    <input type="text" id="search-form-query" name="querytext" value="${param.querytext}" size="30" />
                    <button type="submit" id="search-form-submit" name="submit"/>go</button>
                </form>

                <c:import var="rss" url="http://nutch.mannlib.cornell.edu/nutch/opensearch?">
                <%-- <c:import var="rss" url="http://localhost:8080/nutch/opensearch"> --%>
                    <c:param name="query" value="${param.querytext}"/>
                    <c:param name="hitsPerSite" value="0"/>
                    <c:param name="lang" value="en"/>
                    <c:param name="hitsPerPage" value="100"/>
                </c:import>
                
                
                <x:parse var="results" doc="${rss}"/>
                
                <c:set var="total">
                    <x:out select="$results//*[local-name()='totalResults']"/>
                </c:set>
                
                <div id="searchResults">
                    <x:choose>
                        <x:when select="$results//item">
                            <c:if test="${total == 1}">
                                <p class="resultCount">${total} result for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                            </c:if>
                            <c:if test="${total > 1}">
                                <p class="resultCount">${total} results for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                            </c:if>
                            <x:forEach select="$results//item">
                                <x:set var="resultTitle" select="substring-before(title, ' |')"/>
                                <h3>
                                    <a href="<x:out select='link'/>">
                                    <c:out value="${resultTitle}"/>
                                    </a>
                                </h3>
                                <p><x:out escapeXml="false" select="description"/></p>
                            </x:forEach>
                        </x:when>
                        <x:otherwise>
                        <c:choose>
                            <c:when test="${!empty param.querytext}">
                                <p>Your search - <strong>${param.querytext}</strong> - did not return any results.</p>   
                            </c:when>
                            <c:otherwise>&nbsp;</c:otherwise>
                        </c:choose>
                        </x:otherwise>
                    </x:choose>
                </div>
            
                <%-- %><div id="vivoResults">
                    <c:url var="vivoQuery" value="search">
                        <c:param name="home" value="1"/>
                        <c:param name="appname" value="VIVO"/>
                        <c:param name="flag1" value="1"/>
                        <c:param name="submit" value="go"/>
                        <c:param name="sitesearch" value="vivo.cornell.edu"/>
                        <c:param name="querytext" value="biology"/>
                    </c:url>
                    <c:out value="${vivoQuery}"/>
                    <c:import var="vivo" url="/${vivoQuery}"/>
                    <c:set var="startIndex" value="${fn:indexOf(vivo, 'contentsBrowseGroup')}"/>
                    <c:set var="endIndex" value="${fn:indexOf(vivo, '--contentsBrowseGroup--')}"/>
                    <c:set var="trimmed" value="${fn:substring(vivo, startIndex+22, endIndex-8)}"/>
                    <c:out escapeXml="false" value="${trimmed}"/>
                </div> --%>
            
            
            </div><!-- content -->
        
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />