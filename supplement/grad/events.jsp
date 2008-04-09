<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="events"/>
</jsp:include>

<div id="contentWrap">
	<div id="content">

        <c:choose>
            <c:when test="${empty param.uri}">
                <c:import url="part/allevents.jsp"/>
            </c:when>
        
            <c:otherwise>
                <%-- <c:redirect url="gradfieldsIndex.jsp"/> --%>
            </c:otherwise>
        </c:choose>
      
	</div> <!-- content -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />