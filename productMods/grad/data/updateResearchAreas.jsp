<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ include file="../part/resources.jsp" %>

<c:catch var="pageError">

<c:if test="${param.showall == 'true'}">

    <div class="description span-14">
        <p>This page lets you identify Graduate Fields that involve specific types of research. You can also find out which faculty are conducting that research.</p>
        <p>Try selecting an area from the list. Select more than one to find faculty conducting unique combinations of research.</p>
        <noscript><p><strong>NOTE: To select multiple areas you need to enable JavaScript in your browser.</strong></p></noscript>
    </div>
    
</c:if>

<c:if test="${param.showall != 'true' && !empty param.areas}">

    <c:set var="areaParams" value="${param.areas}"/>
    <c:set var="areaParams" value="${param.areas}"/>
    
    <c:set var="areaList" value="${fn:split(areaParams,',')}"/>
    
    <c:choose>
        <c:when test="${!empty areaList[0]}"><c:set var="area1" value="${namespace}${areaList[0]}"/></c:when>
        <c:otherwise><c:set var="area1" value="${namespace}${param.uri}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[1]}"><c:set var="area2" value="${namespace}${areaList[1]}"/></c:when>
        <c:otherwise><c:set var="area2" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[2]}"><c:set var="area3" value="${namespace}${areaList[2]}"/></c:when>
        <c:otherwise><c:set var="area3" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[3]}"><c:set var="area4" value="${namespace}${areaList[3]}"/></c:when>
        <c:otherwise><c:set var="area4" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[4]}"><c:set var="area5" value="${namespace}${areaList[4]}"/></c:when>
        <c:otherwise><c:set var="area5" value="${area1}"/></c:otherwise>
    </c:choose>
    <c:choose>
        <c:when test="${!empty areaList[5]}"><c:set var="area6" value="${namespace}${areaList[5]}"/></c:when>
        <c:otherwise><c:set var="area6" value="${area1}"/></c:otherwise>
    </c:choose>

        <sparql:lock model="${applicationScope.jenaOntModel}">
         <sparql:sparql>
                 <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" area1="<${area1}>" area2="<${area2}>" area3="<${area3}>" area4="<${area4}>" area5="<${area5}>" area6="<${area6}>">
                   PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
                   PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                   PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                   PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                   PREFIX core: <http://vivoweb.org/ontology/core#>
                   SELECT DISTINCT ?fieldUri ?fieldLabel (count(DISTINCT ?personUri) AS ?count)
                   WHERE {
                     ?area1 core:researchAreaOf ?personUri .
                     ?personUri core:hasResearchArea ?area2 .
                     ?personUri core:hasResearchArea ?area3 .
                     ?personUri core:hasResearchArea ?area4 .
                     ?personUri core:hasResearchArea ?area5 .
                     ?personUri core:hasResearchArea ?area6 .
                     ?personUri vivo:memberOfGraduateField ?fieldUri .
                     ?fieldUri vivo:associatedWith ?groupUri .
                     ?groupUri rdf:type vivo:fieldCluster .
                     OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
                     OPTIONAL { ?personUri vitro:moniker ?moniker }
                    FILTER (!regex(?moniker, "emeritus", "i"))
                   }
                    GROUP BY ?fieldUri ?fieldLabel
                    ORDER BY desc(?count)
                    LIMIT 1000
                 </listsparql:select>
         </sparql:sparql>
         </sparql:lock>
         
         <c:if test="${!empty rs[0].fieldUri}">
         
             <c:choose>
                 <c:when test="${param.showfaculty == 'yes'}"><c:set var="visibility" value="show"/></c:when>
                 <c:when test="${param.showfaculty == 'no'}"><c:set var="visibility" value="hide"/></c:when>
                 <c:otherwise><c:set var="visibility" value="hide"/></c:otherwise>
             </c:choose>
         
             <div class="headingBox">
                 <h3>Applicable Graduate Fields</h3>
                 <c:if test="${param.showfaculty == 'no'}">
                     <p><a class="toggle showThem" href="/researchareas/${areaList[0]}/showfaculty">Show faculty</a></p>
                 </c:if>
                 <c:if test="${param.showfaculty == 'yes'}">
                     <p><a class="toggle hideThem" href="/researchareas/${areaList[0]}">Hide faculty</a></p>
                 </c:if>
             </div>
 
                 <ul class="fieldList">
                     <c:forEach items="${rs}" var="row">
                         <c:if test="${row.fieldUri != thisField}">
                             <c:set var="thisField" value="${row.fieldUri}"/>
                                 <c:set var="fieldID" value="${fn:substringAfter(row.fieldUri,'/individual/')}"/>
                                 <li class="${fieldID}">
                                        <h4 class="fields"><a href="/fields/${fieldID}">${row.fieldLabel.string}</a></h4>
                                        <c:import url="../part/faculty_list.jsp">
                                            <c:param name="type" value="multiArea"/>
                                            <c:param name="field" value="${row.fieldUri}"/>
                                            <c:param name="visibility" value="${visibility}"/>
                                            <c:param name="area1" value="${area1}"/>
                                            <c:param name="area2" value="${area2}"/>
                                            <c:param name="area3" value="${area3}"/>
                                            <c:param name="area4" value="${area4}"/>
                                            <c:param name="area5" value="${area5}"/>
                                            <c:param name="area6" value="${area6}"/>
                                        </c:import>
                                 </li>
                         </c:if>
                     </c:forEach>
                 </ul>
        </c:if>
        
        <c:if test="${empty rs[0].fieldUri}">
            <%-- <div class="headingBox">
                <h3>Applicable Graduate Fields</h3>
                <c:if test="${param.showfaculty == 'no'}">
                    <p></p>
                </c:if>
                <c:if test="${param.showfaculty == 'yes'}">
                    <p></p>
                </c:if>
            </div> --%>
            <div class="headingBox">
                <h3>Applicable Graduate Fields</h3>
            </div>
            <p class="description">No matches for that combination &mdash; <a class="undo" href="#">undo</a>?</p>
        </c:if>
</c:if>     

</c:catch>
<c:if test="${!empty pageError}">${pageError}</c:if>

