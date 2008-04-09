<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fields"/>
</jsp:include>

<div id="contentWrap">
	<div id="content">

        <!-- Build URL for returning to Group -->
        <c:url var="grouphref" value="fields.jsp">
            <c:param name="uri" value="${param.groupUri}"/>
            <c:param name="groupLabel" value="${param.groupLabel}"/>
            <c:param name="groupClass" value="${param.groupClass}"/>
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
      
	</div> <!-- content -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />