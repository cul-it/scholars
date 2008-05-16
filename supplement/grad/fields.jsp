<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- NOTE: Pages with URL parameters containing 'groupLabel' are ignored by the search crawler --%>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fields"/>
    <jsp:param name="titleText" value="Graduate Field of ${param.fieldLabel} - Life Sciences Graduate Programs at Cornell"/>
</jsp:include>

<div id="contentWrap">
    
    <div id="breadcrumbs" class="small">
        <ol>
            <li class="first"><a class="first" href="index.jsp">Home</a></li>
            <li class="second">
                <c:choose>
                    <c:when test="${!empty param.groupLabel}">
                        <c:url var="groupHref" value="groups.jsp">
                            <c:param name="uri" value="${param.groupUri}"/>
                            <c:param name="groupLabel" value="${param.groupLabel}"/>
                            <c:param name="groupClass" value="${param.groupClass}"/>
                        </c:url>
                        <a class="second ${param.groupClass}" href="${groupHref}">${param.groupLabel}</a>
                    </c:when>
                    <c:otherwise>
                        <a class="second" href="gradfieldsIndex.jsp">Graduate Fields</a>
                    </c:otherwise>
                </c:choose>
            </li>
            <li class="third">${param.fieldLabel}</li>
        </ol>
    </div> <!-- breadcrumbs -->
    
	<div id="content">

        <!-- Build URL for returning to Group -->
        <c:url var="grouphref" value="fields.jsp">
            <c:param name="uri" value="${param.groupUri}"/>
            <c:param name="groupLabel" value="${param.groupLabel}"/>
            <c:param   name="groupClass" value="${param.groupClass}"/>
        </c:url>
        
        <c:choose>
            <c:when test="${not empty param.uri}">
                <c:import url="/entity">
                    <c:param name="portal" value="1" />
                    <c:param name="uri" value="${param.uri}" />
                    <c:param name="view" value="grad/templates/fieldEntity.jsp" />
                </c:import>
            </c:when>
        
            <c:otherwise>
                <c:redirect url="gradfieldsIndex.jsp"/>
            </c:otherwise>
        </c:choose>
      
        <!-- content closed in fieldEntity -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />