<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="org.joda.time.DateTime" %>
<%@ page import="org.joda.time.Period" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.hp.hpl.jena.rdf.model.*" %>
<%@ page import="com.hp.hpl.jena.ontology.*" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep"%>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.admin.auditSelfEditingAgents.jsp");
%>
<%  if(session == null || !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
        %><c:redirect url="/about"></c:redirect><%
    }
	Model auditModel = (Model)getServletContext().getAttribute("jenaAuditModel");
    Model mainModel = (Model)getServletContext().getAttribute("jenaOntModel");
    OntModel combinedModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_DL_MEM);
    combinedModel.addSubModel(auditModel);
    combinedModel.addSubModel(mainModel);
    request.setAttribute("combinedModel",combinedModel);
%>
<%
    int days = 7;
    String dayStr = request.getParameter("days");
	if (dayStr!=null) {
	    try {
	        int intval = Integer.parseInt(dayStr);
	        if (intval > 0) {
	            days = intval;
	        } else {
	            request.setAttribute("paramError","Note: the \"days\" parameter submitted ("+dayStr+") must be a positive integer; using default value");
	        }
	    } catch (NumberFormatException ex) {
	        request.setAttribute("paramError","Note: could not parse the \"days\" parameter value \""+dayStr+"\" as a positive integer; using default value");
	    }
	}
    DateTime now = new DateTime();
    DateTime sinceWhen = now.minus(Period.days(days));
    request.setAttribute("since", "\"" + sinceWhen.toString("yyyy-MM-dd'T'HH:mm:ss") + "\"" );
%>
    
<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>  <!-- from formPrefix.jsp -->
	<link rel="stylesheet" type="text/css" href="<c:url value="/${themeDir}css/screen.css"/>" media="screen"/>
    <title>VIVO Correction Form</title>
</head>
<body class="formsEdit">
<div id="wrap">
<jsp:include page="/${themeDir}jsp/identity.jsp" flush="true"/>
<div id="contentwrap">
<jsp:include page="/${themeDir}jsp/menu.jsp" flush="true"/>
<!-- end of formPrefix.jsp -->

<div id="content">
<div class="staticPageBackground">
<div class="feedbackForm">
<h2>VIVO Self-Editors in the past <%=days%> days</h2>
<c:if test="${!empty paramError}"><p>${paramError}</p></c:if>
<sparql:lock model="${requestScope.combinedModel}" > 
<sparql:sparql>
    <sparql:select model="${requestScope.combinedModel}" var="rs" since="${since}">
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
        PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
        PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
        SELECT DISTINCT ?datetime ?agent ?label ?uri
        WHERE
        {
        ?event vitro:loggedInAgent ?agent ;
               vitro:loggedInAt ?datetime .
        ?agent rdfs:label ?label .

        FILTER( xsd:dateTime(?datetime) >= xsd:dateTime(?since) )

        FILTER ( ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual19589>  && # Caruso
                 ?agent != <http://vivo.library.cornell.edu/ns/abox/hri2#person7134> && # Worthington
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual762>    && # Devare
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual24052>  && # Lowe
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual22972>  && # Corson-Rikert
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#TurnerJaron>      && # Porciello
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual24900>  && # Cappadona
                 ?agent != <http://vivo.library.cornell.edu/ns/0.1#individual23948> )   # Newberry
        }
        ORDER BY ?datetime
    </sparql:select>
    
    <fmt:setLocale value="en_US"/>
    <table>
    <c:forEach items="${rs.rows}" var="row">
        <fmt:parseDate var="loginDateTime" value="${row.datetime}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
        <fmt:formatDate var="loginDate" value="${loginDateTime}" pattern="EEEE', 'MMM'. 'd' 'yyyy" />
        <fmt:formatDate var="loginTime" value="${loginDateTime}" pattern="h:mm a" />
        
        <c:url var="agentLink" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${row.agent}"/></c:url>
         
        <tr><td>${loginDate}</td><td>${loginTime}</td><td><a href="${agentLink}" class="url">${row.label.lexicalForm}</a></td></tr>  
    </c:forEach>
    </table>
</sparql:sparql>
</sparql:lock>
<p/>
<form action="auditSelfEditingAgents.jsp">
    Report users for the previous <input type="text" name="days" size="2" value="<%=days%>"/> days
    <input type="submit" value="New Report" class="yellowbutton"/>
</form>
<p/>
</div><!--feedbackForm-->
</div><!-- staticPageBackground -->
</div><!--content-->

<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
</div> <!-- contentwrap -->
     <jsp:include page="/${themeDir}jsp/footer.jsp" flush="true"/>
</div><!-- wrap -->
</body>
</html>