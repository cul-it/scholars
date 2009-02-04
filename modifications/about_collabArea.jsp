<%@ page import="org.apache.commons.httpclient.HttpClient" %>
<%@ page import="org.apache.commons.httpclient.auth.AuthScope" %>
<%@ page import="org.apache.commons.httpclient.UsernamePasswordCredentials" %>
<%@ page import="org.apache.commons.httpclient.methods.GetMethod" %>
<%@ page import="org.apache.commons.httpclient.methods.PostMethod" %>
<%@ page import="org.joda.time.DateTime" %>
<%@ page import="org.joda.time.Period" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:choose>
<c:when test="${!empty param.redirect}">
    <%-- this weird redirect lets authenticated VIVO users access Mint stats with this homemade cookie --%>
    <jsp:useBean id="loginHandler" class="edu.cornell.mannlib.vedit.beans.LoginFormBean" scope="session" />
    <c:set var="loginStatus" value="<%=loginHandler.getLoginStatus()%>"/>
    <c:if test="${loginStatus == 'authenticated'}">
    <% String password = "ce135a8d1b2af5c4478128c7cef22432";
    Cookie thinmint = new Cookie ("MintAuth",password);
    thinmint.setMaxAge(10);
    thinmint.setDomain(".cornell.edu");
    thinmint.setPath("/");
    response.addCookie(thinmint);
    %>
    <c:redirect url="http://vivostats.mannlib.cornell.edu"/>
    </c:if>
</c:when>

<c:when test="${!empty param.level && !empty param.user}">

<%-- All the basecamp-related stuff here relies on VIVO usernames matching basecamp usernames (mw542) --%>

<c:set var="vivoUser" value="${param.user}"/>
<%-- <c:set var="vivoUser" value="miles"/> --%>
<c:set var="vivoLevel" value="${param.level}"/>
<%-- <c:set var="vivoLevel" value="50"/> --%>
<c:set var="thisContext" value="<%=request.getContextPath()%>"/>

<%
  DateTime now = new DateTime();
  DateTime prevDay = now.minus(Period.days(1));
  DateTime nextDay = now.plus(Period.days(1));
  String currently = now.toString("yyyy-MM-dd'T'HH:mm:ss'Z'");
  String yesterday = prevDay.toString("yyyy-MM-dd'T'HH:mm:ss'Z'");
  String tomorrow = nextDay.toString("yyyy-MM-dd'T'HH:mm:ss'Z'");
%>

<fmt:parseDate var="currDate" value="<%=currently%>" pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" />
<fmt:parseDate var="yestDate" value="<%=yesterday%>" pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" />
<fmt:parseDate var="tomDate" value="<%=tomorrow%>" pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" />
<fmt:formatDate var="today" dateStyle="short" value="${currDate}"/>
<fmt:formatDate var="yesterday" dateStyle="short" value="${yestDate}"/>
<fmt:formatDate var="tomorrow" dateStyle="short" value="${tomDate}"/>

<% 
// set up the authentication for basecamp
HttpClient client = new HttpClient();
client.getState().setCredentials(
    new AuthScope("mannits.projectpath.com", -1),
    new UsernamePasswordCredentials("vivoguest", "8455guest")
);
client.getState().setAuthenticationPreemptive(true);

String msgList="";
String milestoneList="";
String peopleList="";
String todoAssigned="";
String allTodoLists="";
String todoPersonal="";

// get all messages in project
GetMethod msg = new GetMethod("http://mannits.projectpath.com/projects/1313498/posts.xml");
msg.setDoAuthentication( true );
msg.setRequestHeader("Accept", "application/xml");
try {
    int msgHttpResult = client.executeMethod( msg );
/*    System.out.println("Messages response: " + msgHttpResult);*/
    msgList = msg.getResponseBodyAsString();
} finally {
    msg.releaseConnection();
}

// get upcoming milestones
PostMethod ms = new PostMethod("http://mannits.projectpath.com/projects/1313498/milestones/list");
String reqBody = "<find>upcoming</find>";
ms.setDoAuthentication( true );
ms.setRequestBody(reqBody);
ms.setRequestHeader("Content-type", "application/xml");
ms.addRequestHeader("Accept", "application/xml");
try {
    int msHttpResult = client.executeMethod( ms );
/*    System.out.println("Milestones response: " + msHttpResult);*/
    milestoneList = ms.getResponseBodyAsString();
} finally {
    ms.releaseConnection();
}

// get all people in project
GetMethod ppl = new GetMethod("http://mannits.projectpath.com/contacts/people/705397/");
ppl.setDoAuthentication( true );
ppl.setRequestHeader("Accept", "application/xml");
try {
    int pplHttpResult = client.executeMethod( ppl );
/*    System.out.println("People response: " + pplHttpResult);*/
    peopleList = ppl.getResponseBodyAsString();
} finally {
    ppl.releaseConnection();
}%>

<c:catch var="msgError">
    <x:parse var="bcMessages" doc="<%=msgList%>" />
    <c:set var="bcMessagesTest"><x:out select="$bcMessages//post" /></c:set>
</c:catch>
<c:catch var="msError">
    <x:parse var="bcMilestones" doc="<%=milestoneList%>" />
    <c:set var="bcMilestonesTest"><x:out select="$bcMilestones//milestone" /></c:set>
</c:catch>
<c:catch var="pplError">
    <x:parse var="bcPeople" doc="<%=peopleList%>" />
    <c:set var="bcPeopleTest"><x:out select="$bcPeople//person" /></c:set>
</c:catch>

<%-- <p>messages: ${bcMessagesTest}</p>
<p>milestones: ${bcMilestonesTest}</p>
<p>people: ${bcPeopleTest}</p> --%>

<c:if test="${!empty bcPeopleTest}">
    <%-- check to see whether the current vivo user is also a basecamp user --%>
    <x:set var="bcUser" select="$bcPeople//person[user-name=$pageScope:vivoUser]"/>
    <c:set var="bcID"><x:out select="$bcUser//id"/></c:set>
    <c:set var="bcUsername"><x:out select="$bcUser//user-name"/></c:set>
    <c:set var="bcFullname"><x:out select="$bcUser//first-name"/>${" "}<x:out select="$bcUser//last-name"/></c:set>
</c:if>

<c:if test="${bcID != ''}">
    <% 
    // get todo items assigned to current user
    String basecampID = (String)pageContext.getAttribute("bcID");
    if (basecampID.length() > 1){
        GetMethod todo = new GetMethod("http://mannits.projectpath.com/todo_lists.xml?responsible_party="+basecampID);
        todo.setDoAuthentication( true );
        todo.setRequestHeader("Accept", "application/xml");
        try {
            int todoHttpResult = client.executeMethod( todo );
/*            System.out.println("Todo (assigned) response: " + todoHttpResult);*/
            todoAssigned = todo.getResponseBodyAsString();
        } finally {
            todo.releaseConnection();
        }

        // get all todo lists with pending items
        GetMethod todo2 = new GetMethod("http://mannits.projectpath.com/projects/1313498/todo_lists.xml?filter=pending");
        todo2.setDoAuthentication( true );
        todo2.setRequestHeader("Accept", "application/xml");
        try {
            int todo2HttpResult = client.executeMethod( todo2 );
/*            System.out.println("Todo (all lists) response: " + todo2HttpResult);*/
            allTodoLists = todo2.getResponseBodyAsString();
        } finally {
            todo2.releaseConnection();
        }
    }%>

    <c:catch var="todoAssignedError">
        <x:parse var="bcTodoAssigned" doc="<%=todoAssigned%>" />
        <c:set var="bcTodoAssignedTest"><x:out select="$bcTodoAssigned//todo-item" /></c:set>
    </c:catch>
    <c:catch var="todoAllError">
        <x:parse var="bcAllTodo" doc="<%=allTodoLists%>" />
        <c:set var="bcAllTodoTest"><x:out select="$bcAllTodo//todo-list" /></c:set>
    </c:catch>
    
    <c:if test="${!empty bcAllTodoTest}">
        <%-- check to see if one of the todo lists has a name that matches the current user's name --%>
        <%-- <x:set var="bcTodo" select="$bcAllTodo//todo-list[name=$pageScope:bcFullname]"/> --%>
        <c:set var="personalListID" value=""/>
        <x:forEach var="list" select="$bcAllTodo//todo-list">
            <c:set var="thisName"><x:out select="name"/></c:set>
            <c:if test="${fn:contains(thisName,bcFullname)}">
                <c:set var="personalListID"><x:out escapeXml="false" select="id"/></c:set>
            </c:if>
        </x:forEach>
        <%-- <c:set var="personalListID"><x:out escapeXml="false" select="$bcTodo/id"/></c:set> --%>
    </c:if>

    <% // get items for current user's personal todo list (if it exists)
    String listID = (String)pageContext.getAttribute("personalListID");
    if(listID.length() > 1) {
    	GetMethod todo3 = new GetMethod("http://mannits.projectpath.com/todo_lists/" + listID +"/todo_items.xml");
    	todo3.setDoAuthentication( true );
    	todo3.setRequestHeader("Accept", "application/xml");
    	try {
    	    int todo3HttpResult = client.executeMethod( todo3 );
/*          System.out.println("Todo (personal) response: " + todo3HttpResult);*/
    	    todoPersonal = todo3.getResponseBodyAsString();
    	} finally {
    	    todo3.releaseConnection();
    	}
    }%>
    <c:catch var="todoPersonalError">
        <c:if test="${!empty personalListID}">
            <x:parse var="bcTodoPersonal" doc="<%=todoPersonal%>" />
            <c:set var="bcTodoPersonalTest"><x:out select="$bcTodoPersonal//todo-item" /></c:set>
        </c:if>
    </c:catch>
