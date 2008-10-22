<%@ page import="java.util.*, java.text.*, jr.beans.examples.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ page contentType="text/xml" %>


<sparql:sparql>
<listsparql:select model="${applicationScope.jenaOntModel}" var="allFields">
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
    SELECT DISTINCT ?fieldUri ?fieldLabel ?id
    WHERE
    {

    ?group
    rdf:type vivo:fieldCluster ;
    vivo:hasAssociated ?fieldUri .

    ?fieldUri
    vivo:AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember
    ?person .
    
    ?fieldUri vivo:gradschoolID ?id .

    OPTIONAL { ?fieldUri rdfs:label ?fieldLabel }
    }
    ORDER BY ?fieldLabel
    LIMIT 100
</listsparql:select>
</sparql:sparql>

<?xml version="1.0" encoding="UTF-8" ?> 

    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
            <atom:link href="http://worthington.mannlib.cornell.edu/grad/data/dapperRSS.jsp" rel="self" type="application/rss+xml" />
              <title>List of IDs for Field Details Dapp</title>
              <link>http://worthington.mannlib.cornell.edu/grad/data/dapperRSS.jsp</link>
              <description>IDs for a Dapp that scrapes the Graduate School site</description>
              <language>en</language>
            
            <c:forEach items="${allFields}" var="field">
                <c:set var="localname" value="${fn:substringAfter(field.fieldUri,'#')}"/>
                <item>
                    <title>${field.fieldLabel.string}</title>
                    <description>${field.id.string}</description>
                    <link>http://gradeducation.lifesciences.cornell.edu/fields/${localname}</link>
                    <guid>${field.fieldUri}</guid>
                </item>
            </c:forEach>

        </channel>
    </rss>