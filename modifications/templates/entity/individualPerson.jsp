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
Individual entity = (Individual)request.getAttribute("entity");
if (entity == null){
    String e="entityBasic.jsp expects that request attribute 'entity' be set to the Entity object to display.";
    throw new JspException(e);
}

if (VitroRequestPrep.isSelfEditing(request)) { // || LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
    request.setAttribute("showSelfEdits",Boolean.TRUE );
}
%>
<c:if test="${sessionScope.loginHandler != null &&
              sessionScope.loginHandler.loginStatus == 'authenticated' &&
              sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
	<c:set var="showCuratorEdits" value="${true}"/>
</c:if>
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
%>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityPropsListJsp' value='/entityPropList'/>
<c:set var='entityMergedPropsListJsp' value='/entityMergedPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var="themeDir"><c:out value="${portalBean.themeDir}" default="themes/vivo/"/></c:set>

    <jsp:include page="/${themeDir}jsp/dashboard.jsp" flush="true" />

    <div id="content" class="person">
        <c:if test="${showCuratorEdits}"><jsp:include page="entityAdmin.jsp"/></c:if>
        
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
                
                <c:choose>
					<c:when test="${showCuratorEdits || showSelfEdits}">
                		<c:import url="${entityMergedPropsListJsp}">
                			<c:param name="mode" value="edit"/>
                			<c:param name="grouped" value="true"/>
                		</c:import>
                	</c:when>
                	<c:otherwise>
                		<c:import url="${entityMergedPropsListJsp}">
               				<c:param name="grouped" value="true"/>
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
                <c:if test="${!empty entity.keywordString}">
                	<div class="citation">
						<c:choose>
					    	<c:when test="${showKeywordEdits == true}">
					        	<jsp:include page="/${entityKeywordsListJsp}" />
					    	</c:when>
					    	<c:otherwise>
					    		Keywords: ${entity.keywordString}
					    	</c:otherwise>
						</c:choose>
                	</div>
                </c:if>
                ${requestScope.servletButtons} 
        </div>
    </div> <!-- content -->
    <div class="clear"></div>
