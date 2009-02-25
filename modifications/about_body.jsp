<%@ taglib prefix="form" uri="http://vitro.mannlib.cornell.edu/edit/tags" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>

<%@page import="edu.cornell.mannlib.vitro.webapp.dao.jena.pellet.PelletListener"%>
<jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ page errorPage="/error.jsp"%>
<%

    Portal portal = (Portal) request.getAttribute("portalBean");
    final String DEFAULT_SEARCH_METHOD = "fulltext"; /* options are fulltext/termlike */
    String loginD = (loginD = request.getParameter("login")) == null ? "block" : loginD.equals("null") || loginD.equals("") ? "block" : loginD;
%>

<c:set var='themeDir' ><c:out value='<%=portal.getThemeDir()%>' default='themes/default/'/></c:set>
<div id="content">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
<!-- ############################################################# start left block ########################################################### -->
    <td valign="top" width="20%" class="lightbackground" >
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr><!-- begin toc -->
    <td style="padding-left:10px;" height="300" id="aboutControlPane" class="lightbackground" valign="top" align="left">
    <div onclick="switchGroupDisplay('loginarea','loginSw','${themeDir}site_icons')" title="click to toggle login fields on or off" class="headerlink" onmouseover="onMouseOverHeading(this)" onmouseout="onMouseOutHeading(this)">
    <p style="font-size:0.9em;" class="normal"><% if ( loginD.equals("block")) { %><img src="${themeDir}site_icons/minus.gif" id="loginSw" alt="hide site administration login" /><% } else { %><img src="${themeDir}site_icons/plus.gif" id="loginSw" alt="show site administration login form" /><% } %>
    <i> site administration</i></p>
    </div>
<%  if (loginHandler.getLoginStatus().equals("authenticated")) { %>
       <div id="loginarea" class="pageGroupBody" style="display:block">
<%  } else { %>
        <div id="loginarea" class="pageGroupBody" style="display:<%=loginD%>">
<%  } %>

