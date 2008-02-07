<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

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
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
              SELECT DISTINCT ?talkUri ?blurb ?label
              WHERE
              {
              ?person
              vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative
              ?field .

              ?field rdf:type vivo:GraduateField .

              ?person
              vivo:CornellFacultyMemberInOrganizedEndeavor
              ?dept .

              ?dept rdf:type vivo:AcademicDepartment .

              ?dept 
              vivo:OrganizedEndeavorSponsorOfAssociatedEnumeratedSet
              ?seminar.

              ?seminar
              vivo:seminarOrLectureSeriesHasMemberTalk
              ?talkUri .

              ?talkUri
                vitro:timekey ?timekey ;
                vitro:sunrise ?sunrise ;
                vitro:blurb   ?blurb ;
                rdfs:label ?label.

               FILTER( xsd:dateTime(?now) > ?sunrise  && xsd:dateTime(?now) < ?timekey )
              }
              ORDER BY ?timekey
              LIMIT 2

          ]]>
    </sparql:select>


        <ul>
            <c:forEach  items="${rs.rows}" var="talk">
                <li>                  
                  <c:url var="href" value="/entity"><c:param name="uri" value="${talk.talkUri}"/></c:url>
                  <a href="${href}">${talk.label.string}</a>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>

</jsp:root>
