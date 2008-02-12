<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%><%/* this odd thing points to something in web.xml */ %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>  <!-- formPrefix.jsp -->
    <%
        request.setAttribute("themeDir","themes/editdefault/");
    %>
  

    <c:url value="/${themeDir}css/screen.css" var="prefixCss"/>
	<link rel="stylesheet" type="text/css" href="${prefixCss}" media="screen"/>
	<c:url value="/${themeDir}css/formedit.css" var="prefixFormCss"/>
	<link rel="stylesheet" type="text/css" href="${prefixFormCss}" media="screen"/>
    <title>${themeDir}</title>
<body>
<div id="wrap">
    <jsp:include page="/${themeDir}jsp/identity.jsp" flush="true"/>
    <div id="contentwrap">
        <jsp:include page="/${themeDir}jsp/menu.jsp" flush="true"/>
        <!-- end of formPrefix.jsp -->