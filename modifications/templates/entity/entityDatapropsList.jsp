<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.RdfLiteralHash" %>


<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
         Displays the dataProperties for an entity
         
         request.attributes:
         an Entity object with the name "entity" 
         
         request.parameters:
         None yet.
         
          Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
          for debugging info.
                 
         bjl23 2006-08-23 created        
        **********************************************/                           
if (request.getAttribute("entity") == null){
    String e="entityDatapropsList.jsp expects that request attribute 'entity' be set to the Entity object to display.";
    throw new JspException(e);
}         
%>
<c:if test="${sessionScope.loginHandler != null &&
              sessionScope.loginHandler.loginStatus == 'authenticated' &&
              sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
    <c:set var="showPropEdits" value="true"/>
</c:if>
<%  if( VitroRequestPrep.isSelfEditing(request) ){
    request.setAttribute("showPropEdits","true");
}%>
    
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='portal' value='${requestScope.portal}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var='datapropStmt' value='${datapropStmt}'/>
<c:choose>
    <c:when test="${showPropEdits == true}">
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/editdefault/'/></c:set>
    </c:when>
    <c:otherwise>
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
    </c:otherwise>
</c:choose>
    
<c:set var="numDataprops" value="${fn:length(entity.dataPropertyList)}"/>

<div id="datatypeProperties">

<c:if test="${numDataprops>0}">                     
    <c:forEach items="${entity.dataPropertyList}" var="dataprop">
        <c:set var='displayLimit' value='${dataprop.displayLimit}'/>
        
        <h3 class="propertyName">${dataprop.publicName}</h3>
        
            <c:if test="${showPropEdits == true}">
            <c:url var="editProp" value="edit/editDatapropStmtRequestDispatch.jsp">
                <c:param name="subjectUri" value="${entity.URI}"/>
                <c:param name="predicateUri" value="${dataprop.URI}"/>
                <c:param name="defaultForm" value="false"/>
            </c:url>
            <a class="add image" href="${editProp}" title="add new"> <img src="${themeDir}site_icons/add_new.gif" alt="(add new)" /></a>
        </c:if>

        <c:set var='counter' value='0'/>
    
        <c:set var='dataRows' value='${fn:length(dataprop.dataPropertyStatements)}'/>

        <c:if test='${dataRows-displayLimit==1}'><c:set var='displayLimit' value='${displayLimit+1}'/></c:if>

        <c:if test="${displayLimit < 0}">
            <c:set var='displayLimit' value='20'/>
        </c:if>

		<c:choose>
        	<c:when test="${dataRows>1 && displayLimit>0}">
            	<ul class='datatypePropertyValue'>
        	</c:when>
        	<c:when test="${dataRows==1}">
        		<div class='datatypePropertyValue'>
        	</c:when>
        </c:choose>
    
        <c:forEach items='${dataprop.dataPropertyStatements}' var='dataPropertyStmt'>
             <c:if test='${counter ==  displayLimit}'>
                 <c:if test='${dataRows>1 && displayLimit>0}'>
                     </ul>
                 </c:if>
                 <div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('type${dataprop.URI}','typeSw${dataprop.URI}','${themeDir}site_icons')"
                        title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)"
                        onmouseout="onMouseOutHeading(this)">                                   
                        <span class="entityMoreSpan"><img src="${themeDir}site_icons/plus.gif" id="typeSw${dataprop.URI}" alt="more links"/> <c:out value='${fn:length(dataprop.dataPropertyStatements) - counter}' />
                     
                        <c:choose>
                            <c:when test='${displayLimit==0}'> entries </c:when>
                            <c:otherwise> more </c:otherwise>
                        </c:choose>
                        </span>
                </div>
                <div id="type${dataprop.URI}" style="display: none;">                     
                <ul class="datatypePropertyDataList">
            </c:if>
            <c:set var='counter' value='${counter+1}'/>
            <c:choose>
                <c:when test='${dataRows==1}'>
                      ${dataPropertyStmt.data}
                </c:when>
                <c:otherwise>
                    <li>
                      ${dataPropertyStmt.data}
                    </li>
                </c:otherwise>
            </c:choose>
            <c:if test="${showPropEdits == true}">
                <c:set var="datapropStmt" scope="request" value="${dataPropertyStmt}"/>
                <%
                DataPropertyStatement dps=(DataPropertyStatement)request.getAttribute("datapropStmt");
                if (dps==null) {
                    throw new JspException("DataPropertyStatement null in entityDatapropsList");
                }
                if (dps.getData()==null) {
                    throw new JspException("DataPropertyStatement.getData() returns null in entityDatapropsList");
                }
                int requestHash = RdfLiteralHash.makeRdfLiteralHash(dps);
                //System.out.println("in entityDatapropsList.jsp, setting data hash to "+requestHash+" for data\n["+dps.getData()+"]\n");
                %>
                <c:url var="edit" value="edit/editDatapropStmtRequestDispatch.jsp">
                    <c:param name="subjectUri" value="${entity.URI}"/>
                    <c:param name="predicateUri" value="${dataprop.URI}"/>
                    <c:param name="datapropKey" value="<%=String.valueOf(requestHash)%>"/>
                </c:url>
                <a class="edit image" href="${edit}" title="edit"> <img src="${themeDir}site_icons/pencil.gif" alt="(edit)" /></a>
          
                <c:url var="delete" value="edit/editDatapropStmtRequestDispatch.jsp">
                    <c:param name="subjectUri" value="${entity.URI}"/>
                    <c:param name="predicateUri" value="${dataprop.URI}"/>
                    <c:param name="datapropKey" value="<%=String.valueOf(requestHash)%>"/>
                    <c:param name="cmd" value="delete"/>
                </c:url>
                <a class="delete image" href="${delete}" title="delete"> <img src="${themeDir}site_icons/trashcan.gif" alt="(delete)" /></a>
                <c:remove var="datapropStmt" scope="request"/>
            </c:if>
            <c:choose>
                <c:when test='${dataRows==1}'>
                </c:when>
                <c:otherwise>
                    </li>
                </c:otherwise>
            </c:choose>
                            

        </c:forEach>
        <c:choose>
        	<c:when test="${dataRows>1}">
            	</ul>
        	</c:when>
        	<c:when test="${dataRows==1}">
        		</div>
        	</c:when>
        </c:choose>
    </c:forEach> 
</c:if>
</div> <!-- datatypeProperties -->