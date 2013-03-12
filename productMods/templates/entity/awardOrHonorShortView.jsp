<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${!empty individual}">
    <p style="color:black">
    <c:out value="${individual.name}" />
    <c:if test="${!empty individual.moniker}">
        <c:out value=" | " />    
        <c:out value="${individual.moniker}" /> 
    </c:if>
    <p>
</c:if>    