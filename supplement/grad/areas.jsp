<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>
<%@ include file="part/resources.jsp" %>

<c:if test="${empty param.uri}">
    <c:redirect url="/fieldsindex/"/>
</c:if>

<c:set var="URI">${namespace}${param.uri}</c:set>
<c:set var="encodedURI"><str:encodeUrl>${URI}</str:encodeUrl></c:set>
<c:set var="areaID" scope="session">${param.uri}</c:set>
<c:set var="areaName" scope="session">
	<c:import url="part/getlabel.jsp"><c:param name="uri" value="${URI}"/></c:import>
</c:set>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="areas"/>
    <jsp:param name="metaURI" value="${encodedURI}"/>
    <jsp:param name="titleText" value="${areaName} | Cornell University"/>
</jsp:include>

        <div id="contentWrap">

            <div id="content">

                <h2 class="groupLabel ${areaID}">${areaName}</h2>
				
                <h3>Graduate Fields in this Area</h3>
                <ul class="fields">
                    <jsp:include page="part/listfields.jsp">
                        <jsp:param name="uri" value="${URI}"/>
                    </jsp:include>  
                </ul>
                    
				<jsp:include page="part/programs-in-group.jsp">
                    <jsp:param name="uri" value="${URI}"/>
                </jsp:include>
                    
                <div class="gradEducation small">
                    <h3>Other Areas</h3>
					<ul class="groupings">
					<jsp:include page="part/listgroups.jsp">
	                    <jsp:param name="uri" value="${URI}"/>
	                </jsp:include>
					</ul>
				</div>

                  <div class="gradEducation">
                      <h3>What are Graduate Fields?</h3>
                      <p>Graduate education at Cornell is organized by Fields, which group faculty by common academic interest.  Almost all Fields have an administrative home in a department.  In some cases the faculty comprising the Field are virtually the same as those comprising the department.  In other cases not all the departmental faculty are members of a Field with a home in that department, and many outside-departmental faculty are members.  Generally each Field acts independently in graduate student admissions, e.g. recruiting, selecting, financing, and interviewing prospective students who visit Cornell, although in some cases Fields recruit together.</p>
                      <%-- <p><strong>The first step in applying to Cornell's Graduate School is identifying which Field most closely matches your goals.</strong></p> --%>
                      <p>For more information visit the <a title="Cornell Graduate School Web site" href="http://www.gradschool.cornell.edu/index.php?p=9">Graduate School Web site</a></p>
                  </div>

            </div><!-- content -->

        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />
