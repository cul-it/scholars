<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          xmlns:listsparql="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/"
          xmlns:rand="http://jakarta.apache.org/taglibs/random-1.0"
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
        request.setAttribute("now", "\"" + now.toDateTimeISO().toString() + "\"" );
    </jsp:scriptlet>

 <sparql:sparql>
   <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" now="${now}" >
     <![CDATA[

         PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
         PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
         PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
         PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
         PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
         SELECT DISTINCT ?news ?newsLabel ?blurb ?sourceLink ?newsThumb ?moniker
         WHERE
         {

         ?group
         rdf:type
         vivo:fieldCluster .

         ?group
         vivo:hasAssociated
         ?field .

         ?field
         vivo:AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember
         ?person .

         ?news
           vivo:featuresPerson2 ?person ;
           vitro:sunrise ?sunrise ;
           vitro:primaryLink ?link ;
           vitro:blurb ?blurb ;
           rdfs:label ?newsLabel .

           ?link vitro:linkURL ?sourceLink .

          OPTIONAL { ?news vitro:imageThumb ?newsThumb }
      
          OPTIONAL { ?news vitro:moniker ?moniker }
      
          FILTER( xsd:dateTime(?now) > ?sunrise )
         }
         ORDER BY DESC(?sunrise)
         LIMIT 40

          ]]>
          
    </listsparql:select>
    
        

        <rand:number id="random1" range="0-39"/>
        <c:set var="random1"><jsp:getProperty name="random1" property="random"/></c:set>
        
        <rand:number id="random2" range="0-39"/>
        <c:set var="random2"><jsp:getProperty name="random2" property="random"/></c:set>
        
        <c:forEach begin="0" end="100">
            <c:if test="${rs[random1].newsThumb.string == null}">
                <rand:number id="random1" range="0-39"/>
                <c:set var="random1"><jsp:getProperty name="random1" property="random"/></c:set>
            </c:if>
        </c:forEach>
        
        <c:forEach begin="0" end="100">
            <c:if test="${rs[random2].newsThumb.string == null || random1 == random2 }">
                <rand:number id="random2" range="0-39"/>
                <c:set var="random2"><jsp:getProperty name="random2" property="random"/></c:set>
            </c:if>
        </c:forEach>

        <ul>
            <c:forEach  items="${rs}" var="item" begin="${random1}" end="${random1}">
                <li>
                  
 					<c:url var="image" value="/images/${item.newsThumb.string}"/>
                  <a href="full ${item.moniker.string}"><img width="128" src="${image}" alt="${item.newsLabel.string}"/></a><a title="full ${item.moniker.string}" href="${item.sourceLink.string}">${item.newsLabel.string}</a>
                </li>
            </c:forEach>
            <c:forEach  items="${rs}" var="item" begin="${random2}" end="${random2}">
                <li class="clean">
                  
 					<c:url var="image" value="/images/${item.newsThumb.string}"/>
                  <a href="full ${item.moniker.string}"><img width="128" src="${image}" alt="${item.newsLabel.string}"/></a><a title="full ${item.moniker.string}" href="${item.sourceLink.string}">${item.newsLabel.string}</a>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>

</jsp:root>
