<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

<!-- given a graduate field , produce a list of people in the field with links -->

  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />
    

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs"
            field="&lt;${param.uri}&gt;">
      <![CDATA[

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
              SELECT DISTINCT ?person ?personLabel
              WHERE
              {
              ?person vivo:AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative ?field
              OPTIONAL { ?person rdfs:label ?personLabel }
              }
              ORDER BY ?personLabel
              LIMIT 2000

          ]]>
    </sparql:select>


        <ul>
            <c:forEach  items="${rs.rows}" var="person">
                <li>
                    <c:url var="href" value="/entity"><c:param name="uri" value="${person.person}"/></c:url>
                    <a href="${href}">${person.personLabel.string}</a>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>

</jsp:root>
