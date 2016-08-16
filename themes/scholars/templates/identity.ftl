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
<div id="logo-container" style="${backsplashDisplay!};">
	<img width="56%" src="${urls.base}/themes/scholars/images/scholars_logo.png" />
</div>
<div id="welcome" style="${backsplashDisplay!};position: fixed;width:100%;z-index: -1;margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
	<ul style="list-style: none;margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
		<li style="position:absolute;display:list-item;width:100%;height:100%;min-height:100%;background: transparent url('${urls.base}/themes/scholars/images/scholars-backdrop.jpg') no-repeat center center;background-size: cover;"></li>
	</ul>
</div>
