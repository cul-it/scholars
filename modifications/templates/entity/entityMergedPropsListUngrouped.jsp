<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.PropertyInstanceDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.DataPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.PropertyInstance" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Property" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.KeywordProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.PropertyGroup" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.PropertyGroupDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ObjectPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.RdfLiteralHash" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.entity.entityMergedPropsList.jsp");
%>
	<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
<%  if( VitroRequestPrep.isSelfEditing(request) ) {
        log.debug("setting showSelfEdits true");%>
        <c:set var="showSelfEdits" value="${true}"/>
<%  }
    if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
	    log.debug("setting showCuratorEdits true");%>
	    <c:set var="showCuratorEdits" value="${true}"/>
<%  }%>
    <c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
    <c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
    <c:set var="hiddenDivCount" value="0"/>
<%	Individual subject = (Individual) request.getAttribute("entity");
	if (subject==null) {
    	throw new Error("Subject individual must be in request scope for dashboardPropsList.jsp");
	}

	// Nick wants not to use explicit parameters to trigger visibility of a div, but for now we don't just want to always show the 1st one
	String openingGroupLocalName = (String) request.getParameter("curgroup");
    VitroRequest vreq = new VitroRequest(request);
    // added to permit distinguishing links outside the current portal
    int currentPortalId = -1;
    Portal currentPortal = vreq.getPortal();
    if (currentPortal!=null) {
    	currentPortalId = currentPortal.getPortalId();
    }

    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
	PropertyGroupDao pgDao = wdf.getPropertyGroupDao();
    ArrayList<Property> propsList = (ArrayList) request.getAttribute("mergedList");
	for (Property p : propsList) {%>
 		<c:set var="stmtCounter" value="0"/>
<%		if (p instanceof ObjectProperty) {
 			ObjectProperty op = (ObjectProperty)p;%>
 			<c:set var="objProp" value="<%=op%>"/>
 			<c:set var="editableInSomeWay" value="${false}"/>
 			<c:if test="${showSelfEdits || showCuratorEdits}">
	    		<edLnk:editLinks item="${objProp}" var="links" />
	    		<c:if test="${!empty links}">
	    			<c:set var="editableInSomeWay" value="${true}"/>
	    		</c:if>                                                       
      		</c:if>
	    	<c:set var="objStyle" value="display: block;"/>
	    	<c:set var="objRows" value="${fn:length(objProp.objectPropertyStatements)}"/>
	    	<c:if test="${objRows==0}"><c:set var="objStyle" value="display: block;"/></c:if>
	    	<c:if test="${editableInSomeWay || objRows>0}">
				<div class="propsItem" id="${objProp.localName}">
					<h3 class="propertyName">${objProp.editLabel}</h3>
		    		<c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${objProp}" icons="true" /></c:if>
		    		<c:if test="${showCuratorEdits}">
		    			<c:choose>
		    				<c:when test="${!empty objProp.groupURI}">
		    			        <c:if test="${!empty objProp.domainDisplayTier}">
<%		    				        PropertyGroup pg = pgDao.getGroupByURI(op.getGroupURI());
		    					    if (pg!=null && pg.getName()!=null) {
		    					    	request.setAttribute("groupName",pg.getName());%>
		    					        <span style="color: grey; font-size: 0.75em;"> tier ${objProp.domainDisplayTier} within group ${groupName}</span>
<%                                  }%>
                                </c:if>
		    				</c:when>
		    				<c:otherwise>
		    				    <c:if test="${!empty objProp.domainDisplayTier}"><span style="color: grey; font-size: 0.75em;"> tier ${objProp.domainDisplayTier}</span></c:if>
		    				</c:otherwise>
		    			</c:choose>
		    		</c:if>
  					<c:set var="displayLimit" value="${objProp.domainDisplayLimit}"/>
  					<c:if test="${displayLimit<0}">
  					    <c:set var="displayLimit" value="32"/> <% /* arbitrary limit if value is unset, i.e. -1 */ %>
  					</c:if>
					<c:if test="${fn:length(objProp.objectPropertyStatements)-displayLimit==1}"><c:set var="displayLimit" value="${displayLimit+1}"/></c:if>
					<c:if test="${objRows>0}">
      					<ul class='properties'>
  					</c:if>
					<c:forEach items="${objProp.objectPropertyStatements}" var="objPropertyStmt">
						<c:if test="${stmtCounter == displayLimit}"><!-- set up toggle div and expandable continuation div -->
  							</ul>
  		                	<c:set var="hiddenDivCount" value="${hiddenDivCount+1}"/>
							<c:url var="themePath" value="/${themeDir}site_icons" />
                          	<div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('type${hiddenDivCount}','typeSw${hiddenDivCount}','${themePath}')" title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)" onmouseout="onMouseOutHeading(this)">                                                           
                  				<span class="entityMoreSpan"><img src="<c:url value="/${themeDir}site_icons/plus.gif"/>" id="typeSw${hiddenDivCount}" alt="more links"/>
                  				<c:out value='${objRows - stmtCounter}'/> 
                              	<c:choose>
                                  	<c:when test='${displayLimit==0}'> entries </c:when>
                                  	<c:otherwise> more </c:otherwise>
                              	</c:choose>
                              	</span>
                          	</div>
          					<div id="type${hiddenDivCount}" style="display: none;">                                   
              				<ul class="properties">
						</c:if>
     					<li>
     					<c:set var="opStmt" value="${objPropertyStmt}" scope="request"/>
           				<c:url var="propertyLink" value="/entity">
               				<c:param name="home" value="${portal.portalId}"/>
               				<c:param name="uri" value="${objPropertyStmt.object.URI}"/>
               				<%--
<%							ObjectPropertyStatement oStmt = (ObjectPropertyStatement)request.getAttribute("opStmt");
							if (oStmt!=null) {
								Individual obj= (Individual)oStmt.getObject();
								if (obj != null) {
									if (!obj.doesFlag1Match(currentPortalId)) {%>
										<c:param name="jump" value="true"/>
<%									}
								}
							}%> --%>
           				</c:url>
						<c:remove var="opStmt" scope="request"/>
         				<c:forEach items="${objPropertyStmt.object.VClasses}" var="type">
         					<c:if test="${!empty type.customShortView}">
         						<c:set var="altRenderJsp" value="${type.customShortView}"/>
         					</c:if>
         				</c:forEach> 
            			<c:choose>
				            <c:when test="${!empty altRenderJsp}">
								<c:set scope="request" var="individual" value="${objPropertyStmt.object}"/>
								<c:set scope="request" var="predicateUri" value="${objProp.URI}"/>
								<jsp:include page="${altRenderJsp}" flush="true"/>
				            	<c:remove var="altRenderJsp"/>
				    		</c:when>
				            <c:otherwise>
				            	<a class="propertyLink" href='<c:out value="${propertyLink}"/>'><p:process><c:out value="${objPropertyStmt.object.name}"/></p:process></a>
				            	<c:if test="${!empty objPropertyStmt.object.moniker}">
				                    <p:process><c:out value="| ${objPropertyStmt.object.moniker}"/></p:process>
				                </c:if>
							</c:otherwise>
	            		</c:choose>
						<c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${objPropertyStmt}" icons="true"/></c:if>
      					</li>
						<c:set var="stmtCounter" value="${stmtCounter+1}"/>
					</c:forEach>
					<c:if test="${objRows > 0}"></ul></c:if>
   					<c:if test="${stmtCounter > displayLimit}"></div></c:if>
 				</div><!-- ${objProp.localName} -->
 			</c:if>
<%		} else if (p instanceof DataProperty) {
  			DataProperty dp = (DataProperty)p;%>
  			<c:set var="dataProp" value="<%=dp%>"/>
 			<c:set var="dataRows" value="${fn:length(dataProp.dataPropertyStatements)}"/>
		    <c:set var="dataStyle" value="display: block;"/>
		    <c:if test="${dataRows==0}"><c:set var="dataStyle" value="display: block;"/></c:if>
			<div class="propsItem" id="${dataProp.localName}" style="${dataStyle}">
				<h3 class="propertyName">${dataProp.editLabel}</h3>
		    	<c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${dataProp}" icons="true"/></c:if>
				<c:if test="${showCuratorEdits}">
		    		<c:choose>
		    		    <c:when test="${!empty dataProp.groupURI}">
		    			    <c:if test="${!empty dataProp.displayTier}">
<%		    				    PropertyGroup pg = pgDao.getGroupByURI(dp.getGroupURI());
		    					if (pg!=null && pg.getName()!=null) {
		    					    request.setAttribute("groupName",pg.getName());%>
		    					    <span style="color: grey; font-size: 0.75em;"> tier ${dataProp.displayTier} within group ${groupName}</span>
<%                              }%>
                            </c:if>
		    		    </c:when>
		    			<c:when test="${!empty dataProp.groupURI}">
				    		<c:if test="${!empty dataProp.displayTier}"><span style="color: grey; font-size: 0.75em;"> tier ${dataProp.displayTier} within group</span></c:if>
				    	</c:when>
				    	<c:otherwise>
				    		<c:if test="${!empty dataProp.displayTier}"><span style="color: grey; font-size: 0.75em;"> tier ${dataProp.displayTier}</span></c:if>
				    	</c:otherwise>
				    </c:choose>
				</c:if>
				<c:set var="displayLimit" value="${dataProp.displayLimit}"/>
				<c:if test="${displayLimit<0}">
				    <c:set var="displayLimit" value="32"/> <% /* arbitrary limit if value is unset, i.e. -1 */ %>
				</c:if>
				<c:if test="${fn:length(dataProp.dataPropertyStatements)-displayLimit==1}"><c:set var="displayLimit" value="${displayLimit+1}"/></c:if>
				<c:if test="${displayLimit < 0}"><c:set var="displayLimit" value="20"/></c:if>
				<div class="datatypeProperties">
 			    	<c:if test="${dataRows > 1}">
						<ul class="datatypePropertyValue">
					</c:if>
					<c:if test="${dataRows == 1}">
						<div class="datatypePropertyValue">
					</c:if>
					<c:forEach items="${dataProp.dataPropertyStatements}" var="dataPropertyStmt">
						<c:if test="${stmtCounter == displayLimit}">
  							<c:if test="${dataRows > 1 && displayLimit < 0}"></ul></c:if>
              				<div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('type${dataProp.URI}','typeSw${dataProp.URI}','${themeDir}site_icons')"
                     			 title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)"
                     			 onmouseout="onMouseOutHeading(this)">                                   
                     			<span class="entityMoreSpan"><img src="${themeDir}site_icons/plus.gif" id="typeSw${dataProp.URI}" alt="more links"/>
                     				<c:out value='${dataRows - stmtCounter}' />
                     				<c:choose>
                         				<c:when test='${displayLimit==0}'> entries </c:when>
                         				<c:otherwise> more </c:otherwise>
                     				</c:choose>
                     			</span>
             				</div>
             				<div id="type${dataProp.URI}" style="display: none;">                     
						</c:if>
		            	<c:set var="stmtCounter" value="${stmtCounter+1}"/>
		            	<c:choose>
		                	<c:when test='${dataRows==1}'><p:process>${dataPropertyStmt.data}</p:process></c:when>
		                	<c:otherwise><li><p:process>${dataPropertyStmt.data}</p:process></li></c:otherwise>
		            	</c:choose>
		            	<c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${dataPropertyStmt}" icons="true"/></c:if>
       					<c:if test="${dataRows==1}"></div></c:if>
					</c:forEach>
					<c:if test="${stmtCounter > displayLimit}"></div></c:if>
                </div><!-- datatypeProperties -->
			</div><!-- ${dataProp.localName} -->		
<%		} else { // keyword property -- ignore
		    if (p instanceof KeywordProperty) {%>
				<p>Not expecting keyword properties here.</p>
<%			} else {
  				log.warn("unexpected unknown property type found");%>
   				<p>Unknown property type found</p>
<%			}
		} 
   } // end for (Property p : g.getPropertyList()
%>

