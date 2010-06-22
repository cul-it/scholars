<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:choose>
	<c:when test="${!empty individual}">
		<c:if test="${!empty individual.objectPropertyMap}">
			<c:choose>
				<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicFacultyMember'].objectPropertyStatements}">
					<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicFacultyMember'].objectPropertyStatements[0].object}"/>
				</c:when>
				<c:otherwise>
					<c:choose>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicStaffMember'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAcademicStaffMember'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsNonAcademicStaffMember'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsNonAcademicStaffMember'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#employeeOfAsLibrarian'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#employeeOfAsLibrarian'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:when test="${!empty individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#employeeOfAsArchivist'].objectPropertyStatements}">
							<c:set var="dept" value="${individual.objectPropertyMap['http://vivo.cornell.edu/ns/mannadditions/0.1#employeeOfAsArchivist'].objectPropertyStatements[0].object}"/>
						</c:when>
						<c:otherwise/>
					</c:choose>
				</c:otherwise>
			</c:choose>
			<c:if test="${!empty dept}"> | ${dept.name}</c:if>
			<c:if test="${!empty individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAdminFacultyMember'].objectPropertyStatements}">
				<c:set var="adminDept" value="${individual.objectPropertyMap['http://vivo.library.cornell.edu/ns/0.1#employeeOfAsAdminFacultyMember'].objectPropertyStatements[0].object}"/>
				<c:if test="${!empty adminDept}"> | ${adminDept.name}</c:if>
			</c:if>
		</c:if>
	</c:when>
	<c:otherwise>
		<c:out value="Got nothing to draw here ..."/>
	</c:otherwise>
</c:choose>
