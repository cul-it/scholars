<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<c:set var='imageDir' value='images' />
<c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
<c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
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
	<%-- Cornell affiliations --%>
    <c:url var="overviewStatement" value="/edit/editDatapropStmtRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#overviewStatement"/>
    </c:url>
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
    <%-- Research & Professional Activities --%>
    <c:url var="researchArea" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonHasResearchArea"/>
    </c:url>
    <c:url var="sponsoredProjects" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#PersonPrimaryInvestigatorOfFinancialAward"/>
    </c:url>
    <c:url var="linkkeyword" value="/editForm">
        <c:param name="home" value="${portal.portalId}"/>
		<c:param name="individualURI" value="${entity.URI}"/>
		<c:param name="origin" value="user"/>
		<c:param name="controller" value="Keys2Ents"/>
    </c:url>
    <c:url var="removekeyword" value="/editForm">
        <c:param name="home" value="${portal.portalId}"/>
		<c:param name="individualURI" value="${entity.URI}"/>
		<c:param name="origin" value="user"/>
		<c:param name="action" value="remove"/>
		<c:param name="controller" value="Keys2Ents"/>
    </c:url>
    <c:url var="newkeyword" value="/editForm">
        <c:param name="home" value="${portal.portalId}"/>
		<c:param name="individualURI" value="${entity.URI}"/>
		<c:param name="origin" value="user"/>
		<c:param name="controller" value="Keyword"/>
    </c:url>

    
    <%-- Academics --%>
    <c:url var="teachingFocus" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#teachingFocus"/>
    </c:url>
    
    <%-- Service --%>
    <c:url var="outreachFocus" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#outreachFocus"/>
    </c:url>
    <%-- Background --%>
    <%-- Publications --%>
    <%-- International --%>
    <c:url var="researchFocus" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#internationalFocus"/>
    </c:url>

    <c:url var="geographicalResearchArea" value="/edit/editRequestDispatch.jsp">
      <c:param name="subjectUri" value="${entity.URI}"/>
      <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#hasGeographicalResearchArea"/>
    </c:url>

    <%-- Contact --%>
<ul id="dashboardNavigation">
	<li>
		<h2><a href="#">Cornell Affiliations</a></h2>
		<ul class="dashboardCategories">
			<li class="dashboardProperty"><a href="${overviewStatement}">overview statement</a></li>
			<li class="dashboardProperty"><a href="${headof}">head of</a></li>
			<li class="dashboardProperty"><a href="${dept}">academic initiative(s)</a></li>
			<li class="dashboardProperty"><a href="${gradfield}">graduate field membership(s)</a></li>
			<li class="dashboardProperty"><a href="${membercenter}">affiliations with center/institute</a></li>
			<li class="dashboardProperty"><a href="${committees}">campus committees &amp; services</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Research &amp; Professional Activities</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="${researchArea}">research areas</a></li>
		<li class="dashboardProperty"><a href="${sponsoredProjects}">sponsored projects</a></li>
		<li class="dashboardProperty"><a href="${linkkeyword}">select keyword</a></li>
		<c:if test="${!empty(entity.keywords)}">
			<li class="dashboardProperty"><a href="${removekeyword}">remove keyword</a></li>
		</c:if>
		<li class="dashboardProperty"><a href="${newkeyword}">new keyword</a></li>
		<li class="dashboardProperty"><a title="disabled">professional
		service (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled">presentations (disabled)</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">International Expertise &amp; Activities</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="${geographicalResearchArea}">geographical
		research area</a></li>
		<li class="dashboardProperty"><a title="disabled"
		>international statement (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled"
		>collaboration with (disabled)</a></li>
		</ul>
	</li>

	<li>
		<h2><a href="#">Instruction &amp; Academics</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a title="disabled" >teaching
		areas (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >for-credit
		courses (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >new courses
		planned (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >academic
		initiatives (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >advising (disabled)</a></li>
		</ul>
	</li>

	<li>
		<h2><a href="#">Outreach &amp; Service</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a title="disabled" >outreach
		statement (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >impact
		statement (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >public
		service (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled"
		>organizational advising or consulting (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >non-credit
		instruction (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >media
		expertise (disabled)</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Bio &amp; Background</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a title="disabled" >educational
		background (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled"
		>professional background (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >awards
		&amp; distinctions (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >university
		title (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >working
		title (disabled)</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Publications &amp; Other Works</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a title="disabled" >author of (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >editor of (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >performer
		of (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >creator of (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >contributor
		of (disabled)</a></li>
		</ul>
	</li>
	<li>
		<h2><a href="#">Contact Information</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a title="disabled" >photo (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >office
		address (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >office
		phone (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >email
		address (disabled)</a></li>
		<li class="dashboardProperty"><a title="disabled" >links (disabled)</a></li>
		</ul>
	</li>
</ul>
</div>
