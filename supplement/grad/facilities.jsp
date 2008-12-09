<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="facilities"/>
    <jsp:param name="titleText" value="Research Facilities | Cornell University"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">

                <h2>Research Facilities</h2>
                <em class="subhead">A selection of the various equipment, services and labs that support Life Sciences research at Cornell</em>
                
                <%-- querying for individuals here (without selecting) to leave out tabs with no individuals --%>
                <sparql:lock model="${applicationScope.jenaOntModel}" >
                <sparql:sparql>
                  <listsparql:select model="${applicationScope.jenaOntModel}" var="facilitiesTab">
                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
                    PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
                    SELECT DISTINCT ?facGroup ?facGroupLabel
                    WHERE
                    {
                    ?facGroup
                    vitro:subTabOf
                    vivo:tab1441173947 . 

                    ?tabConnector
                    vitro:involvesTab
                    ?facGroup .

                    ?tabConnector
                    vitro:involvesIndividual
                    ?facility .

                    OPTIONAL { ?facGroup rdfs:label ?facGroupLabel }
                    }
                    ORDER BY ?facGroupLabel
                    LIMIT 200
                  </listsparql:select>
                 </sparql:sparql>
                 </sparql:lock>
                
                    <ul>
                        <c:forEach  items="${facilitiesTab}" var="rs">
                        <str:replace replace="/" with="" var="className">${rs.facGroupLabel.string}</str:replace>
                        <str:replace replace=" " with="" var="className">${className}</str:replace>
                        <str:replace replace="," with="" var="className">${className}</str:replace>
                        <li id="${className}">
                            <h3 class="facilityGroup">${rs.facGroupLabel.string}</h3>
                                <c:import url="part/getfacilities.jsp">
                                    <c:param name="group" value="${rs.facGroup}"/>
                                </c:import>
                        </li>
                        </c:forEach>
                    </ul>
                          
            </div><!-- content -->

        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />