<#assign deptLabel = "" />
<#if requestingDept?has_content>
	<#assign deptLabel = requestingDept[0].label />
</#if>
	


		<div class="row"  style="background-color:#fff;" >
			<div id="container" class="col-sm-12 col-md-12 col-lg-12" style="min-height:300px;border: 1px solid #cdd4e7;border-top:5px solid #CC6949;padding-bottom:60px">
				<div style="float:right;margin:22px 22px 0 0">
					<a href="#" id="org-subject-area-exporter">
						<i class="fa fa-download" aria-hidden="true" title="download the data" style="z-index:4000"></i>
					</a>
				</div>
				<div  style="margin:16px 0 0 20px">
					<h2 style="padding:0;color:#5f5858;font-size:20px">Person to Subject Area Map</h2>
					<#if departmentList?has_content>
						<p style="margin:10px 0 0 2px;font-family: Muli, Arial, Verdana, Helvetica;font-size:16px">
							<select id="sa-dept-select">
								<option value="">Select a department...</option>
							  <#list departmentList as dept >
								<option value="${dept.dept?url}" <#if deptLabel == dept.label>selected</#if>>${dept.label!}</option>
							  </#list>
							</select>
						</p>
					</#if>
				</div>	
			<#if requestingDept?has_content>
				<div id="organization-subject-areas" style="padding-bottom:60px;height:1000;width:70%"></div>
					<script>
					$().ready(function() {
		  			  var ora = new ScholarsVis.OrganizationResearchAreas({
	      				target : '#organization-subject-areas',
	      				organization : "${requestingDept[0].dept?url}"
						});
						ora.show();
						$('#org-subject-area-exporter').click(ora.showVisData);
					});
					</script>
			</#if>
			</div> <!--! end of #container -->
		</div> <!-- end of row -->
<div style="margin-top:200px">&nbsp;</div>
<script>
$().ready(function() {
	$('#sa-dept-select').change(function() {
		var url = "${urls.base}/orgSAVisualization?deptURI=" + $(this).val();
		if ( url ) {
			window.location = url;
		}
	});
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
				  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/svg-pan-zoom.js"></script>')}
