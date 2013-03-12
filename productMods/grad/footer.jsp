<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="org.joda.time.DateTime" %>

<%
  DateTime now = new DateTime();
  request.setAttribute("year", now.toString("yyyy") + " " );
%>

	</div> <!-- wrap -->
    <div class="push"></div> <%-- this push div is helps to stick the footer to the bottom --%>
</div> <!-- overlay -->
<div id="footer">
	<div>
	    <a class="siteFeedback" href="/feedback/" title="Send Us Feedback">Site Feedback</a>
	    <p>&#169; ${year} <a href="http://lifesciences.cornell.edu" title="home"><strong>Life Sciences</strong></a> <a href="http://www.cornell.edu" title="Cornell University">Cornell University</a> Ithaca, NY 14853</p>
	    
        <%-- secret VIVO link, ssshhh... --%>
	    <c:if test="${!empty param.uri && param.uri !=''}">
    	    <c:url var="vivoLink" value="http://vivo.cornell.edu/entity">
    	        <c:param name="uri" value="${param.uri}"/>
    	    </c:url>
            <a target="_blank" class="vivoLink" href="${vivoLink}">open in VIVO</a>
	    </c:if>
    </div>
</div><!-- footer -->

<%-- MINT STATISTICS (disabled by default) --%>
<%--
<!-- <script src="http://vivostats.mannlib.cornell.edu/grad/?js" type="text/javascript"></script> -->
--%>
<%-- GOOGLE ANALYTICS (disabled by default -- uncomment on production machine only!)--%>
<%--
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-5164622-4']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
--%>
</body>
</html>