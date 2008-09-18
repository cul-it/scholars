<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="groupindex"/>
    <jsp:param name="titleText" value="Index of Graduate Fields | Cornell University"/>
</jsp:include>
		
		<div id="contentWrap">
			<div id="content">
								
				<div class="gradEducation">
                    <h2>What are Graduate Fields?</h2>
                    <p>Graduate education at Cornell is organized by Fields, which group faculty by common academic interest.  Almost all Fields have an administrative home in a department.  In some cases the faculty comprising the Field are virtually the same as those comprising the department.  In other cases not all the departmental faculty are members of a Field with a home in that department, and many outside-departmental faculty are members.  Generally each Field acts independently in graduate student admissions, e.g. recruiting, selecting, financing, and interviewing prospective students who visit Cornell, although in some cases Fields recruit together.</p>
                    <%-- <p><strong>The first step in applying to Cornell's Graduate School is identifying which Field most closely matches your goals.</strong></p> --%>
                    <p>For more information visit the <a title="Cornell Graduate School Web site" href="http://www.gradschool.cornell.edu/index.php?p=9">Graduate School Web site</a></p>
                </div>		
				
				<h2>Life Sciences Graduate Fields <span>(grouped by subject area)</span></h2>
				<jsp:include page="part/list-groups-with-fields.jsp" />
						
			</div><!-- content -->
		
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />