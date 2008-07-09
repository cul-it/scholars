<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.1" prefix="mt" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/regexp-1.0" prefix="rx" %>
<%@ page import="javax.mail.internet.AddressException" %>
<%@ page import="javax.mail.internet.InternetAddress" %>


<mt:mail>
    <mt:setrecipient type="to">mw542@cornell.edu</mt:setrecipient>

    <c:set var="testEmail" value="mil#es@unthunk.org"/>
    
        <mt:from>
            <c:out value="${testEmail}"/>
        </mt:from>


        <p>The following errors occured<br/><br/>
        <mt:error id="err">
            <jsp:getProperty name="err" property="error"/><br/>
        </mt:error>
        <br/>Please back up a page, fix the error and resubmit.</p>
</mt:mail>
