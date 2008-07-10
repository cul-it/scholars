<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.1" prefix="mt" %>
<%@ page import="org.joda.time.DateTime"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="feedback"/>
    <jsp:param name="titleText" value="Feedback | Cornell University"/>
</jsp:include>

<div id="contentWrap">
	<div id="content">

<%-- 
    String captchaKey = session.getAttribute("captcha").toString(); 
    String requestedValue = request.getParameter("captcha");
--%>
<%
    DateTime now = new DateTime();
    request.setAttribute("now", "\"" + now.toDateTime().toString() + "\"" );

    DateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss");
    java.util.Date date = new java.util.Date();
    String d = dateformat.format(date);

%>

        <%-- <c:set var="captchaKey" value="<%=captchaKey%>"/> --%>
        <%-- <c:set var="requestKey" value="<%=requestedValue%>"/> --%>
        
        <%-- <c:if test="${captchaKey == requestKey}"> --%>
        
            <h2>Got it!</h2>
            <p>Thanks for taking the time to send us feedback.</p>

            <%-- Build the email body here before sending --%>
            <fmt:parseDate var="now" value="<%=d%>" pattern="yyyy-MM-dd-HH:mm:ss" />
            <fmt:formatDate var="dateTime" value="${now}" type="both" pattern="EEEE, MMMM d @ hh:mm a"  />
            
            <c:if test="${!empty param.name}">
                <c:set var="fbName">${param.name}</c:set>
            </c:if>
            <c:if test="${empty param.name}">
                <c:set var="fbName">not provided</c:set>
            </c:if>

            
            <c:if test="${!empty param.email}">
                <c:set var="fbEmail">${param.email}</c:set>
            </c:if>
            <c:if test="${empty param.email}">
                <c:set var="fbEmail">not provided</c:set>
            </c:if>
            
            
            <c:if test="${!empty param.message}">
                <c:set var="fbMessage">${param.message}</c:set>
            </c:if>
            
            <c:choose>
                <c:when test="${param.type == 'content'}">
                    <c:set var="fbRegarding" value="content"/>
                </c:when>
                <c:when test="${param.type == 'technical'}">
                    <c:set var="fbRegarding" value="technical issues"/>
                </c:when>
                <c:when test="${param.type == 'other'}">
                    <c:set var="fbRegarding" value="other"/>
                </c:when>
            </c:choose>
            
<c:set var="emailBody">
Received: ${dateTime}
From: ${fbName}
Email: ${fbEmail}
<%-- Regarding: ${fbRegarding} --%>

Message:
${fbMessage}
</c:set>
            <mt:mail>

                <c:choose>
                    <c:when test="${param.type == 'content'}">
                       <mt:setrecipient type="to">mw542@cornell.edu</mt:setrecipient>
                       <%-- <mt:setrecipient type="cc">nac26@cornell.edu</mt:setrecipient> --%>
                       <mt:subject>Life Science Graduate Portal - Feedback Received (content-related)</mt:subject>
                    </c:when>
                    <c:when test="${param.type == 'technical'}">
                        <mt:setrecipient type="to">mw542@cornell.edu</mt:setrecipient>
                        <%-- <mt:setrecipient type="cc">nac26@cornell.edu</mt:setrecipient> --%>
                        <mt:subject>Life Science Graduate Portal - Feedback Received (technical issues)</mt:subject>
                    </c:when>
                    <c:when test="${param.type == 'other'}">
                        <mt:setrecipient type="to">mw542@cornell.edu</mt:setrecipient>
                        <%-- <mt:setrecipient type="cc">nac26@cornell.edu</mt:setrecipient> --%>
                        <mt:subject>Life Science Graduate Portal - Feedback Received (other)</mt:subject>
                    </c:when>
                </c:choose>
                
                <mt:from>site-feedback@grad.lifesciences.cornell.edu</mt:from>

                <mt:message>${emailBody}</mt:message>
                
                <mt:send>
                    <p>The following errors occured<br/><br/>
                    <mt:error id="err">
                        <jsp:getProperty name="err" property="error"/><br/>
                    </mt:error>
                    <br/>Please back up a page, fix the error and resubmit.</p>
                </mt:send>

            </mt:mail>
        
        <%-- </c:if> --%>
        
        <%-- <c:if test="${captchaKey != requestKey}">
            <h2>Sorry, there was a problem...</h2>
            <p>It looks like the code you entered was incorrect. Hit your back button to try again.</p>
        </c:if> --%>
        
	</div> <!-- content -->
</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />
