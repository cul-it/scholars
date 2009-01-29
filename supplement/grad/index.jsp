<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="home"/>
    <jsp:param name="titleText" value="Graduate Programs in the Life Sciences | Cornell University"/>
    <jsp:param name="metaDescription" value="Education is changing. Faculty across Cornell are incorporating new tools, new data, and new thinking into new and current curricula, which also examine the social and ethical issues that this new research raises. A new generation of scholars and scientists is being trained in a more collaborative, interdisciplinary environment."/>
</jsp:include>
        
        <div id="contentWrap">
            
            <div id="content" class="span-15">
                
                <p>Graduate programs at Cornell are organized by Fields. The first step in applying is identifying a Field that best matches your academic goals.</p>
                <p class="span-13">With over 30 Fields to choose from in the Life Sciences, let's narrow it down by selecting a broad interest...</p>
            
				<ul class="groupings">
	                <jsp:include page="part/groups_list.jsp"></jsp:include>
				</ul>
				
				<p id="fullList">...or see the <a title="list of life sciences graduate fields" href="/allfields">full list</a> of Fields instead</p>
            
                <p id="applyBox"><strong>Already determined which Field is right for you?</strong><a id="applyButton" href="http://www.gradschool.cornell.edu/?p=1" title="graduate school application">Apply Now</a></p>
                
  	        </div><!-- content -->
      
            <div id="sidebar" class="span-8 last">
                
                <div id="researchAreas">
                    <h2>Have a research area in mind?</h2>
                    <form name="findresearch" action="/researchareas/" method="get"> 
                        <select id="research-areas-menu" name="uri">
                            <option>--- try one ---</option>
                                <jsp:include page="part/researchareas_list.jsp">
                                    <jsp:param name="type" value="all-menu"/>
                                </jsp:include>
                        </select>
                        <input type="hidden" name="home" value="true"/>
                        <input type="submit" id="research-area-submit" value="go" />
                    </form>
                </div>
				
                <div id="searchBox">
                    <form name="findresearch" action="/search/" method="get"> 
                        <h2><label for="search-form-query">Search this site</label></h2>
                        <input type="text" id="search-form-query" name="query" value="" size="26" />
                        <input type="submit" id="search-form-submit" name="submit" value="go" />
                    </form>
                </div>
                
                <div id="helpfulPages">
                   <h2>Helpful Pages</h2>
                   <ul>
                       <li><a href="http://gradschool.cornell.edu/index.php?p=9">More about how Graduate Fields work</a></li>
                       <li><a href="http://www.gradschool.cornell.edu/index.php?p=33">Fellowships &amp; Assistantships</a></li>
                       <li><a href="http://www.gradschool.cornell.edu/index.php?p=106">Graduate student life at Cornell</a></li>
                       <li><a href="http://www.cornell.edu/about/facts/stats.cfm">Facts about Cornell</a></li>
                   </ul>
                </div>
                
            </div> <!-- sidebar -->
            
        </div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp"></jsp:include>