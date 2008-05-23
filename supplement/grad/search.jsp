<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="searchParam" value=" Results: ${param.querytext}"/>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="searchpage"/>
    <jsp:param name="titleText" value="Search${searchParam} | Cornell University"/>
</jsp:include>

        <style type="text/css">
            span.highlight { background: #5a5651; padding: 0 1px; }
        </style>
        
        <div id="contentWrap">
            <div id="content">

                <form action="search.jsp" method="get" name  e="gs"> 

                    <div id="search-input" style="padding: 20px 10px; border: 1px solid #ccc; margin-bottom: 20px"> 
                        <label for="search-form-query">SEARCH:</label>
                        <input type="text" id="search-form-query" name="querytext" value="${param.querytext}" size="30" />
                        <input type="submit" id="search-form-submit" name="submit" value="go" />
                    </div>
                    
                </form>

                <c:import var="rss" url="http://localhost:8080/nutch/opensearch">
                    <c:param name="query" value="${param.querytext}"/>
                    <c:param name="hitsPerSite" value="0"/>
                    <c:param name="lang" value="en"/>
                    <c:param name="hitsPerPage" value="10"/>
                </c:import>
                
                <x:parse var="results" doc="${rss}"/>
            
                <x:choose>
                    <x:when select="$results//item">
                        <x:forEach select="$results//item">
                            <x:set var="resultTitle" select="substring-before(title, ' |')"/>
                            <h4>
                                <a href="<x:out select='link'/>">
                                <c:out value="${resultTitle}"/>
                                </a>
                            </h4>
                            <p><x:out escapeXml="false" select="description"/></p>
                        </x:forEach>
                    </x:when>
                    <x:otherwise>
                        <p>No Results</p>
                    </x:otherwise>
                </x:choose>
            
            
            
            
            </div><!-- content -->
        
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />