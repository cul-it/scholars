<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<#if !backsplashDisplay?? >
	<#assign backsplashDisplay = "display:none"/>
	<style>
		div.editingForm {
			margin: 30px;
			padding: 30px;
			background-color: #fff;
		}
		section#search {
			display:none;
		}
	</style>
</#if>
<div id="logo-container" style="${backsplashDisplay!}">
	<img width="56%" src="${urls.theme}/images/scholars_logo.png" />
</div>
<div id="welcome" style="${backsplashDisplay!}">
	<ul>
		<li></li>
	</ul>
</div>
<div id="tagline" style="${backsplashDisplay!};z-index:-1;position:fixed;left:10px;bottom:178px;">
	<img width="112%" src="${urls.theme}/images/tagline.png" />
</div>
