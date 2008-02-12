<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<c:set var='imageDir' value='images' />
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<div id="dashboard"><p>Hello, Faculty Member</p>
	<c:if test="${!empty entity.imageThumb}">
		<c:if test="${!empty entity.imageFile}">
				<c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
				<a class="image" href="${imageUrl}">
		</c:if>
		<c:url var="imageSrc" value="${imageDir}/${entity.imageThumb}"/>
		<img src="<c:out value="${imageSrc}"/>" alt=""/>
		<c:if test="${!empty entity.imageFile}"></a></c:if>
	</c:if>

    <c:url var="headof" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonLeadParticipantForOrganizedEndeavor"/>
    </c:url>
    <c:url var="dept" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#CornellFacultyMemberInOrganizedEndeavor"/>
    </c:url>
    <c:url var="gradfield" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative"/>
    </c:url>
    <c:url var="membercenter" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonLeadParticipantForOrganizedEndeavor"/>
    </c:url>
    <c:url var="committees" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonLeadParticipantForOrganizedEndeavor"/>
    </c:url>

<ul id="dashboardNavigation">
	<li>
		<h2><a href="#">Cornell Affiliations</a></h2>
		<ul class="dashboardCategories">
			<li class="dashboardProperty"><a href="#">overview statement</a></li>
			<li class="dashboardProperty"><a href="${headof}">head of</a></li>
			<li class="dashboardProperty"><a href="${dept}">academic department(s)</a></li>
			<li class="dashboardProperty"><a href="${gradfield}">graduate field membership(s)</a></li>
			<li class="dashboardProperty"><a href="${membercenter}">affiliations with center/institute</a></li>
			<li class="dashboardProperty"><a href="${committees}">campus committees &amp; services</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Research &amp; Professional Activities</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">research  focus / research activities list</a></li>
		<li class="dashboardProperty"><a href="#">sponsored projects</a></li>
		<li class="dashboardProperty"><a href="#">other research projects</a></li>
		<li class="dashboardProperty"><a href="#">keywords</a></li>
		<li class="dashboardProperty"><a href="#">research areas (designated</a></li>
		<li class="dashboardProperty"><a href="#">patents</a></li>
		<li class="dashboardProperty"><a href="#">research services or facilities used</a></li>
		<li class="dashboardProperty"><a href="#">professional service</a></li>
		<li class="dashboardProperty"><a href="#">presentations</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Instruction &amp; Academics</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">teaching areas (statement)</a></li>
		<li class="dashboardProperty"><a href="#">for-credit courses</a></li>
		<li class="dashboardProperty"><a href="#">new courses planned</a></li>
		<li class="dashboardProperty"><a href="#">academic initiatives</a></li>
		<li class="dashboardProperty"><a href="#">advising</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Outreach &amp; Service</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">outreach statement</a></li>
		<li class="dashboardProperty"><a href="#">impact statement</a></li>
		<li class="dashboardProperty"><a href="#">public service</a></li>
		<li class="dashboardProperty"><a href="#">organizational advising or consulting</a></li>
		<li class="dashboardProperty"><a href="#">non-credit instruction</a></li>
		<li class="dashboardProperty"><a href="#">media expertise</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Bio &amp; Background</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">educational background</a></li>
		<li class="dashboardProperty"><a href="#">professional background</a></li>
		<li class="dashboardProperty"><a href="#">awards &amp; distinctions</a></li>
		<li class="dashboardProperty"><a href="#">university title</a></li>
		<li class="dashboardProperty"><a href="#">working title</a></li>
		<li class="dashboardProperty"><a href="#">emplid</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Publications &amp; Other Works</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">author of</a></li>
		<li class="dashboardProperty"><a href="#">editor of</a></li>
		<li class="dashboardProperty"><a href="#">performer of</a></li>
		<li class="dashboardProperty"><a href="#">creator of</a></li>
		<li class="dashboardProperty"><a href="#">contributor of</a></li>
	</li>
		</ul>
	<li>
		<h2><a href="#">International Expertise &amp; Activities</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">international statement</a></li>
		<li class="dashboardProperty"><a href="#">geographical research area</a></li>
		<li class="dashboardProperty"><a href="#">collaboration with</a></li>
	</li>
		</ul>
	<li>
		<h2><a href="#">Contact Information</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">photo</a></li>
		<li class="dashboardProperty"><a href="#">office address</a></li>
		<li class="dashboardProperty"><a href="#">office phone</a></li>
		<li class="dashboardProperty"><a href="#">email address</a></li>
		<li class="dashboardProperty"><a href="#">links</a></li>
		</ul>
	</li>
</ul>
</div>