<#if requestingDept?has_content>
	<div class="row"  style="background-color:#fff;">
	<div id="container" class="col-sm-12 col-md-12 col-lg-12" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;padding-bottom:60px">
	<div style="float:right;margin:22px 22px 0 0">
		<a href="#"><i class="fa fa-download" aria-hidden="true" title="download the data" style="font-size:24px;z-index:4000"></i></a>
	</div>
		<div  style="margin:16px 0 0 20px"><h2 style="padding:0;color:#5f5858;font-size:20px">Person to Subject Area Map &ndash; ${requestingDept[0].label!}</h2></div>	
		<div id="organization-research-areas" style="padding-bottom:60px"></div>
		<script>
		$().ready(function() {
		  loadVisualization({
		    target : '#organization-research-areas',
		    url : "${urls.base}/api/dataRequest?action=organization_research_areas&organization=${requestingDept[0].dept?url}",
		    parse : 'turtle',
		    transform : transformFlaredata,
		    display : plotConceptMap,
		    height : 1000,
		    width : 0.70
		  });
		});
		</script>
	  </div> <!--! end of #container -->
	</div> <!-- end of row -->
</#if>
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
					'<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/svg-pan-zoom.js"></script>')}
