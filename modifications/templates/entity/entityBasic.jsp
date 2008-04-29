<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.entity.entityBasic.jsp");
%>
<%
log.debug("Starting entityBasic.jsp");
Individual entity = (Individual)request.getAttribute("entity");
if (entity == null){
    String e="entityBasic.jsp expects that request attribute 'entity' be set to the Entity object to display.";
    throw new JspException(e);
}

if (VitroRequestPrep.isSelfEditing(request) || LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
    request.setAttribute("showSelfEdits",Boolean.TRUE);
}%>
<c:if test="${sessionScope.loginHandler != null &&
              sessionScope.loginHandler.loginStatus == 'authenticated' &&
              sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
    <c:set var="showCuratorEdits" value="${true}"/>
</c:if>
<c:set var='imageDir' value='images' />
<c:set var="themeDir"><c:out value="${portalBean.themeDir}" default="themes/vivo/"/></c:set>
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
    
    if (VitroRequestPrep.isSelfEditing(request) || LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) { %>
    	<jsp:include page="/templates/entity/individualPerson.jsp" flush="true"/>
<%      return;
	}
    List<VClass> vclasses=entity.getVClasses(false);
    for(VClass clas: vclasses) {
        //System.out.println(clas.getURI());
        if ( "http://www.aktors.org/ontology/portal#Person".equals(clas.getURI()) ) {
            %><jsp:include page="/templates/entity/individualPerson.jsp" flush="true"/><%
            return;
        }
    }
%>

<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityMergedPropsListJsp' value='/entityMergedPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:choose>
    <c:when test="${showPropEdits == true}"><!-- set in basicPage.jsp only for self-editing  -->
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/editdefault/'/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
    </c:otherwise>
</c:choose>

    <div id="content">
        <jsp:include page="entityAdmin.jsp"/> 
        
        <div class='contents entity'>
                <h2>${entity.name}</h2> 
                <c:choose>
                    <c:when test="${!empty entity.moniker}">
                        <em class="moniker">${entity.moniker}</em>
                    </c:when>
                    <c:otherwise>
                        <em class="moniker">${vclassName}</em>
                    </c:otherwise>
                </c:choose>
                <ul class="externalLinks">
                <c:if test="${!empty entity.anchor}">
                    <c:choose>
                        <c:when test="${!empty entity.url}">
                            <c:url var="entityUrl" value="${entity.url}" />
                            <li class="first"><a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a></li>
                        </c:when>
                        <c:otherwise>
                            <li class="first"><span class="externalLink">${entity.anchor}</span></li>
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
                 
                <c:if test="${!empty entity.imageThumb}">
                    <div class="thumbnail">
                        <c:if test="${!empty entity.imageFile}">
                            <c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
                            <a class="image" href="${imageUrl}">
                        </c:if>
                        <c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
                       <img src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
                       <c:if test="${!empty entity.imageFile}"></a></c:if>
                    </div>
                    <c:if test="${!empty entity.citation}">
                        <div class="citation">${entity.citation}</div>
                    </c:if>
                </c:if>
                
                <c:choose>
                    <c:when test="${showCuratorEdits || showSelfEdits}">
                        <c:import url="${entityMergedPropsListJsp}">
                            <c:param name="mode" value="edit"/>
                            <c:param name="grouped" value="false"/>
                        </c:import>
                    </c:when>
                    <c:otherwise>
                        <c:import url="${entityMergedPropsListJsp}">
                            <c:param name="grouped" value="false"/>
                        </c:import>
                    </c:otherwise>
                </c:choose>
                <p/>
                
                <div class='description'>
                  ${entity.blurb}
                </div>
                <div class='description'>
                  ${entity.description}
                </div>
                <c:if test="${(!empty entity.citation) && (empty entity.imageThumb)}">
                    <div class="citation">
                        ${entity.citation}
                    </div>
                </c:if>
                <div class="citation">
                <c:choose>
                    <c:when test="${showKeywordEdits == true}">
                        <jsp:include page="/${entityKeywordsListJsp}" />
                    </c:when>
                    <c:otherwise>
                        <c:if test="${!empty entity.keywordString}">
                            Keywords: ${entity.keywordString}
                        </c:if>
                    </c:otherwise>
                </c:choose>
                </div>
                ${requestScope.servletButtons}
        </div>
    </div> <!-- content -->