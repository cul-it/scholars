<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<%@ page errorPage="/error.jsp"%>
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.entity.singularEvent.jsp");
%>
<%
log.debug("Starting singularEvent.jsp");
Individual entity = (Individual)request.getAttribute("entity");

VitroRequest vreq = new VitroRequest(request);
WebappDaoFactory wdf = vreq.getWebappDaoFactory();
%>

<c:if test="${!empty entityURI}">
	<c:set var="myEntityURI" scope="request" value="${entityURI}"/>
<%
	try {
		entity = wdf.getIndividualDao().getIndividualByURI((String)request.getAttribute("myEntityURI"));
		System.out.println("singularEvent rendering "+entity.getURI());
	} catch (Exception e) {
		e.printStackTrace();
	}
	%>
</c:if>

<% 

if (entity == null){
    String e="singularEvent.jsp expects that request attribute 'entity' be set to the Entity object to display.";
    throw new JspException(e);
}

if (VitroRequestPrep.isSelfEditing(request) || LoginFormBean.loggedIn(request, LoginFormBean.EDITOR) /* minimum level*/) {
    request.setAttribute("showSelfEdits",Boolean.TRUE);
}

//DataProperty monikerDataProp = wdf.getDataPropertyDao().getDataPropertyByURI("http://vitro.mannlib.cornell.edu/ns/vitro/0.7#moniker");
//if (monikerDataProp != null) {
//    List <DataPropertyStatement> monikerList = wdf.getDataPropertyStatementDao().getDataPropertyStatements(monikerDataProp);
//    if (monikerList!=null && monikerList.size()>0) {
//        for (DataPropertyStatement dp : monikerList) {%>
<%--          <c:set var="monikerDataPropertyStmt" value="<%=dp%>"/> --%>
<%//	  }
//    }
//}
%>
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
        imageUrl = response.encodeURL( "/images/" + entity.getImageFile() );                     
    }

    //anytime we are at an entity page we shouldn't have an editing config or submission
    session.removeAttribute("editjson");
    EditConfiguration.clearAllConfigsInSession(session);
    EditSubmission.clearAllEditSubmissionsInSession(session);
%>

<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityMergedPropsListJsp' value='/entityMergedPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>

<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>

    <div id="content">
        <jsp:include page="entityAdmin.jsp"/> 
        
        <div class='contents entity'>
       		<div id="label">
                <h2><p:process>${entity.name}</p:process></h2>
                <c:if test="${!empty entity.moniker}">
                    <p:process><em class="moniker">${entity.moniker}</em></p:process>
<%--    			<c:if test="${showSelfEdits || showCuratorEdits}">
				    	<edLnk:editLinks item="${monikerDataPropertyStmt}" icons="false"/>                                                       
	        		</c:if> --%>
                </c:if>
            </div><!-- entity label -->
            <c:choose>
                <c:when test="${!empty entity.timekey}">
                    <fmt:parseDate var="eventDateTime" value="${entity.timekey}" pattern="EEE MMM dd HH:mm:ss ZZZ yyyy" parseLocale="en_US"/>
                    <fmt:formatDate var="anchorText" value="${eventDateTime}" type="both" dateStyle="full" timeStyle="short"/>
                </c:when>
                <c:otherwise>
                	<c:set var="anchorText" value="${entity.anchor}"/>
                </c:otherwise>
            </c:choose>
            <c:if test="${ (!empty anchorText) || (!empty entity.linksList) }">
                <ul class="externalLinks">
                	<c:if test="${!empty anchorText}">
			            <c:choose>
	                        <c:when test="${!empty entity.url}">
	                            <c:url var="entityUrl" value="${entity.url}" />
	                            <li class="first"><a class="externalLink" href="<c:out value="${entityUrl}"/>"><p:process>${anchorText}</p:process></a></li>
	                        </c:when>
	                        <c:otherwise>
	                            <li class="first"><span class="externalLink"><p:process>${anchorText}</p:process></span></li>
	                        </c:otherwise>
		                </c:choose>
		            </c:if>
                    <c:if test="${!empty entity.linksList }">
	                    <c:forEach items="${entity.linksList}" var='link'>
	                        <c:url var="linkUrl" value="${link.url}" />
	                        <li><a class="externalLink" href="<c:out value="${linkUrl}"/>"><p:process>${link.anchor}</p:process></a></li>
	                    </c:forEach>
	                </c:if>
                </ul>
	        </c:if>   
            <c:if test="${!empty entity.imageThumb}">
                <div class="thumbnail">
                    <c:if test="${!empty entity.imageFile}">
                        <c:url var="imageUrl" value="/${imageDir}/${entity.imageFile}" />
                        <a class="image" href="${imageUrl}">
                    </c:if>
                    <c:url var="imageSrc" value='/${imageDir}/${entity.imageThumb}'/>
                    <img src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
                    <c:if test="${!empty entity.imageFile}"></a></c:if>
                </div>
                <c:if test="${!empty entity.citation}">
                    <div class="citation">${entity.citation}</div>
                </c:if>
            </c:if>
            <p:process>
                <div class='blurb'>${entity.blurb}</div>
                <div class='description'>${entity.description}</div>
            </p:process>
            <c:choose>
                <c:when test="${showCuratorEdits || showSelfEdits}">
                     <c:import url="${entityMergedPropsListJsp}">
                         <c:param name="mode" value="edit"/>
                         <c:param name="grouped" value="false"/>
                         <%-- unless a value is provided, properties not assigned to a group will not have a tab or appear on the page --%>
                         <c:param name="unassignedPropsGroupName" value=""/>
                     </c:import>
                 </c:when>
                 <c:otherwise>
                     <c:import url="${entityMergedPropsListJsp}">
                         <c:param name="grouped" value="false"/>
                         <%-- unless a value is provided, properties not assigned to a group will not have a tab or appear on the page --%>
                         <c:param name="unassignedPropsGroupName" value=""/>
                     </c:import>
                 </c:otherwise>
            </c:choose>
            <p/>
            <p:process>
                <c:if test="${(!empty entity.citation) && (empty entity.imageThumb)}">
                    <div class="citation">${entity.citation}</div>
                </c:if>
                <c:if test="${!empty entity.keywordString}">
               	    <div class="citation">
				        <a href="#keywords"/>
				        Keywords: ${entity.keywordString}
               	    </div>
                </c:if>
            </p:process>
            ${requestScope.servletButtons}
        </div>
    </div> <!-- content -->
