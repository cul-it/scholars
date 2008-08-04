<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="home"/>
    <jsp:param name="titleText" value="Graduate Programs in the Life Sciences | Cornell University"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content">
                <h2 class="initial">Explore Graduate Fields in these areas</h2>
                
                <jsp:include page="part/listgroups.jsp"/>
                
                <p class="sevenUnit">On campus, a biorevolution has transformed research. Biology is no longer just being done by biologists. Scientists and scholars from traditionally separate disciplines pursue biological questions and work with biological systems and biologists.</p>
                
                <div id="apply">
                    <p>Begin the process of studying in one of the world's most exciting and diverse academic environments.</p>
                    <a href="http://www.gradschool.cornell.edu/?p=1" id="applyButton" title="Apply"><img src="resources/images/layout/button_apply.gif" alt="Apply Button"/></a>
                </div>
                
            </div><!-- content -->
        
            <div id="sidebar">
                <div id="news">
                    <h2>Life Sciences News</h2>
                    <jsp:include page="part/newsforportal.jsp" />
                    <span class="moreLink"><a title="more Life Sciences news" href="news.jsp">more news &raquo;</a></span>
                </div>
                <div id="searchBox">
                    <form name="findresearch" action="search.jsp" method="get"> 
                        <h2><label for="search-form-query">Search</label></h2>
                        <input type="text" id="search-form-query" name="querytext" value="" size="26" />
                        <input type="submit" id="search-form-submit" name="submit" value="go" />
                    </form>
                </div>
                <div id="seminars">
                    <h2>Life Sciences Seminars</h2>
                    <jsp:include page="part/seminarsforportal.jsp" />
                    <span class="moreLink"><a title="more Life Sciences events" href="events.jsp">more events &raquo;</a></span>
                </div>
            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />