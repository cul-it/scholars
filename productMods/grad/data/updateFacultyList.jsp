<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ include file="../part/resources.jsp" %>

<c:catch var="pageError">

<c:if test="${param.showall == 'true' && !empty param.field}">

    <c:import url="../part/faculty_list.jsp">
         <c:param name="type" value="field"/>
         <c:param name="uri" value="${param.field}"/>
     </c:import>

</c:if>

<c:if test="${!empty param.areas && !empty param.field}">


    <c:set var="activeFieldURI">${param.field}</c:set>

    <c:set var="areaParams" value="${param.areas}"/>
    <c:set var="areaParams" value="${param.areas}"/>
    
    <c:set var="areaList" value="${fn:split(areaParams,',')}"/>
    
    <c:choose>
        <c:when test="${!empty areaList[0]}"><c:set var="area1" value="${namespace}${areaList[0]}"/></c:when>
        <c:otherwise><c:set var="area1" value="${namespace}${param.uri}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[1]}"><c:set var="area2" value="${namespace}${areaList[1]}"/></c:when>
        <c:otherwise><c:set var="area2" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[2]}"><c:set var="area3" value="${namespace}${areaList[2]}"/></c:when>
        <c:otherwise><c:set var="area3" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[3]}"><c:set var="area4" value="${namespace}${areaList[3]}"/></c:when>
        <c:otherwise><c:set var="area4" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[4]}"><c:set var="area5" value="${namespace}${areaList[4]}"/></c:when>
        <c:otherwise><c:set var="area5" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[5]}"><c:set var="area6" value="${namespace}${areaList[5]}"/></c:when>
        <c:otherwise><c:set var="area6" value="${area1}"/></c:otherwise>
    </c:choose>

 
   <c:import var="facultyList" url="../part/faculty_list.jsp">
        <c:param name="type" value="multiArea"/>
        <c:param name="field" value="${activeFieldURI}"/>
        <c:param name="visibility" value="show"/>
        <c:param name="area1" value="${area1}"/>
        <c:param name="area2" value="${area2}"/>
        <c:param name="area3" value="${area3}"/>
        <c:param name="area4" value="${area4}"/>
        <c:param name="area5" value="${area5}"/>
        <c:param name="area6" value="${area6}"/>
    </c:import>
    
    <c:choose>
        <c:when test="${fn:contains(facultyList,'<li')}">${facultyList}</c:when>
        <c:otherwise><p class="description">No matches for that combination &mdash; <a class="undo" href="#">undo</a>?</p></c:otherwise>
    </c:choose>
</c:if>     

</c:catch>
<c:if test="${!empty pageError}">${pageError}</c:if>

