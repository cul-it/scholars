<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:choose>
	<c:when test="${!empty individual}">
		<c:if test="${!empty individual.objectPropertyMap}">
			<c:choose>
				<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#holdFacultyAppointmentIn'].objectPropertyStatements}">
					<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#holdFacultyAppointmentIn'].objectPropertyStatements[0].object}"/>
				</c:when>
				<c:otherwise>
					<c:choose>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellAcademicStaffOtherParticipantInOrganizedEndeavor'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellAcademicStaffOtherParticipantInOrganizedEndeavor'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#Non-AcademicEmployeeOtherParticipantInOrganizedEndeavor'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#Non-AcademicEmployeeOtherParticipantInOrganizedEndeavor'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarianForOrganizedEndeavor'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#CornellLibrarianForOrganizedEndeavor'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#CornellArchivistForOrganizedEndeavor'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#CornellArchivistForOrganizedEndeavor'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:otherwise/>
					</c:choose>
				</c:otherwise>
			</c:choose>
			<c:if test="${!empty dept}"> | ${dept.name}</c:if>
			<c:if test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#holdsFacultyAdminAppointmentIn'].objectPropertyStatements}">
				<c:set var="adminDept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#holdsFacultyAdminAppointmentIn'].objectPropertyStatements[0].object}"/>
				<c:if test="${!empty adminDept}"> | ${adminDept.name}</c:if>
			</c:if>
		</c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
