<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:fn="http://java.sun.com/jsp/jstl/functions"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >

<!-- given a graduate field cluster, produce a list of graduate fields with links -->

  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />
    

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs" group="&lt;${param.uri}&gt;">
      <![CDATA[

          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          SELECT DISTINCT ?field ?fieldLabel ?groupLabel
          WHERE
          {

          ?group
          vivo:hasAssociated
          ?field .

          ?field
          vivo:AcademicInitiativeHasOtherParticipantAcademicEmployeeAsFieldMember
          ?person .

          OPTIONAL { ?field rdfs:label ?fieldLabel }
          OPTIONAL { ?group rdfs:label ?groupLabel }
          }
          ORDER BY ?fieldLabel
          LIMIT 200

          ]]>
    </sparql:select>

    <!-- UL tags being added elsewhere -->
      <c:forEach  items="${rs.rows}" var="gradfield">
        <c:set var="classForField" value="${fn:substringAfter(gradfield.field,'#')}"/>
        <c:set var="classForGroup" value="${fn:substringAfter(param.uri,'#')}"/>
            <li class="${classForField}">
                <c:url var="fieldhref" value="fields.jsp">
                    <c:param name="uri" value="${gradfield.field}"/>
                    <c:param name="fieldLabel" value="${gradfield.fieldLabel.string}"/>
                    <c:param name="groupUri" value="${param.uri}"/>
                    <c:param name="groupLabel" value="${gradfield.groupLabel.string}"/>
                    <c:param name="groupClass" value="${classForGroup}"/>       
                </c:url>
                <a href="${fieldhref}">${gradfield.fieldLabel.string}</a>
            </li>
      </c:forEach>

  </sparql:sparql>
</jsp:root>

