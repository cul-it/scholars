<#--
  <link rel="stylesheet" href="css/reset.css">
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href="css/style.css">
  <script src="js/libs/modernizr-2.0.6.min.js"></script>
-->

  <div class="container">
    <div id="main" role="main">
      <div id="view_selection" class="btn-group">
        <a href="#" id="all" class="btn active">All Grants</a>
        <a href="#" id="year" class="btn">Grants By Year</a>
        <a href="#" id="dept" class="btn">Grants By Department</a>
      </div>
      <div id="selects">
        <div id="years-container" style="display:none;">
          <p>Select year:
          <select id="years">
            
          </select></p>
        </div>
        <div id="depts-container" style="display:none;">
          <p>Select department:
          <select id="depts">
          </select>
        </p>
      </div>
      <div id="vis"></div>
      <div style="padding-top: 10px;">
        <strong>Color scheme:</strong>
        <div>
          <span style="width:170px;height:20px;background-color:#41B3A7;border:1px solid #41B3A7;">Grant: Unknown</span>
          <span style="width:170px;height:20px;background-color:#81F7F3;border:1px solid #81F7F3;">$100,000 > Grant > $0</span>
          <span style="width:170px;height:20px;background-color:#819FF7;border:1px solid #819FF7;">$1,000,000 > Grant > $100,000</span>
          <span style="width:170px;height:20px;background-color:#BE81F7;border:1px solid #BE81F7;">Grant > $1,000,000</span>
        </div>
      </div>

    </div>
    <footer>
      
    </footer>
  </div> <!--! end of #container -->

${stylesheets.add('<link rel="stylesheet" href="${urls.theme}/css/visualizations/grants/style.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/grants/plugins.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/grants/script.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/grants/CustomTooltip.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/grants/coffee-script.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/grants/papaparse.min.js"></script>',
              '<script type="text/coffeescript" src="${urls.theme}/js/visualizations/grants/vis.coffee"></script>')}


  <script type="text/javascript">
    $(document).ready(function() {
        $(document).ready(function() {
          $('#view_selection a').click(function() {
            var view_type = $(this).attr('id');
            $('#view_selection a').removeClass('active');
            $(this).toggleClass('active');
            toggle_view(view_type);
            return false;
          });
        });
    });
  </script>
