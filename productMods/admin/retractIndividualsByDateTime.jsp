<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%!
    
    private static final String TIMEKEY = VitroVocabulary.TIMEKEY;
    private static final String SUNRISE = VitroVocabulary.SUNRISE;
    private static final String SUNSET = VitroVocabulary.SUNSET;
    private static final String MODTIME = VitroVocabulary.MODTIME;
    
    protected DateFormat xsdDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    
%>

<%!

    private Date getDateTime(Individual ind, String dateTimePropURI) {
	    if (TIMEKEY.equals(dateTimePropURI)) {
	    	return ind.getTimekey();
	    } else if (SUNRISE.equals(dateTimePropURI)) {
	    	return ind.getSunrise();
	    } else if (SUNSET.equals(dateTimePropURI)) {
	    	return ind.getSunset();
	    } else if (MODTIME.equals(dateTimePropURI)) {
	    	return ind.getModTime();
	    } else {
	    	DataProperty dp = ind.getDataPropertyMap().get(dateTimePropURI);
	    	if (dp != null) {
	    		List<DataPropertyStatement> dpsList = dp.getDataPropertyStatements();
	    		if (dpsList == null) {
	    			return null;
	    		}
	    		DataPropertyStatement dps = dpsList.get(0);
	    		if (dps == null) {
	    			return null;
	    		} else {
	    			try {
	    			    return xsdDateTimeFormat.parse(dps.getData());
	    			} catch (Exception e) {
	    				return null;
	    			}
	    		}
	    	} else {
	    		return null;
	    	}
	    }
    }
 
%>

<%

	if(session == null || !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
	    %><c:redirect url="/about"></c:redirect><%
	}

    VitroRequest vreq = new VitroRequest(request);

    //WebappDaoFactory wadf = vreq.getWebappDaoFactory();    fitering == very SLOOOOOW
    WebappDaoFactory wadf = (WebappDaoFactory) getServletContext().getAttribute("webappDaoFactory");
    String dateTimePropURI = vreq.getParameter("dateTimePropURI");
    boolean postSubmit = (dateTimePropURI != null) ? true : false;
    String errorMsg = null;
    
    if (postSubmit) {
	    String vclassURI = vreq.getParameter("vclassURI");
	    String outputFmt = vreq.getParameter("outputFmt");
	    String yearStr = vreq.getParameter("year");
	    String monthStr = vreq.getParameter("month");
	    String dayStr = vreq.getParameter("day");
	    if (dayStr.length() == 1) {
	    	dayStr = "0" + dayStr;
	    }
	    
	    boolean outputRequired = (!"".equals(outputFmt));
	    OntModel ontModel = (OntModel) getServletContext().getAttribute(JenaBaseDao.ASSERTIONS_ONT_MODEL_ATTRIBUTE_NAME);
	    Model outputModel = ModelFactory.createDefaultModel(); 
	    	
	    try {
	    	
	    	List<Individual> rawIndividualList = wadf.getIndividualDao().getIndividualsByVClassURI(vclassURI);
	    	Date comparisonDate = xsdDateTimeFormat.parse(yearStr + "-" + monthStr + "-" + dayStr + "T00:00:00");
	    	for (Individual ind : rawIndividualList) {
	    		Date date = getDateTime(ind, dateTimePropURI);
	    		if (date != null && date.before(comparisonDate)) {
	    			if (outputRequired) {
	    				outputModel.add(ontModel.listStatements(ontModel.getResource(ind.getURI()), (Property) null, (RDFNode) null));
	                    outputModel.add(ontModel.listStatements((Resource) null, (Property) null, ontModel.getResource(ind.getURI())));
	                    for (Link l : ind.getLinksList()) {
	                    	outputModel.add(ontModel.listStatements(ontModel.getResource(l.getURI()), (Property) null, (RDFNode) null));
	                    }
	    			}
	    			for (Link l : ind.getLinksList()) {
	    			    wadf.getLinksDao().deleteLink(l);
	    			}
	    			wadf.getIndividualDao().deleteIndividual(ind);
	    		}
	    	}
	    	if (outputRequired) {
	    		if ("RDF/XML".equals(outputFmt)) {
	    			response.setContentType("application/rdf+xml");
	    		} else if ("TTL".equals(outputFmt)) {
	    			response.setContentType("text/turtle");
	    		} else if ("N3".equals(outputFmt)) {
	    			response.setContentType("text/n3");
	    		} else if ("N-TRIPLE".equals(outputFmt)) {
	    			response.setContentType("text/plain");
	    		}
	    		outputModel.write(response.getOutputStream(), outputFmt);
	    		return;
	    	}
	    } catch (Exception e) {
	    	errorMsg = e.getClass().getName() + "<br/>";
	    	for (StackTraceElement traceElt : e.getStackTrace()) {
	    		errorMsg += traceElt.toString() + "<br/>";
	    	}
	    }
    } else {
    	System.out.println("Hello1");
    	List<VClass> vclasses = wadf.getVClassDao().getAllVclasses();
    	System.out.println("Hello1.5");
    	Collections.sort(vclasses);
    	request.setAttribute("vclasses", vclasses);
    	System.out.println("Hello2");
    }

