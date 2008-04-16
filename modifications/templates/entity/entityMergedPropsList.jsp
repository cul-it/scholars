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
<%  boolean showSelfEdits=false;
    boolean showCuratorEdits=false;
    if( VitroRequestPrep.isSelfEditing(request) ) {
        showSelfEdits=true;
        log.debug("setting showSelfEdits true");
    }
    if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
	    showCuratorEdits=true;
	    log.debug("setting showCuratorEdits true");
    }%>
    <c:choose>
    	<c:when test="${showSelfEdits}">
    		<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/editdefault/'/></c:set>
        </c:when>
    	<c:otherwise>
        	<c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
        </c:otherwise>
    </c:choose>
    <c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
    <c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
    <c:set var="hiddenDivCount" value="0"/>
<%	Individual subject = (Individual) request.getAttribute("entity");
	if (subject==null) {
    	throw new Error("Subject individual must be in request scope for dashboardPropsList.jsp");
	}

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
			if (openingGroupLocalName.equals(pg.getLocalName())) {%>
      		    <li><a id="currentCat" href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%			} else { %>
        		<li><a href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%		    }
		} %>
		</ul>
<%		// now display the properties themselves, by group
		for (PropertyGroup g : groupsList) {%>
			<div class="propsCategory" id="<%=g.getLocalName()%>">
			<h2><%=g.getName()%></h2>
<%			for (Property p : g.getPropertyList()) {
				request.setAttribute("prop",p);%>
				<h3><%=p.getEditLabel()%></h3>
<%				if (showSelfEdits || showCuratorEdits) { %>
			        <c:url var="editProp" value="edit/editRequestDispatch.jsp">
			            <c:param name="subjectUri" value="${entity.URI}"/>
			            <c:param name="predicateUri" value="${prop.URI}"/>
			            <c:param name="defaultForm" value="false"/>
			        </c:url>
        			<a class="add image" href="${editProp}" title="add new"><img src="${themeDir}site_icons/add_new.gif" alt="(add new)" /></a>
<%				}
				int counter = 0;
				if (p instanceof ObjectProperty) {
    				ObjectProperty op = (ObjectProperty)p;
    		    	int displayLimit = op.isSubjectSide() ? op.getDomainDisplayLimit() : op.getRangeDisplayLimit();
    		    	List<ObjectPropertyStatement> objPropStmtsList = op.getObjectPropertyStatements();
					if (objPropStmtsList != null ) {
				    	if (objPropStmtsList.size()-displayLimit==1) {
				    		displayLimit += 1;
						}
						if (displayLimit>0) { %>
							<ul class="properties">
<%							for (ObjectPropertyStatement ops : objPropStmtsList) {
	    						request.setAttribute("objPropertyStmt",ops);
	    						request.setAttribute("displayLimit",displayLimit);
	    						if ( counter==displayLimit ) {
	    							if (displayLimit>0) {%>
	    								</ul>
<%									}%>
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
<%								}%>
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
	
<%								if (showSelfEdits || showCuratorEdits) {%>
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
<%								} %>
	        					</li>					
<%							} // end for %>
							</ul><!-- class="properties" -->
<%						} // end if displayLimit > 0
					} // end if getObjectPropertyStatements() != null
				} else if (p instanceof DataProperty) {
    				DataProperty dp = (DataProperty)p;
    				request.setAttribute("dataprop",dp);
    				int displayLimit = dp.getDisplayLimit();
    				int dataRows=0;
    				List<DataPropertyStatement> dataPropStmtsList = dp.getDataPropertyStatements();
    				if (dataPropStmtsList != null) {
    			    	dataRows = dataPropStmtsList.size();
    			    	if ((dataRows - displayLimit)==1) {
    			    		displayLimit += 1;
    					}
    			    	displayLimit= (displayLimit<0) ? 20 : displayLimit;%>
    			    	<div class="datatypeProperties">
<%    			    	if (dataRows>1 && displayLimit>0) { %>
							<ul class='datatypePropertyValue'>
<%            			}
						if (dataRows==1) { %>
							<div class='datatypePropertyValue'>
<%            			}
						for (DataPropertyStatement dps : dataPropStmtsList) {
    						//request.setAttribute("dataPropertyStmt",dps);
    						request.setAttribute("displayLimit",displayLimit);
    						if ( counter==displayLimit ) {
    							if (dataRows>1 && displayLimit>0) {%>
    								</ul>
<%								} %>
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
<%    						}
           					counter += 1;
           					if (dataRows == 1 ) { %>
                      			<%=dps.getData()%>
<%							} else { %>
                    			<li>${dataPropertyStmt.data}</li>
<%							}
							if ( showSelfEdits || showCuratorEdits ) {
								int requestHash = RdfLiteralHash.makeRdfLiteralHash(dps); %>
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
<%							} // end if (showSelfEdits ...
						} // end for %>
						</div><!-- class="datatypeProperties" -->
<%					} // end if dp.getDataPropertyStatements() != null
				} else { // keyword property -- ignore
				    if (p instanceof KeywordProperty) {%>
						<p>Not expecting keyword properties here.</p>
<%					} else {
    					log.warn("unexpected unknown property type found");%>
    					<p>Unknown property type found</p>
<%					}
				} 
			} // end for (Property p : g.getPropertyList()%>
			</div><!-- class="propsCategory" -->
<%		} // end for (PropertyGroup g : groupsList)
    } else {
    	log.warn("incoming merged property list not found as request attribute");
    }
%>

