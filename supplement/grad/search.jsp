<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle">
    <c:if test="${!empty param.querytext}">Search Results: ${param.querytext}</c:if>
    <c:if test="${empty param.querytext}">Search</c:if>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="search"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">
                
                <form action="/search/" method="get" name="search-form" id="search-form"> 
                    <h2><label for="search-form-query">Search</label></h2>
                    <input type="text" id="search-form-query" name="querytext" value="${param.querytext}" size="30" />
                    <button type="submit" id="search-form-submit" name="submit" value="go" />go</button>
                </form>

                <c:choose>
                    <c:when test="${!empty param.start}">
                        <c:set var="start" value="${param.start}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="start" value="0"/>
                    </c:otherwise>
                </c:choose>
                
                <c:if test="${!empty param.querytext && param.querytext != ''}">
                
                    <c:import var="gs" url="http://web.search.cornell.edu/search" charEncoding="UTF-8">
                        <c:param name="q" value="${param.querytext}"/>
                        <c:param name="output" value="xml_no_dtd" />
                        <c:param name="sort" value="date:D:L:d1" />
                        <c:param name="ie" value="UTF-8" />
                        <c:param name="client" value="default_frontend" />
                        <c:param name="oe" value="UTF-8" />
                        <c:param name="start" value="${start}" />
                        <c:param name="num" value="10" />
                        <c:param name="filter" value="0" />
                        <c:param name="site" value="default_collection" />
                        <c:param name="sitesearch" value="http://gradeducation.lifesciences.cornell.edu" />
                    </c:import>
                
                    <x:parse var="google" doc="${gs}"/>
                
                    <c:set var="gtotal">
                        <x:out select="$google//M"/>
                    </c:set>
                
                    <c:set var="first">
                        <x:out select="$google//R[1]/@N"/>
                    </c:set>
                
                    <c:set var="last">
                        <x:out select="$google//R[last()]/@N"/>
                    </c:set>
                
                    <div id="searchResults">
                        <x:choose>
                            <x:when select="$google//RES">
                                <c:if test="${gtotal == 1}">
                                    <p class="resultCount">${gtotal} result for <strong><x:out select="$google//Q" /></strong></p>
                                </c:if>
                                <c:if test="${gtotal > 1}">
                                    <c:choose>
                                        <c:when test="${gtotal < 11}">
                                            <p class="resultCount">1 - ${gtotal} of ${gtotal} results for <strong><x:out select="$google//Q" /></strong></p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="resultCount">${first} - ${last} of about ${gtotal} results for <strong><x:out select="$google//Q" /></strong></p>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                <x:if select="$google//Spelling">
                                    <p class="suggestion">Did you mean: 
                                        <x:forEach select="$google//Spelling/Suggestion">
                                            <strong><x:out select="$google//Spelling/Suggestion/@q" /></strong>
                                        </x:forEach>
                                    </p>
                                </x:if>
                                <x:forEach var="result" select="$google//R">
                                    <c:set var="resultTitle">
                                        <x:out escapeXml="false" select="T"/>
                                    </c:set>
                                    <c:set var="resultHref">
                                        <x:out select='U' />
                                    </c:set>
                                    <h3>
                                        <a title="visit this page" href="${resultHref}">
                                            <c:choose>
                                                <c:when test="${fn:contains(resultTitle, '|')}">
                                                    <x:out escapeXml="false" select="substring-before(T, ' |')"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <x:out escapeXml="false" select="T"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </a>
                                    </h3>
                                    <p><x:out escapeXml="false" select="S"/></p>
                                </x:forEach>
                            </x:when><%-- end search results output --%>
                    
                            <x:otherwise>
                                <c:choose>
                                    <c:when test="${!empty param.querytext}">
                                        <p>Your search - <strong>${param.querytext}</strong> - did not return any results.</p>   
                                    </c:when>
                                    <c:otherwise>&nbsp;</c:otherwise>
                                </c:choose>
                                <x:if select="$google//Spelling">
                                    <p class="suggestion">Did you mean: 
                                        <x:forEach select="$google//Spelling/Suggestion">
                                            <c:set var="altQuery"><x:out select="@q" /></c:set>
                                            <c:url var="pageHref" value="/search/">
                                                <c:param name="querytext" value="${altQuery}"/>
                                            </c:url>
                                            <strong><a href="${pageHref}"><x:out select="@q" /></a>&nbsp;</strong>
                                        </x:forEach>
                                    </p>
                                </x:if>
                            </x:otherwise>
                        </x:choose>
                    </div>
                
                
                    <%-------- PAGING CONTROLS ---------%>
                    <div id="pagination">
                        <x:choose>
                            <x:when select="$google//PU">
                                <c:url var="pageHref" value="/search/">
                                    <c:param name="querytext" value="${param.querytext}"/>
                                    <c:param name="start" value="${param.start - 10}"/>
                                </c:url>
                                <a href="${pageHref}">&lt; Prev</a>
                            </x:when>
                            <x:otherwise>
                            </x:otherwise>
                        </x:choose>
                    
                        <x:choose>
                            <x:when select="$google//NU">
                                <c:url var="pageHref" value="/search/">
                                    <c:param name="querytext" value="${param.querytext}"/>
                                    <c:param name="start" value="${param.start + 10}"/>
                                </c:url>
                                <a href="${pageHref}"> Next &gt;</a>
                            </x:when>
                            <x:otherwise>
                            </x:otherwise>
                        </x:choose>
                    </div><!-- pagination -->
                
                </c:if><%-- if querytext is not empty --%>
                
                <%--<div id="vivoResults">
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