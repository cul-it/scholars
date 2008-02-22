<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>

<jsp:include page="header.jsp" />
<div id="contentWrap">
	<div id="content" class="gradfields">

        <!-- Build URL for returning to Group -->
        <c:url var="grouphref" value="fields.jsp">
            <c:param name="uri" value="${param.groupUri}"/>
            <c:param name="groupLabel" value="${param.groupLabel}"/>
            <c:param name="groupClass" value="${param.groupClass}"/>
        </c:url>
        
       

<h2 class="groupLabel ${param.groupClass}"><a href="${grouphref}">${param.groupLabel}</a></h2
 
<h3>Graduate Field: <span class="fieldLabel">${param.fieldLabel}</span></h3>

<c:import var="fieldDescription" url="part/getdescription.jsp">
         <c:param  name="uri" value="${param.uri}"/>
 </c:import>
<p>${fieldDescription}</p>

<div id="departmentsInField" class="floatLeft">
    <h4 class="fieldRelationLabel">Departments</h4>
    <ul>
        <jsp:include page="part/listdepartments.jsp">
            <jsp:param name="uri" value="${param.uri}"/>
        </jsp:include>
    </ul>
</div>

<div id="facultyInField" class="floatRight">
    <h4 class="fieldRelationLabel">Faculty</h4>
    <ul>
    <jsp:include page="part/listfaculty.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include>
    </ul>
</div>

	</div> <!-- content -->
	
	<div id="sidebar">
    <div id="researchInField">
        <h4>Research Areas</h4>
        <ul>
            <jsp:include page="part/listresearch.jsp">
                <jsp:param name="uri" value="${param.uri}"/>
            </jsp:include>
        </ul>
    </div>
    </div>
	
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />