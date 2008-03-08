<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
         Display a single Entity in the most basic fashion.
         
         request.attributes:
         an Entity object with the name "entity" 
         
         request.parameters:
         None yet.
         
          Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
          for debugging info.
                 
         bdc34 2006-01-22 created        
        **********************************************/                           
        Individual entity = (Individual)request.getAttribute("entity");
        if (entity == null){
            String e="entityBasic.jsp expects that request attribute 'entity' be set to the Entity object to display.";
            throw new JspException(e);
        }
 %>
<c:set var='imageDir' value='images' />
<%
    //here we build up the url for the larger image.
    String imageUrl = null;
    if (entity.getImageFile() != null && 
        entity.getImageFile().indexOf("http:")==0) {
        imageUrl =  entity.getImageFile();
    } else {
        imageUrl = response.encodeURL( "images/" + entity.getImageFile() );                     
    }

    //anytime we are at an entity page we shouldn't have an editing config or submission
    session.removeAttribute("editjson");
    EditConfiguration.clearAllConfigsInSession(session);
    EditSubmission.clearAllEditSubmissionsInSession(session);
    
    if( VitroRequestPrep.isSelfEditing(request) ) {
            request.setAttribute("showPropEdits","true");
    }
%>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityPropsListJsp' value='/entityPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>

    <div id="dashboard">
        <c:if test="${!empty entity.imageThumb}">
            <c:if test="${!empty entity.imageFile}">
                    <c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
                    <a class="image" href="${imageUrl}">
            </c:if>
            <c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
            <img class="headshot" src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
            <c:if test="${!empty entity.imageFile}"></a></c:if>
            <c:if test="${!empty entity.citation}">
                <div class="citation">
                    ${entity.citation}
                </div>
            </c:if>
        </c:if>
        
        <ul class="profileLinks">
            <c:if test="${!empty entity.anchor}">
                <c:choose>
                    <c:when test="${!empty entity.url}">
                        <c:url var="entityUrl" value="${entity.url}" />
                        <li><a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a></li>
                    </c:when>
                    <c:otherwise>
                        <li>${entity.anchor}</li>
                    </c:otherwise>
                </c:choose>
            </c:if>
        
            <c:if test="${!empty entity.linksList }">
                <c:forEach items="${entity.linksList}" var='link'>
                    <c:url var="linkUrl" value="${link.url}" />
                    <li><a class="externalLink" href="<c:out value="${linkUrl}"/>">${link.anchor}</a></li>
                </c:forEach>
            </c:if>
        </ul>
    </div> <!-- dashboard -->