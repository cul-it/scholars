<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Link" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.ObjectPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.DataPropertyDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatementImpl" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.text.Collator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page errorPage="/error.jsp"%>
<%
if (VitroRequestPrep.isSelfEditing(request)) {
    request.setAttribute("showSelfEdits",Boolean.TRUE );
}

VitroRequest vreq = new VitroRequest(request);
WebappDaoFactory wdf = vreq.getWebappDaoFactory();

ObjectProperty linkObjectProp = wdf.getObjectPropertyDao().getObjectPropertyByURI(VitroVocabulary.ADDITIONAL_LINK);
if (linkObjectProp != null) {%>
	<c:set var="additionalLinkObjectProperty" value="<%=linkObjectProp%>"/>
<%
}

DataProperty keywordDataProp = wdf.getDataPropertyDao().getDataPropertyByURI("http://vivo.library.cornell.edu/ns/0.1#keyword");
if (keywordDataProp != null) {%>
	<c:set var="keywordDataProperty" value="<%=keywordDataProp%>"/>
<%
}

Individual indiv = (Individual)request.getAttribute("entity"); // already tested for null in individualPerson.jsp

//here we get any VIVO keywords (now a regular dataproperty)
List<DataPropertyStatement> dataPropertyStatements = indiv.getDataPropertyStatements();
List<DataPropertyStatement> keywordStmts= new ArrayList<DataPropertyStatement>();
for (DataPropertyStatement dps : dataPropertyStatements) {
    if ("http://vivo.library.cornell.edu/ns/0.1#keyword".equals(dps.getDatapropURI())) {
	    if (dps.getData()!=null && dps.getData().trim().length()>0) {
	        keywordStmts.add(dps);
	    }
    }
}
if (keywordStmts.size()>1) { // now sort the keywords, which do not retain an inherent sort order
	Collections.sort(keywordStmts,new Comparator<DataPropertyStatement>() {
        public int compare( DataPropertyStatement first, DataPropertyStatement second ) {
            if (first==null || first.getData()==null) {
                return 1;
            }
            if (second==null || second.getData()==null) {
                return -1;
            }
            Collator collator = Collator.getInstance();
            return collator.compare(first.getData(),second.getData());
        }
    });
}

%>
<c:set var="keywordStatements" value="<%=keywordStmts%>"/>

<c:if test="${sessionScope.loginHandler != null &&
             sessionScope.loginHandler.loginStatus == 'authenticated' &&
             sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
    <c:set var="showCuratorEdits" value="true"/>
