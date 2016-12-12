<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<div id="nav-bar" class="${navbarClass!}" role="navigation" >
	<div id="nav-bar-row"class="row">
		<a id="nav-logo" href="${urls.home}" title="" style="${navbarLogoDisplay!}">
			<span><img src="${urls.base}/themes/scholars/images/menu_logo.png"/></span>
		</a>
		 <nav id="nav-pages" class="pages" >
			<ul>
	        	<#list menu.items as item>
					<#if !item.linkText?contains("Home") >
	            		<li role="listitem">
							<a href="${item.url}" style="<#if item.active>color: #CC6949;</#if>">
								${item.linkText}
							</a>
						</li>
					</#if>
	        	</#list>
						<li class="nav-bar-search" >
							<div id="search-button">
								<i id="show-search" class="fa fa-search" aria-hidden="true"></i>
							</div>
						</li>
			</ul>
			<div id="search-container">
			  <form id="home-search-form" action="${urls.search}" name="search-home" role="search" method="post"> 
	        	<input id="search-input" type="text" name="querytext" class="homepage-search" value="" autocapitalize="off" />
	        	<button type="submit" class="search-submit">GO</button>
			  </form>
	        </div>   
		</nav>
	</div>
</div>


