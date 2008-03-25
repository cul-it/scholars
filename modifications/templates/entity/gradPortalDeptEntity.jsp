<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
     Display a single Department Entity for the grad portal.

     request.attributes:
     an Entity object with the name "entity"
     **********************************************/
    Individual entity = (Individual)request.getAttribute("entity");
    if (entity == null)
        throw new JspException("gradPortalDeptEntity.jsp expects that request attribute 'entity' be set to the Entity object to display.");
%>
<c:set var='financialAwardPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward' scope="page" />

<c:set var='hasFacultyPropUri'     value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasLeadParticipantPerson' scope="page"/>
<c:set var='sponsorsSeriesPropUri' value='http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet' scope="page"/>

<c:set var='hasCoursePropUri'      value='' scope="page"/>

<c:set var='imageDir' value='images' scope="page"/>
    <div id='content'>
        <jsp:include page="entityAdmin.jsp"/>
        <div class='contents entity'>
            Department of
            <h2>${entity.name}</h2>
            <div> ${entity.description}</div>

            <div class='thumbnail'>
                <c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
                <img src='<c:out value="${imageSrc}"/>"' title="image of ${entity.name} webapge" alt="" width="150"/>
                <a href="<c:url value='${entity.url}'/>">${entity.name} web page </a>
            </div>

            <div>
                Headed by
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorHasLeadParticipantPerson"].objectPropertyStatements}'
                           var="headPerson">
                    <li>${headPerson.object.name}</li>
                </c:forEach>
                </ul>

                Located in
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorLocatedInFacility"].objectPropertyStatements}' var="location">
                     <li>${location.object.name}</li>
                </c:forEach>
                </ul>

                Sponsors series
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorSponsorOfAssociatedEnumeratedSet"].objectPropertyStatements}' var="series">
                    <li>${series.object.name}</li>
                </c:forEach>
                </ul>

                Part of graduate fields
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#kdkdkdkdkddk"].objectPropertyStatements}' var="gfield">
                    <li>${gfield.object.name}</li>
                </c:forEach>
                </ul>

                Administers Projects
                 <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#OrganizedEndeavorAdministersFinancialAward"].objectPropertyStatements}' var="project">
                    <li>${project.object.name}</li>
                </c:forEach>
                </ul>


            <div>
                 Faculty
                <ul>
                <c:forEach items='${entity.objectPropertyMap["http://vivo.library.cornell.edu/ns/0.1#CornellFacultyMemberInOrganizedEndeavorac"].objectPropertyStatements}' var="Faculty">
                    <li>${Faculty.object.name}</li>
                </c:forEach>
                </ul>
            </div>

            <%--<div>--%>
                 <%--Courses--%>
                <%--<ul>--%>
                <%--<c:forEach items='${entity.objectPropertyMap["${hasCoursePropUri}"].objetPropertyStatements}}' var="project">--%>
                    <%--<li>${headPerson.name}</li>--%>
                <%--</c:forEach>--%>
                <%--</ul>--%>
            <%--</div>--%>

        </div> <!-- content -->
<%!
        private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }

%>