</c:if>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='dashboardPropsListJsp' value='/dashboardPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var='imageDir' value='images' />
<c:set var="thumbnailSize" value="S"/>
<div id="dashboard"<c:if test="${showCuratorEdits || showSelfEdits}"> class="loggedIn"</c:if>>
   
    <c:choose>
        <c:when test="${showSelfEdits || showCuratorEdits}">
            <c:import url="${dashboardPropsListJsp}">
       	        <%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
                <c:param name="unassignedPropsGroupName" value=""/>
                <c:param name="grouped" value="true"/>
                <c:param name="allProps" value="true"/>
            </c:import>
        </c:when>
        <c:otherwise>
            <c:import url="${dashboardPropsListJsp}">
       	        <%-- unless a value is provided, properties not assigned to a group will not appear on the dashboard --%>
                <c:param name="unassignedPropsGroupName" value=""/>
                <c:param name="grouped" value="true"/>
                <c:param name="allProps" value="false"/> 
            </c:import>
        </c:otherwise>
    </c:choose>
    
    <c:if test="${(!empty entity.anchor) || (!empty entity.linksList) || showSelfEdits || showCuratorEdits}">
    
        <c:choose>
            <%-- for this to work, the vivo:CornellemailnetId data property must be publicly visible (but not in a property group, to avoid direct display) --%>
    		<c:when test="${!empty entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId'].dataPropertyStatements[0].data}">
                <c:set var="emailAddress" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#CornellemailnetId'].dataPropertyStatements[0].data}"/>
                <c:set var="netId" value="${fn:substringBefore(emailAddress,'@')}"/>
                <div id="currentContactInfo">
        	        <c:url var="CUSearchUrl" value="http://www.cornell.edu/search/index.cfm">
        		        <c:param name="tab" value="people"/>
        		        <c:param name="netid" value="${netId}"/>
        	        </c:url>
        	        <strong class="contactLink"><a class="externalLink" title="contact info at cornell.edu" href="${CUSearchUrl}">current contact information</a></strong>
       	        </div>
            </c:when>
            <c:otherwise>
             	<c:if test="${!empty entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#nonCornellemail'].dataPropertyStatements[0].data}">
                	<c:set var="emailAddress" value="${entity.dataPropertyMap['http://vivo.library.cornell.edu/ns/0.1#nonCornellemail'].dataPropertyStatements[0].data}"/>
                	<c:if test="${fn:containsIgnoreCase(emailAddress,'@med.cornell.edu')}">
        	            <div id="currentContactInfo">
         	                <c:url var="CUMedSearchUrl" value="http://www.cornell.edu/search/index.cfm">
        		                <c:param name="tab" value="people"/>
        		                <c:param name="q" value="${emailAddress}"/>
        	                </c:url>
        	                <strong class="contactLink"><a class="externalLink" title="contact info at cornell.edu" href="${CUMedSearchUrl}">current contact information</a></strong>
        	            </div>
                	</c:if>
            	</c:if>
             </c:otherwise>
        </c:choose>
    
        <div id="dashboardExtras">

            <div id="links">
            <c:if test="${showSelfEdits || showCuratorEdits}">
                <h3>Links</h3>
                <edLnk:editLinks item="${additionalLinkObjectProperty}" icons="false"/>
                <c:set var="thumbnailSize" value="T"/>
            </c:if>
                <c:if test="${!empty entity.anchor}">
                    <ul class="profileLinks">
                        <c:choose>
                            <c:when test="${!empty entity.url}">
                                <c:url var="entityUrl" value="${entity.url}" />
                                <c:url var="webSnaprUrl" value="http://mannlib.websnapr.com/">
                                    <c:param name="size" value="${thumbnailSize}"/>
                                    <c:param name="url" value="${entityUrl}"/>
                                </c:url>
                                <li class="first">
                                    <a href="<c:out value="${entityUrl}"/>">
                                        <img class="screenshot" alt="page screenshot" src="${webSnaprUrl}"/>
                                    </a>
                                    <a class="externalLink" href="<c:out value="${entityUrl}"/>">
                                        <p:process>${entity.anchor}</p:process>
                                    </a>
                                    <c:if test="${showSelfEdits || showCuratorEdits}">
                                    	<edLnk:editLinks item="${entity.primaryLink.objectPropertyStatement}" icons="false"/>
                                    </c:if>
                                </li>
                                <%--                            
                                <c:url var="entityUrl" value="${entity.url}" />
                                <li>
                                    <a class="externalLink" href="<c:out value="${entityUrl}"/>">${entity.anchor}</a>
                                    <c:if test="${showSelfEdits || showCuratorEdits}">
                                    	<edLnk:editLinks item="${entity.primaryLink.objectPropertyStatement}" icons="false"/>
                                    </c:if>
                                </li>
                                --%>
                            </c:when>
                            <c:otherwise><li>${entity.anchor}</li></c:otherwise>
                        </c:choose>
                    </c:if>
                    <c:if test="${!empty entity.linksList }">
                        <c:forEach items="${entity.linksList}" var='link'>
                            <c:url var="linkUrl" value="${link.url}" />
                            <c:url var="webSnaprUrl2" value="http://mannlib.websnapr.com/">
                                <c:param name="size" value="${thumbnailSize}"/>
                                <c:param name="url" value="${link.url}"/>
                            </c:url>
                            <li>
                                <a href="<c:out value="${link.url}"/>">
                                    <img class="screenshot" alt="page screenshot" src="${webSnaprUrl2}"/>
                                </a>
                                <a class="externalLink" href="<c:out value="${link.url}"/>">
                                    <p:process>${link.anchor}</p:process>
                                </a>
                                <c:if test="${showSelfEdits || showCuratorEdits}">
                                    <edLnk:editLinks item="${link.objectPropertyStatement}" icons="false"/>
                                </c:if>
                            </li>
                            <%--
                            <li>
                                <c:if test="${showSelfEdits || showCuratorEdits}">
                                    <edLnk:editLinks item="${link.objectPropertyStatement}" icons="false"/>
                                </c:if>
                                <a class="externalLink" href="<c:out value="${linkUrl}"/>">${link.anchor}</a>
                            </li>
                            --%>
                        </c:forEach>
                    </ul>
                </c:if>
            </div>
                        
            <c:choose>
            	<c:when test="${showSelfEdits || showCuratorEdits}">
                    <div id="keywords">
                        <h3>Keywords</h3><edLnk:editLinks item="${keywordDataProperty}" icons="false"/>
                        <c:if test="${!empty keywordStatements}">
                            <ul class="keywords">
        	                    <c:forEach items="${keywordStatements}" var="dataPropertyStmt">
            	                    <li>
            	                        <c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${dataPropertyStmt}" icons="false"/></c:if>
            	                        ${dataPropertyStmt.data}
            	                    </li>
                                </c:forEach>
                            </ul>
                       </c:if>    
                    </div>
                </c:when>
                <c:otherwise>
                    <c:if test="${!empty keywordStatements}">
                        <div id="keywords">
                            <h3>Keywords</h3>
                            <ul class="keywords">
        	                    <c:forEach items="${keywordStatements}" var="dataPropertyStmt">
            	                    <li>${dataPropertyStmt.data}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
         </div><!-- dashboardExtras -->
    </c:if>
</div><!-- dashboard -->