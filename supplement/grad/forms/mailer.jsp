<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.1" prefix="mt" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>

<%@ page session="false" %>
     <head>
          <title>Example JSP using mailer taglib</title>
     </head>
     <body bgcolor="#FFFFFF">
     <!-- The server, session, or mimeMessage attributes are not required -->
     <!-- the mail server used will be localhost. -->
     <mt:mail>
        <req:existsParameter name="server">
          <mt:server><req:parameter name="server"/></mt:server>
        </req:existsParameter>
        <req:existsParameter name="to">
          <mt:setrecipient type="to"><req:parameter name="to"/></mt:setrecipient>
        </req:existsParameter>
        <req:existsParameter name="from">
          <mt:from><req:parameter name="from"/></mt:from>
        </req:existsParameter>
        <req:existsParameter name="cc">
          <mt:setrecipient type="cc"><req:parameter name="cc"/></mt:setrecipient>
        </req:existsParameter>
        <req:existsParameter name="subject">
          <mt:subject><req:parameter name="subject"/></mt:subject>
        </req:existsParameter>
        <req:existsParameter name="message">
          <mt:message><req:parameter name="message"/></mt:message>
        </req:existsParameter>
	<mt:send>
	  <p>The following errors occured<br/><br/>
	  <mt:error id="err">
	    <jsp:getProperty name="err" property="error"/><br/>
	  </mt:error>
	  <br/>Please back up a page, fix the error and resubmit.</p>
	</mt:send>
     </mt:mail>

     <p>The message has been successfully sent.</p>
     </body>
</html>
