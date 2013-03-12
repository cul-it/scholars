<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- Using this JSP to allow for the URL /allfields instead of /areas/allfields --%>

<c:import url="areas.jsp">
    <c:param name="uri" value="allfields"/>
</c:import>
