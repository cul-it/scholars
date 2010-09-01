<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/" 
          xmlns:listsparql="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/"
          xmlns:rand="http://jakarta.apache.org/taglibs/random-1.0"
          xmlns:fmt="http://java.sun.com/jsp/jstl/fmt"
          xmlns:fn="http://java.sun.com/jsp/jstl/functions"
          version="2.0" >
          
<!-- get some news items for the front of the grad portal -->

<!-- from http://thefigtrees.net/lee/sw/sparql-faq#universal -->

 <!-- 3.6. How can I use SPARQL to query maximum/minimum values or other -->
 <!-- universally quantified criteria? -->
 
 <!-- A combination of the SPARQL OPTIONAL keyword and the bound(...) filter -->
 <!-- function can be used to mimic some universally quantified queries. As -->
 <!-- an example, consider this query which finds the minimum price of every -->
 <!-- book in the underlying default graph: -->
 <!--   PREFIX ex: <http://example.org/> -->
 <!--   SELECT ?book ?minprice -->
 <!--   WHERE { -->
 <!--     ?book a ex:book ; ex:price ?minprice . -->
 <!--     OPTIONAL {  -->
 <!--       ?book ex:price ?otherprice .  -->
 <!--       FILTER( ?otherprice < ?minprice ) . -->
 <!--     } . -->
 <!--     FILTER ( !bound(?otherprice) ) . -->
 <!--   } -->

    <jsp:directive.page import="org.joda.time.DateTime" />
 <jsp:directive.page contentType="text/xml; charset=UTF-8" />
 <jsp:directive.page session="false" />

    <jsp:scriptlet>
        DateTime now = new DateTime();
        request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\""); //tried toString("yyyy-MM-dd'T'HH:mm:ss") + "\"" );
        DateTime thirtyDaysAgo = new DateTime(now.minusDays(30));
        request.setAttribute("thirtyDaysAgo", "\"" + thirtyDaysAgo.toDateTimeISO().toString() + "\"");
    </jsp:scriptlet>

