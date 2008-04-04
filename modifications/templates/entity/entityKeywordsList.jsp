<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.KeywordDao" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Keyword" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.KeywordIndividualRelation" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.KeywordIndividualRelationDao" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%
String themeDir="themes/vivo/";
if (VitroRequestPrep.isSelfEditing(request)) {
	themeDir = "themes/editdefault/";
} else if (!LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {%>
    <c:redirect url="/about.jsp"/>
<%
}
Individual ent = (Individual)request.getAttribute("entity");
if (ent==null) {
	throw new Error("no incoming entity in entityKeywordsList.jsp");
}
VitroRequest vreq = new VitroRequest(request);
WebappDaoFactory wdf = vreq.getWebappDaoFactory();
KeywordIndividualRelationDao kirDao = wdf.getKeys2EntsDao();
KeywordDao kDao = wdf.getKeywordDao();
List<KeywordIndividualRelation> kirs = kirDao.getKeywordIndividualRelationsByIndividualURI(ent.getURI());
if (kirs != null) {
    int keyCount=0;
    Iterator kirIt = kirs.iterator();
    while (kirIt.hasNext()) {
        KeywordIndividualRelation kir = (KeywordIndividualRelation) kirIt.next();
        if (kir.getKeyId() > 0) {
            Keyword k = kDao.getKeywordById(kir.getKeyId());
            if (k != null) {
                ++keyCount;
				if (keyCount==1) {%>
					<h3 class="propertyName">Keywords</h3>
					<c:url var="keyEditController" value="editForm">
					    <c:param name="home" value="${currentPortalId}"/>
                		<c:param name="individualURI" value="<%=ent.getURI()%>"/>
                		<c:param name="controller" value="Keys2Ents"/>
                		<c:param name="origin" value="user"/>
                		<c:param name="action" value="dashboardInsert"/>
                	</c:url>
                	<a class="add image"
                       href="${keyEditController}" title="add new"><img src="<%=themeDir%>site_icons/add_new.gif" alt="(add new)"/></a>
					<c:url var="keywordController" value="editForm">
					    <c:param name="home" value="${currentPortalId}"/>
                		<c:param name="individualURI" value="<%=ent.getURI()%>"/>
                		<c:param name="controller" value="Keyword"/>
                		<c:param name="Origin" value="user"/>
                		<c:param name="mode" value="visible"/>
<%						if (VitroRequestPrep.isSelfEditing(request)) { // set keyword as user-added %>
                			<c:param name="action" value="dashboardCreate"/>
<%						} else { // set keyword as curator-added %>
							<c:param name="action" value="curatorCreate"/>
<%						} %>
                	</c:url>
                	<a class="add image"
                       href="${keywordController}" title="create"><img src="<%=themeDir%>site_icons/add_new.gif" alt="(create)"/></a>
                       <div class="datatypePropertyValue">
<%				} else { %>
					<c:out value=", "/>
<%				} %>
                <c:url var="keyEditController" value="editForm">
                    <c:param name="uri" value="<%=kir.getURI()%>"/>
                	<c:param name="individualURI" value="<%=ent.getURI()%>"/>
                	<c:param name="controller" value="Keys2Ents"/>
                	<c:param name="home" value="${currentPortalId}"/>
<%					if (VitroRequestPrep.isSelfEditing(request)) { %>
                		<c:param name="action" value="dashboardDelete"/>
<%					} else { // do we want curators to control visibility? for now, do the same %>
						<c:param name="action" value="dashboardDelete"/>
<%					} %>
                </c:url>
                <c:out value="<%=k.getTerm()%>"/><a class="edit image"
                       href="${keyEditController}" title="edit"><img src="<%=themeDir%>site_icons/pencil.gif" alt="(edit)"/></a>
<% 			}
        }
    }%>
    </div><%
}
%>

