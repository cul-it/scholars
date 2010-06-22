<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
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
<%  }
    if (loginHandler!=null && loginHandler.getLoginStatus()=="authenticated" && Integer.parseInt(loginHandler.getLoginRole())>=loginHandler.getEditor()) {
        log.debug("setting showCuratorEdits true");%>
        <c:set var="showCuratorEdits" value="${true}"/>
        <c:set var='themeDir'><c:out value='${portalBean.themeDir}' default='themes/vivo/'/></c:set>
<%  }
	String unassignedPropGroupName=null;
	String unassignedName = (String) request.getAttribute("unassignedPropsGroupName");
	if (unassignedName != null && unassignedName.length()>0) {
	    unassignedPropGroupName=unassignedName;
	    log.debug("found temp group attribute \""+unassignedName+"\" for unassigned properties");
	}%>
    <c:set var='entity' value='${requestScope.entity}'/><%-- just moving this into page scope for easy use --%>
    <c:set var='portal' value='${requestScope.portalBean}'/><%-- likewise --%>
    <c:set var="hiddenDivCount" value="0"/>
<%  Individual subject = (Individual) request.getAttribute("entity");
    if (subject==null) {
        throw new Error("Subject individual must be in request scope for entityMergedPropsList.jsp");
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
    ArrayList<PropertyGroup> groupsList = (ArrayList) request.getAttribute("groupsList");
    if (groupsList!=null && groupsList.size()>0) { // first do the list of headers 
        if (groupsList.size()==1) {
            for (PropertyGroup pg : groupsList) {
                if (unassignedPropGroupName != null && !unassignedPropGroupName.equalsIgnoreCase(pg.getName())) {
                    log.debug("only one group ["+pg.getName() +"] so rendering without group headers");
                }
                request.setAttribute("mergedList",pg.getPropertyList());
            }
            %><jsp:include page="entityMergedPropsListUngrouped.jsp" flush="true"/><%
            return;
    	}%>
    	
    	<%-- 
        <ul id="profileCats">
<%      for (PropertyGroup pg : groupsList ) {
            if (openingGroupLocalName == null || openingGroupLocalName.equals("")) {
                openingGroupLocalName = pg.getLocalName();
            }
            String styleStr = "display: inline;";
            if (openingGroupLocalName.equals(pg.getLocalName())) {%>
                <li class="currentCat"><a id="currentCat" href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%          } else { %>
                <li><a href="#<%=pg.getLocalName()%>" title="<%=pg.getName()%>"><%=pg.getName()%></a></li>
<%          }
        } %>
        </ul>
	--%>

		
<%      // now display the properties themselves, by group
        for (PropertyGroup g : groupsList) {%>
            <c:set var="group" value="<%=g%>"/>
            <c:set var="groupStyle" value="display: block;"/>
            <c:if test="${group.statementCount==0}"><c:set var="groupStyle" value="display: block"/></c:if>


            	<%-- Getting the count of properties in each group --%>
				<c:set var="counter" value="0"/>
            	<c:set var="propTotal" value="0"/>
				<% int propTotal = g.getPropertyList().size(); %>
				<c:set var="propTotal" value="<%=propTotal%>" />
				
            
			<div class="propsCategory" id="<%=g.getLocalName()%>">
				<h3><strong><%=g.getName()%></strong></h3>
				<div class="propsWrap">
<%				for (Property p : g.getPropertyList()) {%>
<%					if (p instanceof ObjectProperty) {
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
				    		<c:set var="first" value=""/><c:if test="${counter == 0}"><c:set var="first" value=" first"/></c:if>
            		        <c:set var="last" value=""/><c:if test="${(counter+1) == propTotal}"><c:set var="last" value=" last"/></c:if>
                            <div class="propsItem${first}${last}" id="${objProp.localName}">
                                <h4>${objProp.editLabel}</h4>
					    		<c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${objProp}" icons="false" /></c:if>
	    						<c:set var="displayLimit" value="${objProp.domainDisplayLimit}"/>

								<c:if test="${displayLimit<0}">
								    <c:set var="displayLimit" value="32"/> <% /* arbitrary limit if value is unset, i.e. -1 */ %>
								</c:if>

								<c:if test="${objRows>0}">
	        						<ul class='properties'>
	    						</c:if>
					            <c:forEach items="${objProp.objectPropertyStatements}" var="objPropertyStmt">
                                    <li>
					                <c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${objPropertyStmt}" icons="false"/></c:if>
     								<c:set var="opStmt" value="${objPropertyStmt}" scope="request"/>
           							<c:url var="propertyLink" value="/entity">
               							<c:param name="home" value="${portal.portalId}"/>
               							<c:param name="uri" value="${objPropertyStmt.object.URI}"/>
               							<%--
<%										ObjectPropertyStatement oStmt = (ObjectPropertyStatement)request.getAttribute("opStmt");
										if (oStmt!=null) {
											Individual obj= (Individual)oStmt.getObject();
											if (obj != null) {
												if (!obj.doesFlag1Match(currentPortalId)) {%>
													<c:param name="jump" value="true"/>
<%												}
											}
										}%>
										--%>
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
                                    </li>
                                </c:forEach>
                                <c:if test="${objRows > 0}"></ul></c:if>
                            </div><!-- ${objProp.localName} -->
                        </c:if>
<%                  } else if (p instanceof DataProperty) {
                        DataProperty dp = (DataProperty)p;%>
                        <c:set var="dataProp" value="<%=dp%>"/>
                        <c:set var="dataRows" value="${fn:length(dataProp.dataPropertyStatements)}"/>
                        <c:set var="dataStyle" value="display: block;"/>
						<c:set var="displayLimit" value="${dataProp.displayLimit}"/>
                        <c:if test="${dataRows==0}"><c:set var="dataStyle" value="display: block;"/></c:if>

						<c:set var="first" value=""/><c:if test="${counter == 0}"><c:set var="first" value=" first"/></c:if>
            			<c:set var="last" value=""/><c:if test="${(counter+1) == propTotal}"><c:set var="last" value=" last"/></c:if>
            			<c:set var="multiItem" value=""/><c:if test="${dataRows > 1 && displayLimit == 1}"><c:set var="multiItem" value=" multiItem"/></c:if>
            			<c:set var="addable" value=""/><c:if test="${dataRows >= 1 && displayLimit > 1}"><c:set var="addable" value=" addable"/></c:if>
            			
						<div id="${dataProp.localName}" class="propsItem dataItem${first}${last}${multiItem}${addable}" style="${dataStyle}">
							<h4>${dataProp.editLabel}</h4>
					    	<c:if test="${showSelfEdits || showCuratorEdits}">
                                <c:choose>
                                    <c:when test="${dataRows == 1 && displayLimit==1 }">
                                    	<%-- just put in a single "edit" link, not an "add" link that expands to reveal edit/delete links --%>
                                        <edLnk:editLinks item="${dataProp.dataPropertyStatements[0]}" icons="false"/>
                                    </c:when>
                                    <c:otherwise><%-- creates an add link, even if displayLimit is unset, i.e. -1 --%>
                                        <edLnk:editLinks item="${dataProp}" icons="false"/>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${displayLimit<0}">
                            	<%-- set to an arbitrary but high positive limit if unset on property, i.e. -1 --%>
                                <c:set var="displayLimit" value="32"/>
                            </c:if>
                            <c:if test="${fn:length(dataProp.dataPropertyStatements)-displayLimit==1}">
                                <%-- don't leave just one statement to expand --%>
                                <c:set var="displayLimit" value="${displayLimit+1}"/>
                            </c:if>
                            <%-- c:if test="${displayLimit < 0}"><c:set var="displayLimit" value="20"/></c:if --%>
                            <c:if test="${dataRows > 0}">
                                <div class="datatypeProperties">
                                    <c:if test="${dataRows > 1}"><ul class="datatypePropertyValue"></c:if>
                                    <c:if test="${dataRows == 1}"><div class="datatypePropertyValue"></c:if>
                                    <c:forEach items="${dataProp.dataPropertyStatements}" var="dataPropertyStmt">
                                        <p:process>
                                        <c:choose>
                                            <c:when test='${dataRows==1}'>
                                            	<c:if test='${displayLimit>1 && (showSelfEdits || showCuratorEdits)}'>
                                            	    <edLnk:editLinks item="${dataPropertyStmt}" icons="false"/>
                                            	</c:if>
                                            	${dataPropertyStmt.data}
                                            </c:when>
                                            <c:otherwise>
                                                <li>
                                                    <c:if test="${dataRows > 1 || displayLimit != 1 }">
                                                        <c:if test="${showSelfEdits || showCuratorEdits}">
                                                            <edLnk:editLinks item="${dataPropertyStmt}" icons="false"/>
                                                        </c:if>
                                                    </c:if>
                                                    ${dataPropertyStmt.data}
                                                </li>
                                            </c:otherwise>
                                        </c:choose>
                                        </p:process>
                                    </c:forEach>
                                    <c:choose>
                                    	<c:when test="${dataRows==1}"></div></c:when>
                                    	<c:otherwise></ul></c:otherwise>
                                    </c:choose>
                                </div><!-- datatypeProperties -->
                            </c:if>
						</div><!-- ${dataProp.localName} -->
						
<%					} else { // keyword property -- ignore
				    	if (p instanceof KeywordProperty) {%>
							<p>Not expecting keyword properties here.</p>
<%						} else {
    						log.warn("unexpected unknown property type found");%>
    						<p>Unknown property type found</p>
<%						}
					} 
				
				%><c:set var="counter" value="${counter+1}"/><%
    			
				} // end for (Property p : g.getPropertyList()
				%>
				</div><!-- propsWrap -->
			</div><!-- class="propsCategory" -->
			<c:if test="${showSelfEdits || showCuratorEdits}">
		    	<a class="backToTop" href="#wrap" title="jump to top of the page">back to top</a>
			</c:if>
<%		} // end for (PropertyGroup g : groupsList)
    } else {
        log.debug("incoming groups list with merged properties not found as request attribute for subject "+subject.getName()+"\n");
    }
%>

