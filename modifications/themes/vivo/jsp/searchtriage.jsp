<%@ page language="java" %>
<%@ page import="java.util.*" %>

<%	/***********************************************

	Determine whether the user is searching this application or Cornell
	
	************/
	
String scope=request.getParameter("sitesearch");
if (scope!=null && !scope.equals("")) {
	if (scope.equalsIgnoreCase("www.cornell.edu")) {
		String query=request.getParameter("querytext");
		response.sendRedirect("http://www.google.com/u/cuweb?q="+query+"&sa=Search&domains=cornell.edu&sitesearch=cornell.edu");
		return;
	}
}
%>

<jsp:forward page="/search" />
