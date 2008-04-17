<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
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
<%  if( VitroRequestPrep.isSelfEditing(request) ) {
        log.debug("setting showSelfEdits true");%>
        <c:set var="showSelfEdits" value="${true}"/>
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/editdefault/'/></c:set>
<%  }
    if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
	    log.debug("setting showCuratorEdits true");%>
	    <c:set var="showCuratorEdits" value="${true}"/>
	    <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
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
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
	PropertyGroupDao pgDao = wdf.getPropertyGroupDao();
    ArrayList<PropertyGroup> groupsList = (ArrayList) request.getAttribute("groupsList");
    if (groupsList!=null && groupsList.size()>0) { // first do the list of headers %>
        <ul id="profileCats">
<%		for (PropertyGroup pg : groupsList ) { 
			if (openingGroupLocalName == null || openingGroupLocalName.equals("")) {
				openingGroupLocalName = pg.getLocalName();
			}
			String styleStr = pg.getStatementCount()==0 ? "display: inline;" : "display: inline;";
			if (openingGroupLocalName.equals(pg.getLocalName())) {%>
      		    <li style="<%=styleStr%>"><a id="currentCat" href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%			} else { %>
        		<li style="<%=styleStr%>"><a href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%		    }
		} %>
		</ul>
<%		// now display the properties themselves, by group
		for (PropertyGroup g : groupsList) {%>
			<c:set var="group" value="<%=g%>"/>
			<c:set var="groupStyle" value="display: block;"/>
			<c:if test="${group.statementCount==0}"><c:set var="groupStyle" value="display: block"/></c:if>
			<div class="propsCategory" id="<%=g.getLocalName()%>" style="${groupStyle}">
				<h2><%=g.getName()%></h2>
<%				for (Property p : g.getPropertyList()) {%>
    				<c:set var="counter" value="0"/>
<%					if (p instanceof ObjectProperty) {
    					ObjectProperty op = (ObjectProperty)p;%>
    					<c:set var="objProp" value="<%=op%>"/>
				    	<c:set var="objStyle" value="display: block;"/>
				    	<c:if test="${fn:length(objProp.objectPropertyStatements)==0}"><c:set var="objStyle" value="display: block;"/></c:if>
						<div id="${objProp.localName}" style="${objStyle}">
							<h3>${objProp.editLabel}</h3>
				    		<c:if test="${showSelfEdits || showCuratorEdits}">
				    			<edLnk:editLinks item="${objProp}"/>
	        				</c:if>
    						<c:set var="displayLimit" value="${objProp.domainDisplayLimit}"/>
    						<c:if test="${fn:length(objProp.objectPropertyStatements)-displayLimit==1}"><c:set var="displayLimit" value="${displayLimit+1}"/></c:if>
							<ul class="properties">
							<c:forEach items="${objProp.objectPropertyStatements}" var="objPropertyStmt">
								<c:if test="${counter == displayLimit}"><!-- set up toggle div and expandable continuation div -->
    								</ul>
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
	
									<c:if test="${showSelfEdits || showCuratorEdits}">
										<edLnk:editLinks item="${objPropertyStmt}"/>
									</c:if>
        						</li>
								<c:set var="counter" value="${counter+1}"/>
							</c:forEach>
							</ul>
   							<c:if test="${counter > displayLimit}">
       							</div>
   							</c:if>
   						</div>
<%					} else if (p instanceof DataProperty) {
	    				DataProperty dp = (DataProperty)p;%>
	    				<c:set var="dataProp" value="<%=dp%>"/>
	   			    	<c:set var="dataRows" value="${fn:length(dataProp.dataPropertyStatements)}"/>
					    <c:set var="dataStyle" value="display: block;"/>
					    <c:if test="${dataRows==0}"><c:set var="dataStyle" value="display: block;"/></c:if>
						<div id="${dataProp.localName}" style="${dataStyle}">
							<h3>${dataProp.editLabel}</h3>
					    	<c:if test="${showSelfEdits || showCuratorEdits}">
					    		<edLnk:editLinks item="${dataProp}"/>
		        			</c:if>
							<c:set var="displayLimit" value="${dataProp.displayLimit}"/>
							<c:if test="${fn:length(dataProp.dataPropertyStatements)-displayLimit==1}"><c:set var="displayLimit" value="${displayLimit+1}"/></c:if>
							<c:if test="${displayLimit < 0}"><c:set var="displayLimit" value="20"/></c:if>
	   			    		<div class="datatypeProperties">
	   			    			<c:if test="${dataRows > 1 && displayLimit < 0}">
									<ul class='datatypePropertyValue'>
								</c:if>
								<c:if test="${dataRows == 1}">
									<div class='datatypePropertyValue'>
								</c:if>
								<c:forEach items="${dataProp.dataPropertyStatements}" var="dataPropertyStmt">
									<c:if test="${counter == displayLimit}">
	    								<c:if test="${dataRows > 1 && displayLimit < 0}">
	    									</ul>
										</c:if>
	                					<div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('type${dataProp.URI}','typeSw${dataProp.URI}','${themeDir}site_icons')"
	                       					title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)"
	                       					onmouseout="onMouseOutHeading(this)">                                   
	                       					<span class="entityMoreSpan"><img src="${themeDir}site_icons/plus.gif" id="typeSw${dataProp.URI}" alt="more links"/> <c:out value='${fn:length(dataProp.dataPropertyStatements) - counter}' />
	                       						<c:choose>
	                           						<c:when test='${displayLimit==0}'> entries </c:when>
	                           						<c:otherwise> more </c:otherwise>
	                       						</c:choose>
	                       					</span>
	               						</div>
	               						<div id="type${dataProp.URI}" style="display: none;">                     
	               						<ul class="datatypePropertyDataList">
									</c:if>
				            		<c:set var="counter" value="${counter+1}"/>
				            		<c:choose>
				                		<c:when test='${dataRows==1}'>${dataPropertyStmt.data}</c:when>
				                		<c:otherwise><li>${dataPropertyStmt.data}</li></c:otherwise>
				            		</c:choose>
				            		<c:if test="${showPropEdits || showCuratorEdits}">
				            			<edLnk:editLinks item="${dataPropertyStmt}"/>
									</c:if>
	        						<c:choose>
	        							<c:when test="${dataRows>1}"></ul></c:when>
	        							<c:when test="${dataRows==1}"></div></c:when>
	        						</c:choose>
								</c:forEach>
							</div>
						</div>
<%					} else { // keyword property -- ignore
				    	if (p instanceof KeywordProperty) {%>
							<p>Not expecting keyword properties here.</p>
<%						} else {
    						log.warn("unexpected unknown property type found");%>
    						<p>Unknown property type found</p>
<%						}
					} 
				} // end for (Property p : g.getPropertyList()%>
			</div><!-- class="propsCategory" -->
<%		} // end for (PropertyGroup g : groupsList)
    } else {
    	log.warn("incoming merged property list not found as request attribute");
    }
%>

