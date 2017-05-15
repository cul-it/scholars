<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<div id="nav-bar" class="${navbarClass!}" role="navigation" >
	<div id="nav-bar-row"class="row">
		<a id="nav-logo" href="${urls.home}" title="" style="${navbarLogoDisplay!}">
			<span><img src="${urls.base}/themes/scholars/images/menu_logo.png"/></span>
		</a>
		 <nav id="nav-pages" class="pages" >
			<ul>
				<li class="nav-menu-option" role="listitem">
					<a class="menu-links" href="${urls.about}" title="about">About</a>
				</li>
				<li class="nav-menu-option" role="listitem">
					<a class="menu-links" href="${urls.base}/tour" title="take the tour">Take the Tour</a>
				</li>
				<#if currentServlet != "home" >
					<li class="nav-menu-option" id="browse-menu-option" role="listitem">
						Browse
						<div id="browse-menu">
							<ul>
								<li class="browse-menu-li">
									<h3 id="disc-header">Discovery</h3>
									<ul id="disc-links">
										<li><a class="browse-menu-link" href="${urls.base}/domainExpert?querytype=new">Find a Domain Expert</a></li>
										<li style="letter-spacing:0">Explore Research & Scholarship</li>
										<li style="letter-spacing:0">Browse Academic Units</li>
									</ul>
								</li>
								<li class="browse-menu-li">
									<h3 id="vis-header"">Visualizations</h3>
									<ul id="vis-links">
										<li><a class="browse-menu-link" href="${urls.base}/orgSAVisualization">Research Interests</a></li>
										<li><a class="browse-menu-link" href="${urls.base}/homeWordcloudVisualization">Research Keywords</a></li>
										<li><a class="browse-menu-link" href="${urls.base}/homeWorldmapVisualization">Global Collaborations</a></li>
										<li><a class="browse-menu-link" href="${urls.base}/grantsVisualization">Research Grants</a></li>
									</ul>
								</li>
						</div>
					</li>
				</#if>
				<li class="nav-bar-search" >
					<div id="search-button">
						<i id="show-search" class="fa fa-search" aria-hidden="true"></i>
					</div>
				</li>
			</ul>
			<div id="search-container">
			  <form id="home-search-form" action="${urls.search}" name="search-home" role="search" method="post"> 
	        	<input id="search-input" placeholder="Search the full site" type="text" name="querytext" class="homepage-search" value="" autocapitalize="off" />
	        	<button type="submit" class="search-submit">GO</button>
			  </form>
	        </div>   
		</nav>
	</div>
</div>