</c:if>

<%-- <p>assigned todo: ${bcTodoAssignedTest}</p>
<p>all todo: ${bcAllTodoTest}</p>
<p>personal todo: ${bcTodoPersonalTest}</p> --%>

<c:set var="jiraUser" value=""/>
<c:if test="${vivoUser == 'brian'}"><c:set var="jiraUser" value="bdc34@cornell.edu"></c:set></c:if>
<c:if test="${vivoUser == 'bjl23'}"><c:set var="jiraUser" value="bjl23"></c:set></c:if>
<c:if test="${vivoUser == 'jc55'}"><c:set var="jiraUser" value="jc55"></c:set></c:if>

<c:if test="${jiraUser != ''}">
    <c:url var="jiraVitroUrl" value="http://issues.library.cornell.edu/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml">
    	<c:param name="pid" value="10013" />
    	<c:param name="resolution" value="-1" />
    	<c:param name="sorter/field" value="updated" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="sorter/field" value="duedate" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="sorter/field" value="priority" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="tempMax" value="1000" />
    	<c:param name="os_username" value="vivoguest" />
    	<c:param name="os_password" value="1954guest" />
    	<c:param name="assigneeSelect" value="specificuser" />
    	<c:param name="assignee" value="${jiraUser}" />
    </c:url>

    <c:url var="jiraVivoUrl" value="http://issues.library.cornell.edu/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml">
    	<c:param name="pid" value="10230" />
    	<c:param name="resolution" value="-1" />
    	<c:param name="sorter/field" value="updated" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="sorter/field" value="duedate" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="sorter/field" value="priority" />
    	<c:param name="sorter/order" value="DESC" />
    	<c:param name="tempMax" value="1000" />
    	<c:param name="os_username" value="vivoguest" />
    	<c:param name="os_password" value="1954guest" />
    	<c:param name="assigneeSelect" value="specificuser" />
    	<c:param name="assignee" value="${jiraUser}" />
    </c:url>

    <c:catch var="jiraVitroError">
        <c:import var="jiraVitroFeed" url="${jiraVitroUrl}"/>
        <x:parse var="jiraVitro" doc="${jiraVitroFeed}"/>
    </c:catch>
    
    <c:catch var="jiraVivoError">
        <c:import var="jiraVivoFeed" url="${jiraVivoUrl}"/>
        <x:parse var="jiraVivo" doc="${jiraVivoFeed}"/>
    </c:catch>
