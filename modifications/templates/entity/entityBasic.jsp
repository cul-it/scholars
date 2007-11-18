<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%	/***********************************************
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
%>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityPropsListJsp' value='/entityPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>

		<div class='contents entity entity${entity.URI}'>
				<h1>${entity.name}</h1>&nbsp;| 
	  			<c:choose>
	  				<c:when test="${!empty entity.moniker}">
						${entity.moniker}
	  				</c:when>
	  				<c:otherwise>
						${vclassName}
	  				</c:otherwise>
	  			</c:choose>
				<c:if test="${!empty entity.anchor}">
		  			<c:choose>
		  				<c:when test="${!empty entity.url}">
		  					<c:url var="entityUrl" value="${entity.url}" />
		  					| <a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a>
		  				</c:when>
		  				<c:otherwise>
		  					| <span class="externalLink">${entity.anchor}</span>
		  				</c:otherwise>
		  			</c:choose>
		  		</c:if>
				
				<c:if test="${!empty entity.linksList }">
					<c:forEach items="${entity.linksList}" var='link'>
						<c:url var="linkUrl" value="${link.url}" />
						| <a class="externalLink" href="<c:out value="${linkUrl}"/>">${link.anchor}</a>
					</c:forEach>
				</c:if>
				 
				<c:if test="${!empty entity.imageThumb}">
				<div class="thumbnail">
					<c:if test="${!empty entity.imageFile}">
							<c:url var="imageUrl" value="${imageDir}/${entity.imageFile}" />
							<a href="${imageUrl}">
					</c:if>
					<c:url var="imageSrc" value='${imageDir}/${entity.imageThumb}'/>
					<img src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
					<c:if test="${!empty entity.imageFile}"></a></c:if>
				</div>
				<c:if test="${!empty entity.citation}">
				<div class="citation">
					${entity.citation}
				</div>
                </c:if>
				</c:if>
			
                             <% /* graduate portal wants data properties first */ %>
                             <c:choose>
                               <c:when test="${portalBean.appName eq 'CALS Impact'}">
                                  <jsp:include page="/${entityDatapropsListJsp}"/> <% /*here we import the datatype properties for th
e entity */ %>
                                  <c:import url="${entityPropsListJsp}" />  <% /* here we import the properties for the entity */ %>
                               </c:when>
                               <c:otherwise>
				 <c:import url="${entityPropsListJsp}" />  <% /* here we import the properties for the entity */ %>  
				 <jsp:include page="/${entityDatapropsListJsp}"/> <% /*here we import the datatype properties for the entity */ %>
			       </c:otherwise>
                             </c:choose>	

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
                    Keywords: ${entity.keywordString}
                </div>
				</c:if>
				${requestScope.servletButtons}
			        <jsp:include page="entityAdmin.jsp"/> 
		</div>
