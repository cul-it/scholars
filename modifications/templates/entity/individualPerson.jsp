<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.FakeSelfEditingIdentifierFactory"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.Identifier" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.IdentifierBundle" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.ServletIdentifierBundleFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.auth.identifier.SelfEditingIdentifierFactory"%>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="java.text.Collator" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.TreeSet" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/PropertyEditLink" prefix="edLnk" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://vitro.mannlib.cornell.edu/vitro/tags/StringProcessorTag" prefix="p" %>
<%@ page errorPage="/error.jsp"%>
<%! 
public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.templates.entity.individualPerson.jsp");
%>
<%
Individual entity = (Individual)request.getAttribute("entity");
if (entity == null){
    String e="individualPerson.jsp expects that request attribute 'entity' be set to the Individual object to display.";
    throw new JspException(e);
}

String netid = (String)session.getAttribute(FakeSelfEditingIdentifierFactory.FAKE_SELF_EDIT_NETID);
if (netid != null) {
    request.setAttribute("amIFaking",Boolean.TRUE);
}

if (VitroRequestPrep.isSelfEditing(request) /* || LoginFormBean.loggedIn(request, LoginFormBean.EDITOR)*/) {
    // attempt to tell whether a person is editing his or her own page, to control messages
    IdentifierBundle ids =
        ServletIdentifierBundleFactory.getIdBundleForRequest(request,session,pageContext.getServletContext());
    
    //get the selfEditingId
    SelfEditingIdentifierFactory.SelfEditing selfEditingId =
        SelfEditingIdentifierFactory.getSelfEditingIdentifier(ids);
    
    if( selfEditingId != null ){
        if (entity.getURI().equals(selfEditingId.getValue())) {
        	request.setAttribute("editingOwnPage",Boolean.TRUE);
        }
    }
    request.setAttribute("showSelfEdits",Boolean.TRUE);
}
%>
<c:if test="${sessionScope.loginHandler != null &&
              sessionScope.loginHandler.loginStatus == 'authenticated' &&
              sessionScope.loginHandler.loginRole >= sessionScope.loginHandler.editor}">
	<c:set var="showCuratorEdits" value="${true}"/>
	<c:set var="showKeywordEdits" value="${true}"/>
</c:if>
<c:set var="imageDir" value="images" />
<c:set var="themeDir"><c:out value="${portalBean.themeDir}" default="themes/vivo/"/></c:set>
<%
    //here we build up the url for the larger image.
    String imageUrl = null;
    if (entity.getImageFile() != null && 
        entity.getImageFile().indexOf("http:")==0) {
        imageUrl =  entity.getImageFile();
    } else {
        imageUrl = response.encodeURL( "/images/" + entity.getImageFile() );                     
    }

    // here we look for a property specific to VIVO and retrieve it's value
    boolean foundOverview = false;
    List<DataPropertyStatement> dataPropertyStatements = entity.getDataPropertyStatements();
    for (DataPropertyStatement dps : dataPropertyStatements) {
        if ("http://vivo.library.cornell.edu/ns/0.1#overviewStatement".equals(dps.getDatapropURI())) {
    	    if (dps.getData()!=null && dps.getData().trim().length()>0) {
    	    	foundOverview=true; %>
    	    	<c:set var="overviewStatement" value="<%=dps%>"/>
    	        <c:set var="overviewStatementData" value="<%=dps.getData().trim()%>"/>
<%   	        break; // only want 1 statement; should not be more than 1
    	    }
        }
    }
    if (!foundOverview) {
        VitroRequest vreq = new VitroRequest(request);
        WebappDaoFactory wdf = vreq.getWebappDaoFactory();
        DataProperty overviewDataProp = wdf.getDataPropertyDao().getDataPropertyByURI("http://vivo.library.cornell.edu/ns/0.1#overviewStatement");
        if (overviewDataProp == null) {
        	log.error("Error: cannot find overview statement data property \"http://vivo.library.cornell.edu/ns/0.1#overviewStatement\" for \"add\" link");
        } else {%>
        	<c:set var="overviewDataProperty" value="<%=overviewDataProp%>"/>
<%      }
    }
    
    // here we get any VIVO keywords (now a regular dataproperty) or, if empty, the traditional Vitro keywords
    TreeSet<String> keywordSet = new TreeSet<String>(new Comparator<String>() {
        public int compare( String first, String second ) {
            if (first==null) {
                return 1;
            }
            if (second==null) {
                return -1;
            }
            Collator collator = Collator.getInstance();
            return collator.compare(first,second);
        }
    });
    for (DataPropertyStatement dps : dataPropertyStatements) {
        if ("http://vivo.library.cornell.edu/ns/0.1#keyword".equals(dps.getDatapropURI())) {
    	    if (dps.getData()!=null && dps.getData().trim().length()>0) {
    	        keywordSet.add(dps.getData().trim());
    	    }
        }
    }
    String entityKeywordStr = null;
    if (keywordSet.size()>0) {
        Iterator iter = keywordSet.iterator();
        while (iter.hasNext()) {
	    	entityKeywordStr = (entityKeywordStr == null) ? (String)iter.next() : entityKeywordStr + ", " + (String)iter.next();
        }
    } else {
        entityKeywordStr = entity.getKeywordString();
    }
    if (entityKeywordStr != null && entityKeywordStr.trim().length()>0 ){%>
    	<c:set var="entityKeywordString" value="<%=entityKeywordStr%>"/>
<%  }
    //anytime we are at an entity page we shouldn't have an editing config or submission
    session.removeAttribute("editjson");
    EditConfiguration.clearAllConfigsInSession(session);
    EditSubmission.clearAllEditSubmissionsInSession(session);
