<jsp:include page="header.jsp" />
        
        <div id="contentWrap">
            <div id="content">
                <h2 class="initial">Explore our Graduate Fields</h2>
                
                <jsp:include page="part/listgroups.jsp"/>
                
                <p>On campus, a biorevolution has transformed research. Biology is no longer just being done by biologists. Scientists and scholars from traditionally separate disciplines pursue biological questions and work with biological systems and biologists.</p>
                <div id="apply">
                    <p>Begin the process of studying in one of the world's most exciting and diverse academic environments.</p>
                    <a href="#" id="applyButton" title="Apply"><img src="images/layout/button_apply.gif" alt="Apply"/></a>
                </div>
                
            </div><!-- content -->
        
            <div id="sidebar">
                <div id="news">
                    <h2>Life Sciences News</h2>
                    <jsp:include page="part/newsforportal.jsp" />
                    <a class="moreLink" href="#">more news &raquo;</a>
                </div>
                <div id="search">
                    <form name="findresearch" action="" method="get">
                        <label for="findResearchInput"><h2>Find Research</h2></label>
                        <input name="findresearch" id="findResearchInput" type="text" />
                        <button name="submit" id="findResearchButton" type="submit" value="">
                            <img src="images/layout/button_search.gif" alt="Search" />
                        </button>
                    </form>
                </div>
                <div id="seminars">
                    <h2>Life Sciences Seminars</h2>
                    <!-- <ul><li><a href="/vivo/entity?uri=http%3a%2f%2fvivo.library.cornell.edu%2fns%2f0.1%23individual32616_1_1_1_1_1_1_2_1_1_1_1_1_1_2_1_1_1_2_1">TBA-Chemistry and Chemical Biology Seminar</a></li><li><a href="/vivo/entity?uri=http%3a%2f%2fvivo.library.cornell.edu%2fns%2f0.1%23individual32616_1_1_1_1_1_1_2_1_1_1_1_1_1_2_1_1_1">TBA-Chemistry and Chemical Biology Seminar</a></li></ul>
                     --><jsp:include page="part/seminarsforportal.jsp" />
                    <a class="moreLink" href="#">more events &raquo;</a>
                </div>
            </div> <!-- sidebar -->
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />