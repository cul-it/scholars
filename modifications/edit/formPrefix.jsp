<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%><%/* this odd thing points to something in web.xml */ %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>  <!-- formPrefix.jsp -->
<%
    request.setAttribute("themeDir","themes/editdefault/");
	String height = (height=request.getParameter("height")) != null && !(height.equals("")) ? height : "5";
	String width  = (width=request.getParameter("width")) != null && !(width.equals("")) ? width : "50%";
	String defaultButtons="bold,italic,underline,separator,link,bullist,numlist,separator,sub,sup,charmap,separator,undo,redo,separator,removeformat,cleanup,help,code";
	String buttons = (buttons=request.getParameter("buttons")) != null && !(buttons.equals("")) ? buttons : defaultButtons;
	String tbLocation = (tbLocation=request.getParameter("toolbarLocation")) != null && !(tbLocation.equals("")) ? tbLocation : "top";
%>
	<script language="javascript" type="text/javascript" src="../js/tiny_mce/tiny_mce.js"></script>
    <script language="javascript" type="text/javascript">
	tinyMCE.init({
		theme : "advanced",
		mode : "textareas",
		theme_advanced_buttons1 : "<%=buttons%>",
		theme_advanced_buttons2 : "",
		theme_advanced_buttons3 : "",
		theme_advanced_toolbar_location : "<%=tbLocation%>",
		theme_advanced_toolbar_align : "left",
		theme_advanced_resizing : true,
		height : "<%=height%>",
		width  : "<%=width%>",
		valid_elements : "a[href|target|name|title],br,p,i,em,cite,strong/b,u,ul,ol,li" 	
		// save_callback : "customSave",
		// content_css : "example_advanced.css",
		// extended_valid_elements : "a[href|target|name]",
		// plugins : "table",
		// theme_advanced_buttons3_add_before : "tablecontrols,separator",
		// invalid_elements : "li",
		// theme_advanced_styles : "Header 1=header1;Header 2=header2;Header 3=header3;Table Row=tableRow1", // Theme specific setting CSS classes
	});
    </script>


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