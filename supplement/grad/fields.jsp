<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="part/resources.jsp" %>

<c:set var="URI">${namespace}${param.uri}</c:set>
<c:set var="encodedURI"><str:encodeUrl>${URI}</str:encodeUrl></c:set>
<c:set var="fieldName">
	<c:import url="part/getlabel.jsp"><c:param name="uri" value="${URI}"/></c:import>
</c:set>

<c:if test="${!empty param.uri}">
    <c:set var="metaDescription">
    	<c:import url="part/getmetadescription.jsp">
    	    <c:param name="uri" value="${URI}"/>
    	    <c:param name="type" value="field"/>
    	</c:import>
    </c:set>
</c:if>

<!-- <c:set var="groupName"><%=session.getAttribute("groupName")%></c:set> -->
<!-- <c:set var="groupID"><%=session.getAttribute("groupID")%></c:set> -->

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="fields"/>
    <jsp:param name="metaURI" value="${encodedURI}"/>
    <jsp:param name="metaDescription" value="${metaDescription}"/>
    <jsp:param name="titleText" value="Graduate Field of ${fieldName} | Cornell University  "/>
</jsp:include>

<div id="contentWrap">
    
    <!-- <div id="breadcrumbs" class="small">
        <ol>
            <li class="first"><a class="first" href="index.jsp">Home</a></li>
            <li class="second">
                <c:choose>
                    <c:when test="${!empty param.groupLabel}">
                        <c:url var="groupHref" value="areas.jsp">
                            <c:param name="uri" value="${param.groupUri}"/>
                            <c:param name="label" value="${param.groupLabel}"/>
                            <c:param name="class" value="${param.groupClass}"/>
                        </c:url>
                        <a class="second ${param.groupClass}" href="${groupHref}">${param.groupLabel}</a>
                    </c:when>
                    <c:otherwise>
                        <a class="second" href="/fieldsindex/">Graduate Fields</a>
                    </c:otherwise>
                </c:choose>
            </li>
            <li class="third">${param.fieldLabel}</li>
        </ol>
    </div> --> <!-- breadcrumbs -->
    
	<div id="content">
        
        <c:choose>
            <c:when test="${not empty param.uri}">
                <c:import url="/entity">
                    <c:param name="portal" value="1" />
                    <c:param name="uri" value="${URI}" />
                    <c:param name="view" value="grad/templates/fieldEntity.jsp" />
                </c:import>
            </c:when>
        
            <c:otherwise>
                <c:redirect url="/fieldsindex/"/>
            </c:otherwise>
        </c:choose>
      
        <!-- content closed in fieldEntity -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp">
    <jsp:param name="uri" value="${URI}"/>
</jsp:include>