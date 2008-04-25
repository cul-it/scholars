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

<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/jquery_plugins/getURLParam.js"></script>
<script type="text/javascript" src="js/propertyGroupSwitcher.js"></script>