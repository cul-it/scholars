<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<#if navbarLogoDisplay?contains("inline") >
	<#assign bannerDisplay = "display:none;" />
<#else>
	<#assign bannerDisplay = "" />
</#if>
<div id="nav-bar" class="${navbarClass!}" role="navigation"  style="z-index:8">
	<div id="nav-bar-row"class="row">
		<span style="margin-left:-30px;${bannerDisplay!}" id="beta-banner"><img src="${urls.base}/themes/scholars/images/banner.png"/ style="width:134px"></span>
		<a id="nav-logo" href="${urls.home}" title="" style="${navbarLogoDisplay!}">
			<span><img src="${urls.base}/themes/scholars/images/menu_logo.png"/></span>
		</a>
		 <nav id="nav-pages" class="pages" >
			<ul>
				<li class="nav-menu-option" role="listitem">
				  <#if urls.currentPage?contains("about") >
					<span class="menu-links" style="color:#CC6949">About<span>
				  <#else>
					<a class="menu-links" href="${urls.about}" title="about" onclick="javascript:_paq.push(['trackEvent', 'General', 'Homepage', 'About']);">About</a>
				  </#if>
				</li>
				<li class="nav-menu-option" role="listitem">
				  <#if urls.currentPage?contains("tour") >
					<span class="menu-links" style="color:#CC6949">Take the Tour<span>
				  <#else>
					<a class="menu-links" href="${urls.base}/tour" title="take the tour" onclick="javascript:_paq.push(['trackEvent', 'General', 'Homepage', 'Take The Tour']);">Take the Tour</a>
				  </#if>
				</li>
				<#if currentServlet != "home" >
					<li class="nav-menu-option" id="discover-menu-option" role="listitem">
						Discover
						<div id="discover-menu">
							<ul>
								<li class="discover-menu-li">
									<h3 id="searches-header">Searches</h3>
									<ul id="searches-links">
										<li>
											<a class="discover-menu-link" href="${urls.base}/domainExpert?querytype=new">
												Find a Domain Expert
											</a>
										</li>
										<li style="letter-spacing:0">
											<a class="discover-menu-link" href="${urls.base}/scholarship?querytype=new">
												Explore Research & Scholarship
											</a>
										</li>
										<li style="letter-spacing:0">
											<a class="discover-menu-link" href="${urls.base}/academicUnits?vclassId=http://xmlns.com/foaf/0.1/Organization">
												Browse Academic Units
											</a>
										</li>
									</ul>
								</li>
								<li class="discover-menu-li">
									<h3 id="vis-header"">Visualizations</h3>
									<ul id="vis-links">
										<li><a class="discover-menu-link" href="${urls.base}/orgSAVisualization">Research Interests</a></li>
										<li><a class="discover-menu-link" href="${urls.base}/homeWordcloudVisualization">Research Keywords</a></li>
										<li><a class="discover-menu-link" href="${urls.base}/homeWorldmapVisualization">Global Collaborations</a></li>
										<li><a class="discover-menu-link" href="${urls.base}/grantsVisualization">Research Grants</a></li>
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
	        	<button type="submit" class="search-submit" onclick="javascript:_paq.push(['trackEvent', 'Search', 'Homepage', 'Full Site Search']);">GO</button>
			  </form>
	        </div>   
		</nav>
	</div>
</div>


