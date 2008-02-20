<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>

<jsp:include page="header.jsp" />
<div id="contentWrap">
	<div id="content">

        <!-- Build URL for returning to Group -->
        <c:url var="grouphref" value="fields.jsp">
            <c:param name="uri" value="${param.groupUri}"/>
            <c:param name="groupLabel" value="${param.groupLabel}"/>
            <c:param name="groupClass" value="${param.groupClass}"/>
        </c:url>
        
        <c:import var="fieldDescription" url="part/getdescription.jsp">
            <c:param  name="uri" value="${param.uri}"/>
        </c:import>

<h2 class="groupLabel ${param.groupClass}"><a href="${grouphref}">${param.groupLabel}</a></h2>

<h3>${param.fieldLabel}</h3>

<p style="color: red;">${fieldDescription}</p>
 
<div id="departmentsInField">
    <h4>DEPARTMENTS</h4>
    <jsp:include page="part/listdepartments.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include></div>

<div id="facultyInField">
    <h4>FACULTY</h4>
    <jsp:include page="part/listfaculty.jsp">
        <jsp:param name="uri" value="${param.uri}"/>
    </jsp:include>
</div>

	</div> <!-- content -->
	
	<div id="sidebar">
    <div id="keywordsInField">
        <h4>RESEARCH AREAS</h4>
        <jsp:include page="part/listresearch.jsp">
            <jsp:param name="uri" value="${param.uri}"/>
        </jsp:include>
    </div>
    </div>
	
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />