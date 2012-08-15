<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle">
    <c:if test="${!empty param.query}">Search Results: ${param.query}</c:if>
    <c:if test="${empty param.query}">Search</c:if>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="search"/>
    <jsp:param name="titleText" value="${pageTitle}"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">
                
                <form action="/search/" method="get" name="search-form" id="search-form"> 
                    <h2><label for="search-form-query">Search this site</label></h2>
                    <input type="text" id="search-form-query" name="q" value="${param.q}" size="30" />
                    <input type="submit" id="search-form-submit" name="submit" value="go" />
                </form>

                <c:choose>
                    <c:when test="${!empty param.start}">
                        <c:set var="start" value="${param.start}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="start" value="0"/>
                    </c:otherwise>
                </c:choose>
                
                <!-- Results from the google custom search engine get rendered here -->
                <div class="searchResults"><gcse:searchresults-only></gcse:searchresults-only></div>
                
            
            </div><!-- content -->
        </div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp" />