%>

<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@page import="java.util.List"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.Individual"%>
<%@page import="org.joda.time.DateTime"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.JenaBaseDao"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.hp.hpl.jena.rdf.model.ModelFactory"%>
<%@page import="com.hp.hpl.jena.rdf.model.Model"%>
<%@page import="com.hp.hpl.jena.rdf.model.Property"%>
<%@page import="com.hp.hpl.jena.rdf.model.RDFNode"%>
<%@page import="com.hp.hpl.jena.rdf.model.Resource"%>
<%@page import="com.hp.hpl.jena.ontology.OntModel"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.VClass"%>
<%@page import="java.util.Collections"%>
<%@page import="edu.cornell.mannlib.vedit.beans.LoginFormBean"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.Link"%><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>  <!-- from formPrefix.jsp -->
    <link rel="stylesheet" type="text/css" href="<c:url value="/${themeDir}css/screen.css"/>" media="screen"/>
    <title>Delete Old Individuals</title>
</head>
<body class="formsEdit">
<div id="wrap">
<jsp:include page="/${themeDir}jsp/identity.jsp" flush="true"/>
<div id="contentwrap">
<jsp:include page="/${themeDir}jsp/menu.jsp" flush="true"/>
<!-- end of formPrefix.jsp -->

<div id="content">
<div class="staticPageBackground">

<h1>Delete Old Individuals</h1> 

<% if(postSubmit) { %>

<%     if(errorMsg != null) { %>
           <p class="warn"><%=errorMsg%></p>
<%     } else { %>
    
           <p style="color:green;">Individuals removed successfully.</p>

<%     } %>

           <p class="warn">Error removing individuals:</p>
           <p> <%=errorMsg%> </p>

<% } %>

<form action="" method="post>

    <label for="vclassURI">Delete individuals in class:</label>
    <select name="vclassURI" id="vclassURI">
        <c:forEach var="vclass" items="${vclasses}">
            <option value="${vclass.URI}">${vclass.pickListName}</option>
        </c:forEach>
    </select>    

    <hr/>

    <p>Delete individuals with</p>
    <input type="radio" name="dateTimePropURI" value="<%=TIMEKEY%>" id="timekey" checked="checked"/><label for="timekey">timekey</label>
    <input type="radio" name="dateTimePropURI" value="<%=SUNRISE%>" id="sunrise"/><label for="sunrise">sunrise</label>
    <input type="radio" name="dateTimePropURI" value="<%=SUNSET%>" id="sunset"/><label for="sunset">sunset</label>
    <input type="radio" name="dateTimePropURI" value="<%=MODTIME%>" id="modtime"/><label for="modtime">modtime</label>
    <p>prior to: </p>
    <select name="month">
        <option value="01">January</option>
        <option value="02">February</option>
        <option value="03">March</option>
        <option value="04">April</option>
        <option value="05">May</option>
        <option value="06">June</option>
        <option value="07">July</option>
        <option value="08">August</option>
        <option value="09">September</option>
        <option value="10">October</option>
        <option value="11">November</option>
        <option value="12">December</option>
    </select>
    <label for="day">day</label><input name="day" id="day" size="2"/>
    <label for="year">year</label><input name="year" id="year" size="4"/>

    <hr/>

    <p>Output deleted individuals for archival as:</p>
    <input type="radio" name="outputFmt" id="none" value="" checked="checked"/><label for="none">no output</label>
    <input type="radio" name="outputFmt" id="rdfxml" value="RDF/XML"/><label for="rdfxml">RDF/XML</label>
    <input type="radio" name="outputFmt" id="ntriples" value="N-TRIPLES"/><label for="ntriples">N-triples</label>
    <input type="radio" name="outputFmt" id="turtle" value="TTL"/><label for="turtle">Turtle</label>
 
    <hr/>

    <input type="submit" value="delete individuals"/>    

</form>

</div><!-- staticPageBackground -->
</div><!--content-->
</div> <!-- contentwrap -->
     <jsp:include page="/${themeDir}jsp/footer.jsp" flush="true"/>
</div><!-- wrap -->
</body>
</html>