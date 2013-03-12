<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="feedback"/>
    <jsp:param name="titleText" value="Feedback | Cornell University"/>
</jsp:include>


<%-- The captcha JSP used here requires a Java AWT library that's not always loaded correctly 
We're catching errors and submitting the form even if the captcha fails to load,
then sending a notification email saying the captcha is not loading properly. --%>

<%-- get the status of the captcha --%>
<c:catch var="captchaError">
    <c:import var="captcha" url="forms/captcha.jsp"/>
</c:catch>

<%-- set the status in the session --%>
<c:if test="${empty captchaError}">
    <% session.setAttribute("status","ok"); %>
    <c:set var="captchaStatus" value="ok"/>
</c:if>
<c:if test="${not empty captchaError}">
    <% session.setAttribute("status","error"); %>
    <c:set var="captchaStatus" value="error"/>
</c:if>

<div id="contentWrap">
	<div id="content">

	        <h2>Site Feedback</h2>
	        <p>We appreciate any comments or suggestions you would like to share. Your name and email address will not be used for any purpose other than responding to the comments or questions submitted.</p>
            <p><em>*</em> indicates required fields</p>
            
            <form class="cmxform" id="feedbackForm" method="get" action="/feedback-submit.jsp">
                
                <label for="fname">My full name:</label>
                <input id="fname" name="name" size="25" class="text" tabindex="1" />
                
                <label for="femail">My email address:</label>
                <input id="femail" name="email" size="25" class="text email" tabindex="2" />
                
                <label for="type">I'm writing in regard to: <em>*</em></label>
                <select id="ftype" name="type" tabindex="3">
                    <option value="">&nbsp;--- select an item ---&nbsp;</option>
                    <option value="content">Site Content</option>
                    <option value="technical">Technical Issues</option>
                    <option value="other">Other</option>
                </select>
                
                <label for="fmessage">My comments, suggestions, questions: <em>*</em></label>
                <textarea id="fmessage" name="message" cols="22" class="required" tabindex="4"></textarea>
                

                <c:if test="${captchaStatus=='ok'}">
                    <label for="captcha">Please verify the code shown here: <em>*</em></label>
                    <img id="captchaImage" src="/forms/captcha.jsp" alt="captcha image"/>
                    <em class="note">If you cannot read this image, <a title="change code" href="#captchaImage">click here</a> to use a new one</em>
                    <input id="captcha" name="captcha" size="25" class="text required" tabindex="5" />
                </c:if>
                
                <input class="submit" type="submit" value="Submit" tabindex="6" />

            </form>

	
	</div> <!-- content -->
</div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp" />