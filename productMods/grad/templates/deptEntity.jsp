<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<sparql:lock model="${applicationScope.jenaOntModel}">
<sparql:sparql>
    <listsparql:select model="${applicationScope.jenaOntModel}" var="dept" dept="<${param.uri}>">
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      PREFIX core: <http://vivoweb.org/ontology/core#>
      SELECT DISTINCT ?deptLabel ?description ?primaryLinkAnchor ?primaryLinkURL ?deptHeadLabel ?deptHeadUri ?campus
      WHERE {
          ?dept rdfs:label ?deptLabel ;
            rdf:type core:AcademicDepartment .
          OPTIONAL { ?dept core:description ?description }
          OPTIONAL { ?dept vitro:primaryLink ?primaryLink. ?primaryLink vitro:linkAnchor ?primaryLinkAnchor . ?primaryLink vitro:linkURL ?primaryLinkURL }
          OPTIONAL { ?dept vivo:cornellOrganizedEndeavorHasLeadParticipantPerson ?deptHeadUri . ?deptHeadUri rdfs:label ?deptHeadLabel }
          OPTIONAL { ?dept vivo:locatedOnCampus ?campusUri . ?campusUri rdfs:label ?campus }
      }
      LIMIT 20
    </listsparql:select>
</sparql:sparql>
</sparql:lock>

<c:set var="deptUri" value="${param.uri}"/>
<c:set var="deptDescription" value="${dept[0].description.string}"/>
<c:set var="deptLabel" value="${dept[0].deptLabel.string}"/>
<c:set var="deptHeadUri" value="${dept[0].deptHeadUri}"/>
<c:set var="deptHeadLabel" value="${dept[0].deptHeadLabel.string}"/>
<c:set var="linkURL"><str:decodeUrl>${dept[0].primaryLinkURL.string}</str:decodeUrl></c:set>
<c:set var="linkAnchor" value="${dept[0].primaryLinkAnchor.string}"/>

<div id="overview" class="span-15">
    <h2>Department of ${deptLabel}</h2>
    <%-- <div class="description">${deptDescription}</div> --%>

    <%-- display a notice if this is a Weill department --%>
    <%-- <c:forEach items="${dept}" var="row">
        <c:if test="${fn:contains(row.campus.string, 'New York')}">
            <p class="weillNotice"><span>Note:</span> This department is part of Weill Medical College, located at Cornell's New York City campus.</p>
        </c:if>
    </c:forEach> --%>

    <div id="faculty">
        <c:import url="part/faculty_list.jsp">
            <c:param name="type" value="department" />
            <c:param name="uri" value="${deptUri}" />
            <c:param name="deptHead" value="${deptHeadUri}" />
        </c:import>
    </div><!-- deptFaculty -->    
    
</div><!-- overview -->
 
 <div id="sidebar" class="resourceBar span-8 last">
     <h3>Official Web Page</h3>
     <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
         <c:param name="url" value="${linkURL}"/>
         <c:param name="size" value="s"/>
     </c:url>
     <div id="screenshot">
         <a title="official ${deptLabel} page" href="${linkURL}"><img src="${webSnaprUrl}" alt="screenshot of ${linkAnchor}"/></a>
     </div>
     <div class="bottom"></div> <%-- needed to close off the bottom of the sidebar --%>
 </div>
 
<div id="fields" class="section">
    <h3>Life Sciences Fields where these faculty work:</h3>
    <ul class="fields">
        <c:import url="part/fields_list.jsp">
            <c:param name="type" value="department"/>
            <c:param name="uri" value="${deptUri}"/>
        </c:import>
    </ul>
</div><!-- fields -->