</c:if>

<%-- LEFT column --%>
<c:choose>
    <%-- basecamp users --%>
    <c:when test="${!empty bcID && empty jiraUser}">
        <td class="collabArea" id="leftColumn">
        <div id="collabLeft">
            <h2><a title="open basecamp to-do lists" href="http://mannits.projectpath.com/projects/1313498/todo_lists?responsible_party=">To-Do</a></h2>
            <c:if test="${!empty bcTodoPersonalTest}">
                <h3><a title="open personal to-do list" href="http://mannits.projectpath.com/projects/1313498/todo_lists/${personalListID}/?responsible_party=">personal</a></h3>
                <ul><x:forEach select="$bcTodoPersonal//todo-item">
                    <x:if select="completed != 'true'">
                        <c:set var="listID"><x:out escapeXml="false" select="todo-list-id" /></c:set>
                        <c:set var="itemContent"><x:out escapeXml="true" select="content" /></c:set>
                        <c:set var="listUrl" value="http://mannits.projectpath.com/projects/1313498/todo_lists/${listID}/?responsible_party="/>
                        <li><a title="open this in basecamp" href="${listUrl}">${itemContent}</a></li>
                    </x:if>
                </x:forEach></ul>
            </c:if>

            <c:if test="${!empty bcTodoAssignedTest}">
                <h3><a title="open assigned to-do list" href="http://mannits.projectpath.com/projects/1313498/todo_lists?responsible_party=${bcID}">assigned</h3>
                <ul><x:forEach select="$bcTodoAssigned//todo-item">
                    <x:if select="completed != 'true'">
                        <c:set var="listID"><x:out escapeXml="false" select="../../id" /></c:set>
                        <c:set var="itemContent"><x:out escapeXml="true" select="content" /></c:set>
                        <c:set var="listUrl2" value="http://mannits.projectpath.com/projects/1313498/todo_lists/${listID}?responsible_party="/>
                        <li><a title="open this in basecamp" href="${listUrl2}">${itemContent}</a></li>
                    </x:if>
                </x:forEach></ul>
            </c:if>
            
            <c:if test="${empty bcTodoPersonalTest && empty bcTodoAssignedTest}">
                <p style="margin-left: 12px; font-size: 1.1em;">You don't have anything to do.<br/><br/>Read about <a href="http://mannits.projectpath.com/projects/1313498/posts/17995341/">how these lists work</a>.</p>
            </c:if>
        <div id="mintLink" style="margin: 40px 2px 0 2px; padding: 4px 0; border-top: 2px solid #B6CED9;"><a href="${thisContext}/about_collabArea.jsp?redirect=true">View VIVO Statistics</a></div>
        </div>
        </td>
    </c:when>
        
        <%-- jira and basecamp users --%>
    <c:when test="${!empty jiraUser}">
        <td class="collabArea" id="leftColumn">
        <div id="collabLeft">
            <h2><a title="open jira" href="http://issues.library.cornell.edu/">To-Do</a></h2>
            	<x:if select="$jiraVitro//item">
            	<h3><a title="open project in jira" href="http://issues.library.cornell.edu/browse/VITRO">Vitro</a></h3>
            		<ul class="jiraList"><x:forEach select="$jiraVitro//item[position()<9]">
            		    <c:set var="issueTitle"><x:out escapeXml="true" select="title"/></c:set>
            		    <c:set var="issueLink"><x:out escapeXml="false" select="link"/></c:set>
            			<li><a title="open in jira" href="${issueLink}">${issueTitle}</a></li>
            		</x:forEach></ul>
            	</x:if>

            	<x:if select="$jiraVivo//item">
            	<h3><a title="open project in jira" href="http://issues.library.cornell.edu/browse/VIVO">VIVO</a></h3>
            		<ul class="jiraList"><x:forEach select="$jiraVivo//item[position()<5]">
            		    <c:set var="issueTitle"><x:out escapeXml="true" select="title"/></c:set>
            		    <c:set var="issueKey"><x:out escapeXml="true" select="key"/></c:set>
            		    <c:set var="issueUrl" value="http://issues.library.cornell.edu/browse/${issueKey}"/>
            			<li><a title="open in jira" href="${issueUrl}">${issueTitle}</a></li>
            		</x:forEach></ul>
            	</x:if>
            	
            	<c:if test="${!empty bcID}">
            	    <c:if test="${!empty bcTodoAssignedTest}">
            	    <h3><a title="open project in basecamp" href="http://mannits.projectpath.com/projects/1313498/">Basecamp</h3>
                	    <ul class="jiraList"><x:forEach select="$bcTodoAssigned//todo-item">
                            <c:set var="listID"><x:out escapeXml="false" select="../../id" /></c:set>
                            <c:set var="itemContent"><x:out escapeXml="true" select="content" /></c:set>
                            <c:set var="listUrl" value="http://mannits.projectpath.com/projects/1313498/todo_lists/${listID}"/>
                            <li><a title="open this in basecamp" href="${listUrl}">${itemContent}</a></li>
                        </x:forEach></ul>
                    </c:if>
                </c:if>
            <div id="mintLink"><a href="${thisContext}/about_collabArea.jsp?redirect=true">View VIVO Statistics</a></div>
    	</div>
        </td>
    </c:when>
        
    <%-- non-campers and non-jira users --%>
    <c:otherwise>
        <td colspan="1" width="40%" valign="top" >
            <div class="pageGroupBody"><p>VIVO (not an acronym) brings together in one site publicly available information on the people, departments, graduate fields, facilities, and other resources that collectively make up the research and scholarship environment in all disciplines at Cornell.</p>
            <p>Search VIVO for information about faculty, departments and research units, undergraduate majors, graduate fields, courses, research services and facilities --- anything related to academic and research pursuits at Cornell.</p><p>VIVO is currently in <strong>pilot release</strong> and may be missing significant content or relationships.	
            Please <a href="comments?home=1">contact us</a> with any corrections, comments or suggestions for improvement. VIVO runs on the <a href="http://vitro.mannlib.cornell.edu/">Vitro</a> ontology editor and semantic web application software.</p>
            </div>
        </td>
    </c:otherwise>
