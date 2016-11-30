<div class="row"  style="background-color:#fff;">
<div id="container" class="col-sm-12 col-md-12 col-lg-12" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;">
<div style="float:right;margin:22px 22px 0 0">
	<a href="#"><i class="fa fa-download" aria-hidden="true" title="download the data" style="font-size:24px"></i></a>
</div>
	<div class="select-container">
		<select id="view_selection">
			<option id="all" value="grants-all">All Grants</option>
			<option id="year" value="grants-year">Grants By Year</option>
			<option id="dept" value="grants-dept">Grants By Academic Unit</option>
			<option id="funagen" value="grants-funagen">Grants By Funding Agency</option>
		</select>
	</div>
      <div id="selects">
        <div id="years-container" style="display:none;">
          <p>Select year:
          <select id="years">
            
          </select></p>
        </div>
        <div id="depts-container" style="display:none;">
          <p>Select academic unit:
          <select id="depts">
          </select>
          </p>
		</div>
        <div id="funagens-container" style="display:none;">
          <p>Select funding agency:
          <select id="funagens">
          </select>
          </p>
		</div>
      </div>
	  <div style="width:100%;display:inline-block;text-align:center">
	    <div style="margin: 40px 30px 0 0;float:right">
	      <div style="font-size:14px;display:inline;text-align:left">
		  	<ul>
		  		<li style="line-height:30px">
		  	<span style="color: #CC6949;;font-size:16px">Grant Amount</span></li>
		  		<li style="line-height:40px">
	        <span style="margin-left:5px;padding-left:10px;width:10px;height:20px;background-color:#41B3A7;border:1px solid #41B3A7;"></span>
		    <span style="padding-left:6px;">$ unknown</span> </li>
		  		<li style="line-height:40px">
	        <span style="margin-left:5px;padding-left:10px;width:170px;height:20px;background-color:#81F7F3;border:1px solid #81F7F3;"></span>
		    <span style="padding-left:6px;">< $100,000</span></li>
		  		<li style="line-height:40px">
	        <span style="margin-left:5px;padding-left:10px;width:170px;height:20px;background-color:#819FF7;border:1px solid #819FF7;"></span>
		    <span style="padding-left:6px;">$100,000 - $1,000,000</span></li>
		  		<li style="line-height:40px">
	        <span style="margin-left:5px;padding-left:10px;width:170px;height:20px;background-color:#BE81F7;border:1px solid #BE81F7;"></span>
	        <span style="padding-left:6px;">> $1,000,000</span> </li>
	      </div>
	    </div>
      	<div id="vis" style="display:inline;height:600px;width:700px"></div>
	  </div>

    <footer></footer>
  </div> <!--! end of #container -->
</div> <!-- end of row -->
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/grants/style.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/transform-data.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/plugins.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/script.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/CustomTooltip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/coffee-script.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/papaparse.min.js"></script>',
              '<script type="text/coffeescript" src="${urls.base}/js/scholars-vis/grants/vis.coffee"></script>')}


  <script type="text/javascript">
    $(document).ready(function() {
          $('#view_selection').change(function() {
            var view_type = $(this).children(":selected").attr('id');
			$('#view_selection a').removeClass('active');
			$(this).blur();
            toggle_view(view_type);
            return false;
          });
    });
  </script>
