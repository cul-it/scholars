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
    <c:url var="researchFocus" value="/edit/editDatapropStmtRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#researchFocus"/>
    </c:url>
    <c:url var="sponsoredProjects" value="/edit/editRequestDispatch.jsp">
        <c:param name="subjectUri" value="${entity.URI}"/>
        <c:param name="predicateUri" value="http://vivo.library.cornell.edu/ns/0.1#primaryInvestigatorOf"/>
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
		<li class="dashboardProperty"><a href="${researchFocus}">research focus</a></li>
		<li class="dashboardProperty"><a href="${sponsoredProjects}">sponsored projects</a></li>
		<li class="dashboardProperty"><a href="#">other research projects</a></li>
		<li class="dashboardProperty"><a href="${linkkeyword}">select keyword</a></li>
		<c:if test="${!empty(entity.keywords)}">
			<li class="dashboardProperty"><a href="${removekeyword}">remove keyword</a></li>
		</c:if>
		<li class="dashboardProperty"><a href="${newkeyword}">new keyword</a></li>
		<li class="dashboardProperty"><a href="${researchAreas}">research areas (designated</a></li>
		<li class="dashboardProperty"><a href="#">patents</a></li>
		<li class="dashboardProperty"><a href="${facilities}">research services or facilities used</a></li>
		<li class="dashboardProperty"><a href="${professionalService}">professional service</a></li>
		<li class="dashboardProperty"><a href="${presentations}">presentations</a></li>
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
		</ul>
	</li>
	<li>
		<h2><a href="#">International Expertise &amp; Activities</a></h2>
		<ul class="dashboardCategories">
		<li class="dashboardProperty"><a href="#">international statement</a></li>
		<li class="dashboardProperty"><a href="#">geographical research area</a></li>
		<li class="dashboardProperty"><a href="#">collaboration with</a></li>
		</ul>
	</li>
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