</c:choose>



<%-- RIGHT column --%>

<c:choose>
    <c:when test="${!empty bcID}">
        <td class="collabArea">
        <div id="collabRight">
            <c:if test="${!empty bcMilestonesTest}">
                <h2><a title="open milestones in basecamp" href="http://mannits.projectpath.com/projects/1313498/milestones">Upcoming</a></h2>
        	    <ul><x:forEach select="$bcMilestones//milestone">
                    <c:set var="msTitle"><x:out escapeXml="true" select="title"/></c:set>
                    <c:set var="msLink" value="http://mannits.projectpath.com/projects/1313498/milestones"/>
                    <fmt:parseDate var="msDate" pattern="yyyy-MM-dd"><x:out escapeXml="true" select="deadline"/></fmt:parseDate>
                    <fmt:formatDate var="milestoneDate" dateStyle="short" value="${msDate}"/>
                    <li>
                        <strong>
                            <c:choose>
                            <c:when test="${milestoneDate == today}">Today:</c:when>
                            <c:when test="${milestoneDate == tomorrow}">Tomorrow:</c:when>
                            <c:otherwise><fmt:formatDate pattern="MMM d" value="${msDate}"/>:</c:otherwise>
                            </c:choose>
                        </strong> 
                        <a title="open milestones in basecamp" href="${msLink}">${msTitle}</a>
                    </li>

                </x:forEach></ul>
            </c:if>
            
            <c:if test="${!empty bcMessagesTest}">
                <h2><a title="open messages in basecamp" href="http://mannits.projectpath.com/projects/1313498/posts">Messages</a></h2>
                <ul><x:forEach select="$bcMessages//post">
                    <c:set var="msgTitle"><x:out escapeXml="true" select="title"/></c:set>
                    <c:set var="msgID"><x:out escapeXml="true" select="id"/></c:set>
                    <c:set var="msLink" value="http://mannits.projectpath.com/projects/1313498/posts/${msgID}/" />
                    <c:set var="msgAuthor"><x:out escapeXml="true" select="author-name"/></c:set>
                    <c:set var="msgComments"><x:out escapeXml="true" select="comments-count"/></c:set>
                    <fmt:parseDate pattern="yyyy-MM-dd'T'HH:mm:ss'Z'" var="msgDate" timeZone="GMT"><x:out escapeXml="true" select="posted-on"/></fmt:parseDate>
                    <fmt:formatDate var="messageDate" dateStyle="short" value="${msgDate}"/>
                    <li>
                        <p><a title="read in basecamp" href="${msLink}">${msgTitle}</a></p>
                        <span>by <strong>${msgAuthor}</strong> &ndash;  
                        
                            <c:choose>
                                <c:when test="${messageDate == today}">Today</c:when>
                                <c:when test="${messageDate == yesterday}">Yesterday</c:when>
                                <c:otherwise><fmt:formatDate pattern="EEE" value="${msgDate}"/>, <fmt:formatDate pattern="MMM d" value="${msgDate}"/></c:otherwise>
                            </c:choose> @ <fmt:formatDate pattern="h:mm a" value="${msgDate}"/>
                            <c:if test="${msgComments == 1}"> (${msgComments} comment)</c:if>
                            <c:if test="${msgComments > 1}"> (${msgComments} comments)</c:if>
                        </span>
                </x:forEach></ul>
            </c:if>
        </div>
        </td>
    </c:when>
        
    <c:otherwise>
        <td colspan="1" width="40%" valign="top" class="lightbackground2">
            <%-- <object width="160" height="250" ><param name="movie" value="http://widget.meebo.com/mm.swf?zPOfFapnxB"/><embed src="http://widget.meebo.com/mm.swf?zPOfFapnxB" type="application/x-shockwave-flash" width="160" height="250"></embed></object> --%>
            <div class="pageGroupBody"><p>The VIVO project was initiated and resides in the Cornell University Library, with support from the Office of the Provost. Technology development and disciplinary content entry are directed by appropriate subject experts in the Library, who are also part of the VIVO project team. The team includes:<ul>
            <li>Medha Devare - VIVO Project Coordinator (Mann Library)</li>
            <li>Jaron Porciello - Special Projects Librarian (Mann Library)</li>
            <li>Jon Corson-Rikert - Information Technology Lead (Mann Library)</li>
            <li>Brian Caruso - Programmer (Mann Library)</li>
            <li>Brian Lowe - Programmer (Mann Library)</li>
            <li>Nick Cappadona - Web Interface Designer (Mann Library)</li>
            <li>Miles Worthington - Web Interface Designer (Mann Library)</li>
            <li>Kathy Chiang - CALS Research Portal Coordinator (Mann Library)</li>
            <li>Jill Powell - Physical Sciences/Engineering Coordinator (Engineering Library)</li>
            <li>Susette Newberry - Humanities Coordinator (Olin Library)</li>
            <li>Deb Schmidle - Social Sciences Coordinator (Olin Library)</li>
            <li>Susanne Whitaker - Veterinary Sciences Coordinator (Vet Library)</li>
            </ul>
            </div>
        </td>
    </c:otherwise>
</c:choose>
<%-- <c:if test='${!empty msgError}'>Error retrieving basecamp messages<br/></c:if>
<c:if test='${!empty msError}'>Error retrieving basecamp milestones<br/></c:if>
<c:if test='${!empty pplError}'>Error retrieving basecamp people<br/></c:if>
<c:if test='${!empty todoAssignedError}'>Error retrieving basecamp assigned todo items<br/></c:if>
<c:if test='${!empty todoAllError}'>Error retrieving basecamp todo lists<br/></c:if>
<c:if test='${!empty todoPersonalError}'>Error retrieving basecamp personal todo list<br/></c:if>
<c:if test='${!empty todoPersonalError}'>Error retrieving jira vitro list<br/></c:if>
<c:if test='${!empty todoPersonalError}'>Error retrieving jira vivo list<br/></c:if> --%>
</c:when>
</c:choose>

