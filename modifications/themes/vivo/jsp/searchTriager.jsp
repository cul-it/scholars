<%@ page language="java" %>
<%@ page import="java.util.*" %>

<%	/***********************************************

	Determine whether the user is searching this application or Cornell
	
	************/
	
String scope=request.getParameter("sitesearch");
if (scope!=null && !scope.equals("")) {
	if (scope.equalsIgnoreCase("www.cornell.edu")) {
		String query=request.getParameter("querytext");
		/* Cornell search
		<input type="hidden" name="output" value="xml_no_dtd" />
		<input type="hidden" name="sort" value="" />
		<input type="hidden" name="ie" value="UTF-8" />
		<input type="hidden" name="oe" value="UTF-8" />
		<input type="hidden" name="gsa_client" value="default_frontend" />
		<input type="hidden" name="site" value="default_collection" />
		<input type="hidden" name="proxyreload" value="1" />
		<input type="hidden" name="btnG" value="go" />
	    */
		response.sendRedirect("http://www.cornell.edu/search?q="+query+"&output=xml_no_dtd&ie=UTF-8&oe=UTF-8&gsa_client=default_frontend&site=default_collection&proxyreload=1&btnG=go");
		return;
	}
}
response.sendRedirect("../../../search?" + request.getQueryString());
%>