<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="org.joda.time.DateTime" %>

<%
  DateTime now = new DateTime();
  request.setAttribute("year", now.toString("yyyy") );
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
<%-- GOOGLE ANALYTICS (disabled by default)--%>
<%--
<!-- <script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-5164622-4");
pageTracker._trackPageview();
pageTracker._setDomainName("none");
pageTracker._setAllowLinker(true);
</script> -->
--%>
</body>
</html>