%>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityPropsListJsp' value='/entityPropList'/>
<c:set var='entityMergedPropsListJsp' value='/entityMergedPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var="themeDir"><c:out value="${portalBean.themeDir}" default="themes/vivo/"/></c:set>

    <div id="personWrap">

    <jsp:include page="/${themeDir}jsp/dashboard.jsp" flush="true" />
    <div id="content" class="person"><!-- from templates/entity/individualPerson.jsp -->
        <c:if test="${editingOwnPage}">
            <p id="notice">Not sure where to start? Watch a short <a target="_blank" href="http://vivo.dev/documents/tutorials/selfediting_tutorial.htm">video tutorial</a> on how to edit your VIVO profile.</p>
        </c:if>
        <div class='contents entity'>
       		<div id="entity">
       		    <c:if test="${showCuratorEdits and !amIFaking}"><jsp:include page="entityAdmin.jsp"/></c:if>
       		    <c:if test="${!empty entity.imageThumb}">
                    <c:if test="${!empty entity.imageFile}">
                        <c:url var="imageUrl" value="/${imageDir}/${entity.imageFile}" />
                        <a class="image" href="${imageUrl}">
                    </c:if>
                    <c:url var="imageSrc" value='/${imageDir}/${entity.imageThumb}'/>
                    <c:if test="${!empty entity.citation}"><div id="profileImage"></c:if>
                    <img class="headshot" src="<c:out value="${imageSrc}"/>" title="click to view larger image in new window" alt="" width="150"/>
                    <c:if test="${!empty entity.imageFile}"></a></c:if>
                    <c:if test="${!empty entity.citation}"><div class="citation"><p:process>${entity.citation}</p:process></div></div><!-- profileImage --></c:if>
                </c:if>
       		    
                <h2><p:process>${entity.name}</p:process></h2> 
                <c:if test="${!empty entity.moniker}">
                    <p:process><em class="moniker">${entity.moniker}</em></p:process>
                </c:if>
            
            <c:if test="${showCuratorEdits || showSelfEdits}">
                <c:set var="loggedInClass" value="class='loggedIn'"/>
            </c:if>
            
        	<div id="overview" ${loggedInClass}>
        	    <c:choose>
            	    <c:when test="${!empty overviewStatementData}">
            		    ${overviewStatementData}
                   	    <c:if test="${showSelfEdits || showCuratorEdits}"><edLnk:editLinks item="${overviewStatement}" icons="false"/></c:if>
                    </c:when>
                    <c:when test="${(showSelfEdits && editingOwnPage) || showCuratorEdits}">
                    	<em>Note: this page lacks an overview statement.</em><edLnk:editLinks item="${overviewDataProperty}" icons='false'/>
                    </c:when>
                </c:choose>
        	</div>
	</div><!-- entity id -->
            <c:choose>
                <c:when test="${showCuratorEdits || showSelfEdits}">
                    <c:import url="${entityMergedPropsListJsp}">
                        <c:param name="mode" value="edit"/>
                        <c:param name="grouped" value="true"/>
                        <%-- unless a value is provided, properties not assigned to a group will not have a tab or appear on the page --%>
                        <c:param name="unassignedPropsGroupName" value=""/>
                    </c:import>
                </c:when>
                <c:otherwise>
                    <c:import url="${entityMergedPropsListJsp}">
                        <c:param name="grouped" value="true"/>
                    </c:import>
                </c:otherwise>
            </c:choose>

            <div class='description'>
                <p:process>${entity.blurb}</p:process>
            </div>
            <div class='description'>
                <p:process>${entity.description}</p:process>
            </div>  
             
	        <c:if test="${!empty entityKeywordString}">
    	        <div class="citation">
                    <%-- <a href="#keywords">&nbsp;</a> --%>
                    <strong>Keywords:</strong> <p:process>${entityKeywordString}</p:process>
                </div>
	        </c:if>
    	    ${requestScope.servletButtons} 
        </div> <!-- contents entity -->
    </div> <!-- content -->
    <div class="clear"></div>
    </div> <!-- innerwrap -->
