<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%><%/* this odd thing points to something in web.xml */ %>
<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
        Display a list of entities for a tab.

         request.attributes:
         a List of Entity objects with the name "entities"
         portal id as "portal"

         request.parameters:
         None yet.

          Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output for debugging info.

         bdc34 2006-01-27 created
    **********************************************/
        if (request.getAttribute("entities") == null){
            String e="entityListForTabs.jsp expects that request attribute 'entities' be set to a List of Entity objects.";
            throw new JspException(e);
        }
%>
<c:set var='entities' value='${requestScope.entities}' /><%/* just moving this into page scope for easy use */ %>
<c:set var='portal' value='${requestScope.portal}' />
<c:set var='IMG_DIR' value='images/' />
<c:set var='IMG_WIDTH' value='100'/>
<jsp:include page="/templates/alpha/alphaIndex.jsp"/>
<ul class='tabEntities entityListForTab'>
    <c:forEach items='${entities}' var='ent'>
	<c:url var="entHref" value="entity">
		<c:param name="home" value="${sessionScope.currentPortalId}"/>
		<c:param name="uri" value="${ent.URI}"/>
	</c:url>
        <li><a href='<c:out value="${entHref}"/>'>${ent.name}</a> | <c:out value="${ent.moniker}"/> 
            <c:if test="${!empty ent.anchor}"> |
                <c:choose>
                    <c:when test="${!empty ent.url}">
	                    <c:url var="entUrl" value="${ent.url}"/>
                        <a class="externalLink" href="<c:out value="${entUrl}"/>">${ent.anchor}</a>
                    </c:when>
                    <c:otherwise>
                        <i>${ent.anchor}</i>
                    </c:otherwise>
                </c:choose>
            </c:if>
            <c:forEach items='${ent.linksList}' var="entLink"> | <c:url var="entLinkUrl" value="${entLink.url}"/><a class="externalLink" href="<c:out value="${entLinkUrl}"/>">${entLink.anchor}</a></c:forEach>
            <c:choose>
            <c:when test='${not empty ent.imageThumb }'>
                <table style="table-layout:auto;width:auto;"><tr>
                	<!-- the c:url tag must have parameters to do URLEncoding -->
                	<c:url var="imageHref" value="entity">
						<c:param name="home" value="${sessionScope.currentPortalId}"/>
						<c:param name="uri" value="${ent.URI}"/>
					</c:url>
                	<c:url var="imageSrc" value="${IMG_DIR}${ent.imageThumb}"/>
                    <td><a class="image" href="<c:out value="${imageHref}"/>"><img width="${IMG_WIDTH}" src="<c:out value="${imageSrc}"/>" title="${ent.name}" alt="" /></a></td>
                    <c:if test="${not empty ent.blurb}"><td><div class='blurb'>${ent.blurb}</div></td></c:if>
                </tr></table>
            </c:when>
            <c:otherwise>
                <c:if test="${not empty ent.blurb}"><div class='blurb'>${ent.blurb}</div></c:if>
            </c:otherwise>
            </c:choose>
        </li>
    </c:forEach>
</ul>


