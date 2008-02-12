<jsp:include page="header.jsp" />
		
		<div id="contentWrap">
			<div id="content">
				<!-- <h2 class="initial">${param.label}</h2>
								
					<jsp:include page="part/gradfieldlist.jsp">
					    <jsp:param name="uri" value="${param.uri}"/>
					</jsp:include> -->
							<div> Graduate Fields in ${param.label}</div>

							<jsp:include page="part/gradfieldlist.jsp">
							    <jsp:param name="uri" value="${param.uri}"/>
							</jsp:include>	
								
			</div><!-- content -->
		
			<div id="sidebar">
				<div id="departments">
					<h2>Departments</h2>
				    <p>Department list for graduate field would appear here on mouseover event</p>
				</div>
				<div id="fieldGroupings">
					<jsp:include page="part/gradfieldgrouplist.jsp"/>
				</div>
			</div> <!-- sidebar -->
		</div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />