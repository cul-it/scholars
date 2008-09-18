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
                    <button type="submit" id="search-form-submit" name="submit"/>go</button>
                </form>

                <c:choose>
                    <c:when test="${!empty param.page}">
                        <c:set var="start" value="${(param.page-1)*10}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="start" value="0"/>
                    </c:otherwise>
                </c:choose>

                <c:import var="rss" url="http://nutch.mannlib.cornell.edu/nutch/opensearch">
                <%-- <c:import var="rss" url="http://localhost:8080/nutch/opensearch"> --%>
                    <c:param name="query" value="${param.querytext}"/>
                    <c:param name="lang" value="en"/>
                    <c:param name="start" value="${start}"/>
                    <c:param name="hitsPerPage" value="10"/>
                    <c:param name="hitsPerSite" value="0"/>
                </c:import>

                
                <x:parse var="results" doc="${rss}"/>
                
                <c:set var="total">
                    <x:out select="$results//*[local-name()='totalResults']"/>
                </c:set>
               
                <jsp:useBean id="total" type="java.lang.String" />
                
                <c:set var="totalPages">
                    <c:if test="${(total mod 10) == 0}"><% int t = Integer.parseInt(total) / 10; %><%=t%></c:if>
                    <c:if test="${(total mod 10) != 0}"><% int t = Integer.parseInt(total) / 10 + 1; %><%=t%></c:if>
                </c:set>
                
                <div id="searchResults">
                    <x:choose>
                        <x:when select="$results//item">
                            <c:if test="${total == 1}">
                                <p class="resultCount">${total} result for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                            </c:if>
                            <c:if test="${total > 1}">
                                <c:choose>
                                    <c:when test="${empty param.page && total < 11}">
                                        <p class="resultCount">1 - ${total} of ${total} results for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                                    </c:when>
                                    <c:when test="${empty param.page && total > 10}">
                                        <p class="resultCount">1 - 10 of ${total} results for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="resultStart">${(param.page - 1) * 10 + 1}</c:set>
                                        <p class="resultCount">${resultStart} - ${resultStart + 9} of ${total} results for <strong><x:out select="$results//*[local-name()='query']"/></strong></p>
                                    </c:otherwise>
                                </c:choose>
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
                        </x:when><%-- end search results output --%>
                        
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
                
                
                <%-------- PAGING CONTROLS ---------%>
                <div id="pagination">
                <c:if test="${totalPages > 1}">
                    <c:if test="${!empty param.page && param.page > 1}">
                        <c:url var="pageHref" value="/search/">
                            <c:param name="querytext" value="${param.querytext}"/>
                            <c:param name="page" value="${param.page - 1}"/>
                        </c:url>
                        <a href="${pageHref}">&lt; Prev</a>
                    </c:if>
                </c:if>
                
                <%-- when there are only 11 pages or less --%>
                <c:if test="${totalPages > 1 && totalPages < 12}">
                    <c:set var="pageNum" value="1"/>
                    <c:forEach begin="1" end="${totalPages}">
                        <c:choose>
                            <c:when test="${(empty param.page && pageNum == 1) || param.page == pageNum}">
                                <span>${pageNum}</span>
                            </c:when>
                            <c:otherwise>
                                <c:url var="pageHref" value="/search/">
                                    <c:param name="querytext" value="${param.querytext}"/>
                                    <c:param name="page" value="${pageNum}"/>
                                </c:url>
                                <a href="${pageHref}">${pageNum}</a>
                            </c:otherwise>
                        </c:choose>
                        <c:set var="pageNum" value="${pageNum + 1}"/>
                    </c:forEach>
                </c:if>
                
                <%-- when there are more than 11 pages total --%>
                <c:if test="${totalPages > 11}">

                    <%-- between pages 1 and 6 --%>
                    <c:if test="${empty param.page || param.page < 7}">
                        <c:set var="pageNum" value="1"/>
                    </c:if>
                    
                    <%-- between page 7 and the fifth page from the end  --%>
                    <c:if test="${param.page > 6 && (param.page + 5) lt totalPages }">
                        <c:set var="pageNum" value="${param.page - 5}"/>
                    </c:if>
                    
                    <%-- within 5 pages from the end --%>
                    <c:if test="${(totalPages-param.page) < 5}">
                        <c:set var="pageNum" value="${totalPages - 10}"/>
                    </c:if>
                    
                    <c:forEach begin="0" end="10">
                        <c:choose>
                            <c:when test="${(empty param.page && pageNum == 1) || param.page == pageNum}">
                                <span>${pageNum}</span>
                            </c:when>
                            <c:otherwise>
                                <c:url var="pageHref" value="/search/">
                                    <c:param name="querytext" value="${param.querytext}"/>
                                    <c:param name="page" value="${pageNum}"/>
                                </c:url>
                                <a href="${pageHref}">${pageNum}</a>
                            </c:otherwise>
                        </c:choose>
                        <c:set var="pageNum" value="${pageNum + 1}"/>
                    </c:forEach>
                    
                </c:if>
                
                <c:if test="${totalPages > 1 && param.page != totalPages}">
                    <c:url var="pageHref" value="/search/">
                        <c:param name="querytext" value="${param.querytext}"/>
                        <c:if test="${empty param.page}"><c:param name="page" value="2"/></c:if>
                        <c:if test="${!empty param.page}"><c:param name="page" value="${param.page + 1}"/></c:if>
                    </c:url>
                    <a href="${pageHref}"> Next &gt;</a>
                </c:if>
                
                </div><!-- pagination -->
                
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