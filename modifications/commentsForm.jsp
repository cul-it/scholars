<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<div id="content" class="staticPageBackground">

<div class="feedbackForm">

<h2>Contact Us</h2>

  <p>
  	<c:choose>
  		<c:when test='${portalType eq "CALSResearch"}'>
   			Thank you for your interest in the Cornell University College of Agriculture and Life Sciences Research Portal.
   		</c:when>
   		<c:when test='${portalType eq "VIVO"}'>
   			Thank you for your interest in VIVO. 		
   		</c:when>
   		<c:otherwise>
   			Thank you for your interest in the ${siteName} portal.
   		</c:otherwise>
   	</c:choose>
  </p>
 	
 	<p>
 	  ${siteName} is a service that depends on regular updates and feedback.
		Please help us out by providing any necessary corrections and suggestions for additional content (people, departments, courses, research services, etc.)
		that you would like to see represented.
	</p>
	
		<c:if test='${portalType != "clone"}'>
 			<p>If you are looking for information on:</p>
			<ul>
				<li>Undergraduate admissions: contact <a href="http://admissions.cornell.edu/">http://admissions.cornell.edu/</a></li>
 				<li>Undergraduate financial aid: contact <a href="http://finaid.cornell.edu/">http://finaid.cornell.edu/</a></li>
 				<li>Graduate admissions and information: contact <a href="http://www.gradschool.cornell.edu/">http://www.gradschool.cornell.edu/</a></li>
 				<li>International Students and Scholars Office: contact <a href="http://www.isso.cornell.edu/">http://www.isso.cornell.edu/</a></li>
				<li>Faculty, staff and student directory: contact <a href="http://www.cornell.edu/search?tab=people">http://www.cornell.edu/search/?tab=people</a></li>
				<li>General information about Cornell University: <a href="http://www.cornell.edu/">http://www.cornell.edu/</a></li>
			</ul>
		</c:if>

  <p>
		<c:if test='${(siteName eq "CALSResearch" || siteName eq "CALSImpact")}'>
			The reference librarians at Albert R. Mann Library will be in touch with you soon.
		</c:if>
  </p>

		<form name = "contact_form" action="sendmail" method="post" onsubmit="return ValidateForm('contact_form');">
  		<input type="hidden" name="home" value="${portalId}"/>
  		<input type="hidden" name="RequiredFields" value="webuseremail,webusername,comments"/>
  		<input type="hidden" name="RequiredFieldsNames" value="Email address,Name,Comments"/>
  		<input type="hidden" name="EmailFields" value="webuseremail"/>
  		<input type="hidden" name="EmailFieldsNames" value="emailaddress"/>
  		<input type="hidden" name="DeliveryType" value="comment"/>
		
  		<label for="webuseremail"><h3>My email address is:</h3></label>
  		<input style="width:25%;" type="text" name="webuseremail" maxlength="255"/><br/><br/>
		
  		<label for="webusername"><h3>My full name is:</p></h3></label>
  		<input style="width:33%;" type="text" name="webusername" maxlength="255"/><br/><br/>

  		<label for="s34gfd88p9x1"><h3>Enter your comments, questions, or suggestions:</h3></label>
  		<textarea name="s34gfd88p9x1" rows="10" cols="90"></textarea>
		
  		<input type="submit" value="Submit" class="yellowbutton"/>
  		<input type="reset" value="Clear Form" class="plainbutton"/>

		<h3>Thank you!</h3>
		</form>

</div><!--feedbackForm-->

</div><!--staticPageBackground-->
