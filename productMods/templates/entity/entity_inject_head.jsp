<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>

<%  /***********************************************
    This file is used to inject <link> and <script> elements
    into the head element of the generated source of a VITRO
    page that is being displayed by the entity controller.
    
    In other words, anything like domain.com/entity?...
    will have the lines specified here added in the <head>
    of the page.
    
    This is a great way to specify JavaScript or CSS files
    at the entity display level as opposed to globally.
    
    Example:
    <link rel="stylesheet" type="text/css" href="/css/entity.css"/>" media="screen"/>
    <script type="text/javascript" src="/js/jquery.js"></script>
****************************************************/ %>

<c:set var="portal" value="${requestScope.portalBean}"/>
<c:set var="contextPath"><c:out value="${pageContext.request.contextPath}" /></c:set>
<c:set var="themeDir" value="${contextPath}/${portal.themeDir}"/>


<c:url var="jquery" value="/js/jquery.js"/>
<c:url var="getURLParam" value="/js/jquery_plugins/getURLParam.js"/>
<c:url var="colorAnimations" value="/js/jquery_plugins/colorAnimations.js"/>
<c:url var="propertyGroupSwitcher" value="/js/propertyGroupSwitcher.js"/>
<c:url var="vitroControls" value="/js/controls.js"/>
<c:url var="jqueryForm" value="/js/jquery_plugins/jquery.form.js"/>
<c:url var="tinyMCE" value="/js/tiny_mce/tiny_mce.js"/>
<c:url var="googleVisualizationAPI" value="http://www.google.com/jsapi?autoload=%7B%22modules%22%3A%5B%7B%22name%22%3A%22visualization%22%2C%22version%22%3A%221%22%2C%22packages%22%3A%5B%22areachart%22%2C%22imagesparkline%22%5D%7D%5D%7D"/>

<link rel="stylesheet" type="text/css" href="<c:url value='/themes/vivo-basic/css/visualization/visualization.css'/>"/>
<script type="text/javascript" src="${jquery}"></script>
<script type="text/javascript" src="${getURLParam}"></script>
<script type="text/javascript" src="${colorAnimations}"></script>
<script type="text/javascript" src="${propertyGroupSwitcher}"></script>
<script type="text/javascript" src="${jqueryForm}"></script>
<script type="text/javascript" src="${tinyMCE}"></script>
<script type="text/javascript" src="${vitroControls}"></script>
<script type="text/javascript" src="${googleVisualizationAPI}"></script>