<sparql:lock model="${applicationScope.jenaOntModel}" > 
 <sparql:sparql>
   <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" now="${now}" thirtyDaysAgo="${thirtyDaysAgo}" >
     <![CDATA[

         PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
         PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
         PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
         PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
         PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
         PREFIX vitropublic: <http://vitro.mannlib.cornell.edu/ns/vitro/public#>
         PREFIX hr: <http://vivo.cornell.edu/ns/hr/0.9/hr.owl#>
         PREFIX core: <http://vivoweb.org/ontology/core#>

         SELECT DISTINCT ?news ?newsLabel ?blurb ?sourceLink ?newsThumb
         ?moniker ?sunrise ?featured ?featuredLabel ?firstName ?lastName
         WHERE
         {

         ?news
          rdf:type core:NewsRelease ;
          vitro:sunrise ?sunrise ;
          vitro:blurb ?blurb ;
          rdfs:label ?newsLabel .

         OPTIONAL {
           ?news vitro:primaryLink ?link .
           ?link vitro:linkURL ?sourceLink .
          }

          OPTIONAL {
             ?news vitropublic:mainImage ?mainImage .
             ?mainImage vitropublic:thumbnailImage ?thumbnail .
             ?thumbnail vitropublic:downloadLocation ?downloadLocation .
             LET (?newsThumb := str(?downloadLocation))
          }

          OPTIONAL { ?news vitro:moniker ?moniker }

          OPTIONAL {
            ?news core:features ?featured .

            ?featured rdfs:label ?featuredLabel .
            OPTIONAL {
              ?featured hr:FirstName ?firstName .
              ?featured hr:LastName ?lastName
            }
          }
          FILTER( xsd:dateTime(?now) > ?sunrise )
          FILTER( xsd:dateTime(?thirtyDaysAgo) < ?sunrise )
         }
         ORDER BY ?news DESC(?sunrise)
         LIMIT 15
         

          ]]>
          
    </listsparql:select>

        <rand:number id="random1" range="0-39"/>
        <c:set var="random1"><jsp:getProperty name="random1" property="random"/></c:set>
        
        <rand:number id="random2" range="0-39"/>
        <c:set var="random2"><jsp:getProperty name="random2" property="random"/></c:set>
        
        <c:forEach begin="0" end="100">
            <c:if test="${rs[random1].newsThumb.string == null}">
                <rand:number id="random1" range="0-14"/>
                <c:set var="random1"><jsp:getProperty name="random1" property="random"/></c:set>
            </c:if>
        </c:forEach>
        
        <c:forEach begin="0" end="100">
            <!-- mw542 (9-15-2009): news items can now appear on multiple rows in the result set since multiple people can be featured. testing for this below -->
            <c:if test="${rs[random2].newsThumb.string == null || random1 == random2 || rs[random1].news == rs[random2].news}">
                <rand:number id="random2" range="0-14"/>
                <c:set var="random2"><jsp:getProperty name="random2" property="random"/></c:set>
            </c:if>
        </c:forEach>

        <ul>
            <c:forEach  items="${rs}" var="item" begin="${random1}" end="${random1}">
               <fmt:parseDate var="publishDateTimekey" value="${item.sunrise.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
               <fmt:formatDate var="publishDate" value="${publishDateTimekey}" pattern="MMM'. 'd" />
                <li class="newsitem first">
 					        <c:url var="image" value="${item.newsThumb.string}"/>
                  <a class="image" href="${item.sourceLink.string}"><img width="128" src="${image}" alt="${item.newsLabel.string}"/></a>
                  <h4><a class="externalLink" title="full ${item.moniker.string}" href="${item.sourceLink.string}">${item.newsLabel.string}</a></h4><p>${item.blurb.string}</p>
                  <p class="features">
                    <c:if test="${!empty item.featured}">
                      Features: 
                      <c:url var="entityLink" value="/entity">
                        <c:param name="uri" value="${item.featured}"/>
                      </c:url>
                      <c:choose>
                        <c:when test="${!empty item.firstName.string and !empty item.lastName.string}">
                          <c:set var="featuredName" value="${item.firstName.string} ${item.lastName.string}"/>
                        </c:when>
                        <c:otherwise><c:set var="featuredName" value="${item.featuredLabel.string}"/></c:otherwise>
                      </c:choose>
                      <a href="${entityLink}" title="view profile">${featuredName}</a>
                    </c:if>
                    <em>${publishDate}</em>
                  </p>
                </li>
            </c:forEach>
            <c:forEach  items="${rs}" var="item" begin="${random2}" end="${random2}">
                <fmt:parseDate var="publishDateTimekey" value="${item.sunrise.string}" pattern="yyyy-MM-dd'T'HH:mm:ss" />
                <fmt:formatDate var="publishDate" value="${publishDateTimekey}" pattern="MMM'. 'd" />
                <li class="newsitem clean">
 					        <c:url var="image" value="${item.newsThumb.string}"/>
                  <a class="image" href="${item.sourceLink.string}"><img width="128" src="${image}" alt="${item.newsLabel.string}"/></a>
                  <h4><a class="externalLink" title="full ${item.moniker.string}" href="${item.sourceLink.string}">${item.newsLabel.string}</a></h4><p>${item.blurb.string}</p>
                  <p class="features">
                    <c:if test="${!empty item.featured}">
                      Features: 
                      <c:url var="entityLink" value="/entity">
                        <c:param name="uri" value="${item.featured}"/>
                      </c:url>
                      <c:choose>
                        <c:when test="${!empty item.firstName.string and !empty item.lastName.string}">
                          <c:set var="featuredName" value="${item.firstName.string} ${item.lastName.string}"/>
                        </c:when>
                        <c:otherwise><c:set var="featuredName" value="${item.featuredLabel.string}"/></c:otherwise>
                      </c:choose>
                      <a href="${entityLink}" title="view profile">${featuredName}</a>
                    </c:if>
                    <em>${publishDate}</em>
                  </p>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>
</sparql:lock> 
</jsp:root>
