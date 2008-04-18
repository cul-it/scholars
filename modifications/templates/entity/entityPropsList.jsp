<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%      /***********************************************
                 Display a single Entity in the most basic fashion.
                 
                 request.attributes:
                 an Entity object with the name "entity" 
                 
                 request.parameters:
                 None yet.
                 
                  Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
                  for debugging info.
                                 
                 bdc34 2006-01-22 created                
        **********************************************/                               
//              if (request.getAttribute("entity") == null){
//              String e="entityPropsList.jsp expects that request attribute 'entity' be set to the Entity object to display.";
//          throw new JspException(e);
//        }         
%>

<c:set var="hiddenDivCount" value="0"/>

<c:if test="${sessionScope.loginHandler != null &&
              sessionScope.loginHandler.loginStatus == 'authenticated' &&
              sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
<c:set var="showPropEdits" value="true"/>
</c:if>
    <% if( VitroRequestPrep.isSelfEditing(request) ){
        request.setAttribute("showPropEdits","true");
    }
%>

<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:choose>
    <c:when test="${showPropEdits == true}">
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/editdefault/'/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
    </c:otherwise>
</c:choose>


<c:forEach items="${entity.objectPropertyList}" var="prop">
    <h3 class="propertyName">${prop.domainPublic}</h3>
    <c:if test="${showPropEdits == true}">
        <c:url var="editProp" value="edit/editRequestDispatch.jsp">
            <c:param name="subjectUri" value="${entity.URI}"/>
            <c:param name="predicateUri" value="${prop.URI}"/>
            <c:param name="defaultForm" value="false"/>
        </c:url>
        <a class="add image" href="${editProp}" title="add new"> <img src="${themeDir}site_icons/add_new.gif" alt="(add new)" /></a>
    </c:if>
    
    <c:set var='counter' value='0'/>
    <c:set var='displayLimit' value='${prop.rangeDisplayLimit}'/>
    
    <c:if test='${fn:length(prop.objectPropertyStatements)-displayLimit==1}'><c:set var='displayLimit' value='${displayLimit+1}'/></c:if>
    
    <c:if test="${displayLimit > 0}">
        <ul class='properties'>
    </c:if>
        
    <c:forEach items='${prop.objectPropertyStatements}' var='objPropertyStmt'>
        <c:if test='${counter ==  displayLimit}'>
        
            <c:if test="${displayLimit>0}">
                 </ul>
            </c:if>
    
            <c:set var="hiddenDivCount" value="${hiddenDivCount+1}"/>
            <div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('type${hiddenDivCount}','typeSw${hiddenDivCount}','${themeDir}site_icons')" title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)" onmouseout="onMouseOutHeading(this)">                                                           
                <span class="entityMoreSpan"><img src="<c:url value="${themeDir}site_icons/plus.gif"/>" id="typeSw${hiddenDivCount}" alt="more links"/> <c:out value='${fn:length(prop.objectPropertyStatements) - counter}' /> 
                    <c:choose>
                        <c:when test='${displayLimit==0}'> entries </c:when>
                        <c:otherwise> more </c:otherwise>
                    </c:choose>
                </span>
            </div>
    
            <div id="type${hiddenDivCount}" style="display: none;">                                   
                <ul class="propertyLinks">
        </c:if>

        <li>
            <c:url var="propertyLink" value="entity">
                <c:param name="home" value="${portal}"/>
                <c:param name="uri" value="${objPropertyStmt.object.URI}"/>
            </c:url>
            <c:forEach items="${objPropertyStmt.object.VClasses}" var="type">
            	<c:if test="${'http://vivo.library.cornell.edu/ns/0.1#EducationalBackground'==type.URI}">
            		<c:set var="altRenderInclude" value="true"/>
            	</c:if>
            </c:forEach> 
            <c:choose>
            	<c:when test="${altRenderInclude}">
					<c:set var="gradyear" value="${objPropertyStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#yearDegreeAwarded'].dataPropertyStatements[0].data}"/>
					<c:set var="degree" value="${objPropertyStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#preferredDegreeAbbreviation'].dataPropertyStatements[0].data}"/>
					<c:set var="institution" value="${objPropertyStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#institutionAwardingDegree'].dataPropertyStatements[0].data}"/>
					<c:set var="major" value="${objPropertyStmt.object.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#majorFieldOfDegree'].dataPropertyStatements[0].data}"/>
					<c:out value="${gradyear} : ${degree}, ${institution}, ${major}"/>
            		<c:set var="altRenderInclude" value="false"/>
    			</c:when>
            	<c:otherwise>
            		<a class="propertyLink" href='<c:out value="${propertyLink}"/>'><c:out value="${objPropertyStmt.object.name}"/></a> <c:if test="${showPropEdits != true}">| </c:if>
            		<c:choose>
                		<c:when test="${!empty objPropertyStmt.object.moniker}">
                        	<c:out value="${objPropertyStmt.object.moniker}"/>
                		</c:when>
                		<c:otherwise>
                       	<c:out value="${objPropertyStmt.object.VClass.name}"/>
                		</c:otherwise>
            		</c:choose>
				</c:otherwise>
            </c:choose>

            <c:if test="${showPropEdits == true}">
              <c:url var="edit" value="edit/editRequestDispatch.jsp">
                <c:param name="subjectUri" value="${entity.URI}"/>
                <c:param name="predicateUri" value="${prop.URI}"/>
                <c:param name="objectUri" value="${objPropertyStmt.object.URI}"/>
              </c:url>
              <a class="edit image" href="${edit}" title="edit"><img src="${themeDir}site_icons/pencil.gif" alt="(edit)" /></a>

             <c:url var="delete" value="edit/editRequestDispatch.jsp">
                <c:param name="subjectUri" value="${entity.URI}"/>
                <c:param name="predicateUri" value="${prop.URI}"/>
                <c:param name="objectUri" value="${objPropertyStmt.object.URI}"/>
                <c:param name="cmd" value="delete"/>
            </c:url>
            <a class="delete image" href="${delete}" title="delete"><img src="${themeDir}site_icons/trashcan.gif" alt="(delete)" /></a>
            </c:if>
        </li>
    
        <c:set var='counter' value='${counter + 1}'/>
    </c:forEach>

    </ul>

    <c:if test='${counter > displayLimit}'>
        </div>  <!-- close of prop ${prop.URI} -->
    </c:if>

</c:forEach>
