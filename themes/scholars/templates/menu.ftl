<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<div id="nav-bar-topper" class="${navbarClass!}" role="navigation" style="display:none;background: url('${urls.base}/themes/scholars/images/menu-background-topper.png') repeat-x;height: 20px;z-index: 2;width:100%;margin:0;padding:0;border:0;vertical-align:baseline;position:fixed;top:0">
</div>
<div id="nav-bar" class="${navbarClass!}" role="navigation" style="background: url('${urls.base}/themes/scholars/images/nav-menu-background.png') no-repeat center center;background-size: cover;height: 95px;z-index: 2;width:100%;margin:0;padding:0;border:0;vertical-align:baseline;">
	<div class="row" style="position:relative;margin: 0 20px 0 30px;padding:0;border:0;vertical-align:baseline;background:none">
		<a id="nav-logo" class="ir" href="${urls.home}" title="" style="${navbarLogoDisplay!};padding-top:36px;background-color:transparent;background: url('${urls.base}/themes/scholars/images/tower.png') no-repeat;float: left;margin-top: 0;width: 180px;height: 95px;">
			<span style="padding-left:65px;"><img src="${urls.base}/themes/scholars/images/menu_logo.png"/></span>
		</a>
		 <nav class="pages" style="padding-top:15px;margin-top:5px;height:95px;float:right;display:block;font: inherit;">
			<ul style="list-style:none;margin: 0;padding: 0;border: 0;font: inherit;vertical-align: baseline">

	        	<#list menu.items as item>
					<#if !item.linkText?contains("Home") >
	            		<li role="listitem" style="margin:0 0 0 40px !important;text-transform: uppercase;float: left;padding: 0;border: 0;font: inherit;vertical-align: baseline">
							<a href="${item.url}" style="<#if item.active>color: #CC6949;</#if>letter-spacing: .2em;font-size:14px;transition: .5s;text-decoration: none;">
								${item.linkText}
							</a>
						</li>
					</#if>
	        	</#list>
						<li class="nb-4" style="margin:0 0 0 40px !important;text-transform: uppercase;float: left;padding: 0;border: 0;font: inherit;vertical-align: baseline">
							<div id="search-button" style="">
								<i id="show-search" class="fa fa-search" aria-hidden="true"></i>
							</div>
						</li>
			</ul>
			<div id="search-container" style="display:none;" >
			  <form id="home-search-form" action="${urls.search}" name="search-home" role="search" method="post"> 
	        	<input id="search-input" type="text" name="querytext" class="homepage-search" value="" autocapitalize="off" />
	        	<button type="submit" class="search-submit">GO</button>
			  </form>
	        </div>   
		</nav>
	</div>
</div>
<#-- 

<div style="color:#fff;margin:-14px 0 0 9px;padding:0;font-size:12px;font-family:verdana, arial, helvetica, sans-serif">Search Scholars
	<input type="radio" name="search-control" id="search-scholars" checked style="margin-right:12px"/>
	Search Cornell
	<input type="radio" name="search-control" id="search-cornell"/>
</div>

-->


