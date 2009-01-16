<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%-- Used by Javascript for captcha validation --%>

<% 
String captchaKey = session.getAttribute("captcha").toString(); 
String requestedValue = request.getParameter("captcha");
%>

<c:set var="captchaKey" value="<%=captchaKey%>"/>
<c:set var="requestedValue" value="<%=requestedValue%>"/>

<c:choose>
<c:when test="${captchaKey == requestedValue}">true</c:when>
<c:when test="${captchaKey != requestedValue}">false</c:when>
</c:choose>
