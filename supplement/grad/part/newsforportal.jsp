<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
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
   <sparql:select model="${applicationScope.jenaOntModel}" var="rs"
         now="${now}" >
     <![CDATA[

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
              SELECT DISTINCT ?news ?newsLabel ?newsThumb
              WHERE
              {
              ?news
                <http://vivo.library.cornell.edu/ns/0.1#featuresPerson> ?person ;
                <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#timekey> ?timekey ;
                <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#sunrise> ?sunrise ;
                <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#imageThumb> ?newsThumb;
                rdfs:label ?newsLabel .
                
              ?person
              <http://vivo.library.cornell.edu/ns/0.1#AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative>
              ?field .

              ?field 
              rdf:type
              <http://vivo.library.cornell.edu/ns/0.1#GraduateField> .

               FILTER( xsd:dateTime(?now) > ?sunrise )
              }
              ORDER BY DESC(?timekey)
              LIMIT 2

          ]]>
    </sparql:select>


        <ul>
            <c:forEach  items="${rs.rows}" var="item">
                <li>
                    
                  <c:url var="href" value="/entity"><c:param name="uri" value="${item.news}"/></c:url>
 					<c:url var="image" value="/images/${item.newsThumb.string}"/>
                  <img src="${image}"/>
                  <a href="${href}">${item.newsLabel.string}</a>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>

</jsp:root>