<%  if ( loginHandler.getLoginStatus().equals("authenticated")) {
        /* test if session is still valid */
        String currentSessionId = session.getId();
        String storedSessionId = loginHandler.getSessionId();
        if ( currentSessionId.equals( storedSessionId ) ) {
            String currentRemoteAddrStr = request.getRemoteAddr();
            String storedRemoteAddr = loginHandler.getLoginRemoteAddr();
            int securityLevel = Integer.parseInt( loginHandler.getLoginRole() );
            if ( currentRemoteAddrStr.equals( storedRemoteAddr ) ) {%>
                <strong>Logged In</strong><br/>
                User: <i><jsp:getProperty name="loginHandler" property="loginName" /></i><br/>
                <form class="old-global-form" name="logout" action="login_process.jsp" method="post">
                    <input type="hidden" name="home" value="<%=portal.getPortalId()%>"/>
                    <input type="submit" name="loginSubmitMode" value="Log Out" class="logout-button" />
                </form>
				<strong>${languageModeStr}</strong>
			<%
					Object plObj = getServletContext().getAttribute("pelletListener");
					if ( (plObj != null) && (plObj instanceof PelletListener) ) {
						PelletListener pelletListener = (PelletListener) plObj;
						if (!pelletListener.isConsistent()) {
							%>
								<p>
								<strong class="warning">
									INCONSISTENT ONTOLOGY: reasoning halted.
								</strong>
								</p>
								<p>
								<strong class="warning">
									Cause: <%=pelletListener.getExplanation()%>
								</strong>
								</p>
							<% 
						}
					}
				%>
                <h4><a href="listTabs?home=<%=portal.getPortalId()%>">Tabs</a></h4>
                <h4><a href="listGroups?home=<%=portal.getPortalId()%>">Class groups</a></h4>
                <h4><a href="listPropertyGroups?home=<%=portal.getPortalId()%>">Property groups</a></h4>
                <h4><a href="showClassHierarchy?home=<%=portal.getPortalId()%>">Root classes</a></h4>
                <h4><a href="showObjectPropertyHierarchy?home=${portalBean.portalId}&amp;iffRoot=true">Root object properties</a></h4>
                <h4><a href="showDataPropertyHierarchy?home=<%=portal.getPortalId()%>">Root data properties</a></h4>
                <h4><a href="listOntologies?home=<%=portal.getPortalId()%>">Ontologies</a></h4>
                <form class="old-global-form" action="editForm" method="get">
                    <select id="VClassURI" name="VClassURI" class="form-item">
                        <form:option name="VClassId"/>
                    </select>
                    <input type="submit" class="add-action-button" value="Add New Entity of above Type"/>
                    <input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
                    <input type="hidden" name="controller" value="Entity"/>
                </form>
<%              if (securityLevel>=4) { %>
                    <h4><a href="editForm?home=<%=portal.getPortalId()%>&amp;controller=Portal&amp;id=<%=portal.getPortalId()%>">Edit Current Portal</a></h4>
					<h4><a href="listPortals?home=<%=portal.getPortalId()%>">All Portals</a></h4>
<%              }
                if (securityLevel>=5) { %>
                    <h4><a href="listUsers?home=<%=portal.getPortalId()%>">Administer User Accounts</a></h4>
                    <h4><a href="admin/auditSelfEditingAgents.jsp?home=<%=portal.getPortalId()%>">Recent Self-Editors</a></h4>
                    <c:if test="${verbosePropertyListing == true}">
                        <h4><a href="about?verbose=false">Turn off Verbose Property Display</a></h4>
                    </c:if>
                    <c:if test="${empty verbosePropertyListing || verbosePropertyListing == false}">
                        <h4><a href="about?verbose=true">Turn on Verbose Property Display</a></h4>
                    </c:if>                    
<%              }       
                if (securityLevel>=50) { %>
                    <h4><a href="uploadRDFForm?home=<%=portal.getPortalId()%>">Add/Remove RDF Data</a></h4>
                    <%-- <h4><a href="refactorOp?home=<%=portal.getPortalId()%>&amp;modeStr=fixDataTypes">Realign Datatype Literals</a></h4> --%> 
                    <h4><a href="admin/sparqlquery">SPARQL Query</a></h4>
                    <h4><a href="ingest">Ingest Tools</a></h4>
<%              } %>
                <form class="old-global-form" name="logout" action="login_process.jsp" method="post">
                    <input type="hidden" name="home" value="\<\%=portal.getPortalId()\%\>" />
                    <input type="submit" name="loginSubmitMode" value="Log Out" class="logout-button" />
                </form>
<%          } else { %>
                <strong>Program Login</strong><br>
                <i>(IP address has changed)</i><br>
<%              loginHandler.setLoginStatus("logged out");
            }
        } else {
            loginHandler.setLoginStatus("logged out"); %>
            <strong>Program Login</strong><br/>
            <i>(session has expired)</i><br/>
            <form class="old-global-form" name="login" action="login_process.jsp" method="post" onsubmit="return isValidLogin(this) ">
            <input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
            Username:<input type="text" name="loginName" size="10" class="form-item"  /><br />
            Password:<input type="password" name="loginPassword" size="10" class="form-item" /><br />
            <input type="submit" name="loginSubmitMode" value="Log In" class="form-item" />
            </form>
<%      }
    } else { /* not thrown out by coming from different IP address or expired session; check login status returned by authenticate.java */ %>
        <strong>Program Login</strong><br/>
<%      if ( loginHandler.getLoginStatus().equals("logged out")) { %>
            <i>(currently logged out)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("bad_password")) { %>
            <i>(password incorrect)</i><br/>
<%      } else if ( loginHandler.getLoginStatus().equals("first_login_no_password")) { %>
            <i>(1st login; need to request initial password below)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("first_login_mistyped")) { %>
            <i>(1st login; initial password entered incorrectly)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("first_login_changing_password")) { %>
            <i>(1st login; changing to new private password)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("changing_password_repeated_old")) { %>
            <i>(changing to a different password)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("changing_password")) { %>
            <i>(changing to new password)</i>
<%      } else if ( loginHandler.getLoginStatus().equals("none")) { %>
            <i>(new session)</i><br/>
<%      } else { %>
            <i>(status unrecognized: <%=loginHandler.getLoginStatus()%>)</i><br/>
<%      } %>
        <p/>
        <form class="old-global-form" name="login" action="login_process.jsp" method="post" onsubmit="return isValidLogin(this) ">
        <input type="hidden" name="home" value="<%=portal.getPortalId()%>" />
        Username:<br />
<%      String status= loginHandler.getLoginStatus();
        if ( status.equals("bad_password") || status.equals("first_login_no_password")
            || status.equals("first_login_mistyped") || status.equals("first_login_changing_password")
            || status.equals("changing_password_repeated_old") || status.equals("changing_password") ) { %>
            <input type="text" name="loginName" value='<%=loginHandler.getLoginName()%>' size="10" class="form-item" /><br />
<%      } else { %>
            <input type="text" name="loginName" size="10" class="form-item" /><br />
<%      } %>
        Password:
        <font color="red"><%=loginHandler.getErrorMsg("loginPassword")%></font><br />
        <input type="password" name="loginPassword" size="10" class="form-item" /><br />
        <input type="submit" name="loginSubmitMode" value="Log In" class="form-item" />
        </form>
<%      } %>
        </div>
        </td>
        <!-- end toc -->
        </tr>
       </table>
       </td>

       <c:set var="loginStatus" value="<%=loginHandler.getLoginStatus()%>"/>
       <c:set var="securityLevel" value="<%=Integer.parseInt(loginHandler.getLoginRole())%>"/>
       <c:set var="userName"><jsp:getProperty name="loginHandler" property="loginName" /></c:set>
       
       <c:choose>
       <c:when test="${loginStatus == 'authenticated' && securityLevel >= 4}">
            <c:catch var="includeError">
               <jsp:include page="about_collabArea.jsp">
                    <jsp:param name="level" value="${securityLevel}"/>
                    <jsp:param name="user" value="${userName}"/>
                </jsp:include>
            </c:catch>
            <c:if test="${!empty includeError}">
                <td><p>There was a problem loading the content for this page. Contact <a href="mailto:mw542@cornell.edu">Miles Worthington</a> if this continues.</p></td>
                <% System.out.println("Error loading about_collabArea.jsp in about_body.jsp: " + pageContext.getAttribute("includeError")); %>
            </c:if>
       </c:when>
       <c:otherwise>
            <!-- ##################################################end left block, start center block ########################################################### -->
                    <td colspan="1" width="40%" valign="top" >
            <%                  String aboutText=portal.getAboutText();
                                if (aboutText!=null && !aboutText.equals("")) {%>
                                    <div class="pageGroupBody"><%=aboutText%></div>
            <%                }
            %>    

                    </td>
            <!-- #################################################### end center block, start right block ########################################################### -->
                    <td colspan="1" width="40%" valign="top" class="lightbackground2">
            <%                  String ackText=portal.getAcknowledgeText();
                                if (ackText!=null && !ackText.equals("")) {%>
                                    <div class="pageGroupBody"><%=ackText%></div>
            <%                  }
            %>
                    </td>
            <!-- ############################################################# end right block ########################################################### -->
        </c:otherwise>
        </c:choose>
       </tr>
    <!--/table--><!--end main page table -->
</table>
</div> <!-- content -->
