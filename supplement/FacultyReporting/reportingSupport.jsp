<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://www.atg.com/taglibs/json" prefix="json" %>

<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ObjectPropertyDao" %>

<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList" %>

<%@page import="com.hp.hpl.jena.rdf.model.Literal"%>

<%@page import="edu.cornell.mannlib.vitro.webapp.beans.Individual"%>
<sparql:lock model="${applicationScope.jenaOntModel}" >
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="reportingSupport" person="<${param.uri}>">
        PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
		PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
		PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7>
		PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
		PREFIX mann:  <http://vivo.cornell.edu/ns/mannadditions/0.1#>#
		PREFIX report: <http://facultyreportingsupport.vitro.mannlib.cornell.edu/ns/reportingSupport/0.1>

		SELECT  ?person ?personLabel ?questionUri ?questionLabel ?objUri ?objLabel
		WHERE 
		{
			{
			?person report:personHasReportingResponsibility ?report .
			?report report:hasMandatoryQuestion ?questionUri .
			OPTIONAL{?person rdfs:label ?personLabel . }
			OPTIONAL{?person ?questionUri ?objUri . ?objUri rdfs:label ?objLabel . }
			OPTIONAL{?questionUri rdfs:label ?questionLabel}
			} 
			UNION 
			{
  			?person report:personHasReportingResponsibility ?report .
   			?report report:hasQuestion ?questionUri .
   			OPTIONAL{?person rdfs:label ?personLabel . }
			OPTIONAL{?person ?questionUri ?objUri . ?objUri rdfs:label ?objLabel . }
			OPTIONAL{?questionUri rdfs:label ?questionLabel}
			}
		}
		ORDER BY ASC( ?person )
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:set var="questionResult" scope="request" value="${reportingSupport}" />

<h4>${reportingSupport[0].personLabel.string}</h4>

<%
   VitroRequest vreq = new VitroRequest(request);
   WebappDaoFactory wdf = vreq.getWebappDaoFactory();
   ObjectPropertyDao objPropDao = wdf.getObjectPropertyDao();
   Individual ent = wdf.getIndividualDao().getIndividualByURI(request.getParameter("uri"));
   request.setAttribute("entity", ent);   
%>

<table border="1">
<tr>
	<td align="center"><b>Question</b></td>
	<td align="center"><b>Answer</b></td>
</tr>
<%
   if( request.getAttribute("questionResult") != null )
   {
	   if( request.getAttribute("questionResult") instanceof List )
	   {
		   for( Object item : (List)request.getAttribute("questionResult") )
		   {
			   HashMap bindings = (HashMap)item;
			   Object questionUriValue = bindings.get("questionUri");
			   //out.println("<b>questionUriValue: </b>"+ questionUriValue +"<br>");
			   Object objLabelValue = bindings.get("objLabel");
			   //out.println("<b>objLabelValue: </b>" + objLabelValue +"<br>");
			   ObjectProperty objProp = objPropDao.getObjectPropertyByURI(questionUriValue.toString());
			   //out.println("<b>objProp: </b>" + objProp +"<br>");
			   //out.println("<b>objProp.getDomainPublic(): </b>" + objProp.getDomainPublic() +"<br><br><br>");
			   %>
			   <tr>
					<td><%= objProp.getDomainPublic() %></td>
					<% if (objProp instanceof ObjectProperty) 
					{
						//ObjectProperty op = (ObjectProperty) objProp;
						request.setAttribute("objProp", objProp);						
						 
			    		} 
						if (objLabelValue != null) 
						{
						%>
							<td>QUESTION ANSWERED</td>
    					<% 
						}
						else 
						{
						%>
							<td>NEED TO ANSWER QUESTION &nbsp;&nbsp;
							<edLnk:editLinks item="${requestScope.objProp}" icons="true"/> &nbsp;&nbsp;
							<%
							String questionUriValueSplit[] = questionUriValue.toString().split("#");
							String urlValue = request.getContextPath() + "/entity?uri=" +java.net.URLEncoder.encode(request.getParameter("uri").toString(),"UTF-8") + "&property=" + questionUriValueSplit[1];
							%>
							<a href="<%= urlValue%>">Go to this property on your page</a>
							</td>
    					<% 
						}
			     		%> 
			   </tr> 
		    <%
		   }
	   }
	   else
	   {
		   out.println("questionResult was not a List");
	   }
   }
   else
   {
	   out.println("questionResult was null");
   }
%>
</table>