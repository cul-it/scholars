<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

<c:if test="${!empty param.uri}">
  <sparql:lock model="${applicationScope.jenaOntModel}">
   <sparql:sparql>
           <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" countryUri="<${param.uri}>">
             PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
             PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
             PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
             PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
             PREFIX core: <http://vivoweb.org/ontology/core#>
             SELECT DISTINCT ?countryUri ?name ?personUri ?personLabel ?image ?moniker ?deptLabel
             WHERE {
               SERVICE <http://sisler.mannlib.cornell.edu:8081/openrdf-sesame/repositories/courses2> {
                 ?countryUri rdf:type core:Country .
                 ?countryUri rdfs:label ?name .
                 ?countryUri vivo:internationalResearchAreaFor ?personUri .
                 ?personUri rdfs:label ?personLabel .
                 OPTIONAL { ?personUri vitro:imageThumb ?image }
                 OPTIONAL { ?personUri vitro:moniker ?moniker }
               }
             }
              ORDER BY ?personLabel
              LIMIT 1000
           </listsparql:select>
   </sparql:sparql>
   </sparql:lock>
 
 <html lang="en">
 <head>
 	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
 	<title>People by Country</title>
 	
 	<style type="text/css">
 	  body, ul, li, p {
 	    margin: 0;
 	    padding: 0;
 	  }
 	  
 	  body {
 	    background: #fff;
 	    position: relative;
 	    font-family: Helvetica, Arial, sans-serif;
 	  }

 	  .countryName {
 	    font-family: Georgia, Times, serif;
 	    display: block
 	    font-size: 18px;
 	    background: #777777;
 	    color: #fff;
 	    padding: 8px;
 	    text-transform: uppercase;
 	  }
 	  ul {
 	    margin: 20px 0;
 	    padding: 0;
 	  }
 	  li {
 	    position: relative;
 	    height: 50px;
 	    list-style-type: none;
 	    margin: 0 20px 10px 20px;
      padding: 0;
      font-size: 14px;
      color: #999;
      overflow: hidden;
 	  }
 	  li a.image {
 	    position: absolute;
 	    top: 0;
 	    left: 0;
 	  }
 	  li p, li em {
 	    display: block;
 	    margin-left: 53px;
 	    margin-top: 4px;
 	  }
 	  li em { font-size: 13px; }
 	  a {color: #0080AE}
 	</style>
 </head>
 
 <body>
     
  <c:if test="${!empty param.country}">
    <h4 class="countryName">${param.country}</h4>
  </c:if>
   <ul>
   <c:forEach var="row" items="${rs}">
    <c:if test="${lastPerson != row.personUri}">
      <c:set var="lastPerson" value="${row.personUri}"/>
      
      <%-- Build an image URL --%>
      <c:choose>
        <c:when test="${!empty row.image.string}">
          <c:set var="imageURL" value="http://vivo.cornell.edu/images/${row.image.string}"/>
        </c:when>
        <c:otherwise>
          <c:set var="imageURL" value="http://gradeducation.lifesciences.cornell.edu/resources/images/profile_missing.gif"/>
        </c:otherwise>
      </c:choose>
      
      <%-- Build a VIVO URL --%>
      <c:url var="vivoURL" value="http://vivo.cornell.edu/entity"><c:param name="uri" value="${row.personUri}"/></c:url>
      
      <li>
        <a class="image" target="_blank" title="open vivo profile" href="${vivoURL}"><img width="40" src="${imageURL}"/></a>
        <p><a target="_blank" title="open vivo profile" href="${vivoURL}">${row.personLabel.string}</a></p>
        <em>${row.moniker.string}</em>
      </li>
    </c:if>
    </c:forEach>
    </ul>
</c:if>
         
</body>
</html>

