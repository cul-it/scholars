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
                <%-- <jsp:include page="part/alldepartments.jsp" /> --%>
            </c:otherwise>
        </c:choose>
        
<%-- 
        <h2 class="groupLabel ${param.groupClass}"><a href="${grouphref}">${param.groupLabel}</a></h2>
 
        <h3>Graduate Field: <span class="fieldLabel">${param.fieldLabel}</span></h3>

        <c:import var="fieldDescription" url="part/getdescription.jsp">
                 <c:param  name="uri" value="${param.uri}"/>
         </c:import>
        
        <div id="departmentsInField">
            <h4>Departments</h4>
            <ul>
                <jsp:include page="part/listdepartments.jsp">
                    <jsp:param name="uri" value="${param.uri}"/>
                </jsp:include>
            </ul>
        </div>
        <p>${fieldDescription}</p>

        <div id="facultyInField">
            <h4>Faculty</h4>
            <ul>
            <jsp:include page="part/listfaculty.jsp">
                <jsp:param name="uri" value="${param.uri}"/>
            </jsp:include>
            </ul>
        </div>


        <div id="researchInField">
            <h4>Research Areas</h4>
            <ul>
                <jsp:include page="part/listresearch.jsp">
                    <jsp:param name="uri" value="${param.uri}"/>
                </jsp:include>
            </ul>
        </div>
--%>

	</div> <!-- content -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />