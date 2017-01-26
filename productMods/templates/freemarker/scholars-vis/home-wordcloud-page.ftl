<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4" class="scholars-container">
      <div class="panel-group" id="accordion">
        <div class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                <span class="start">Filter by:</span> Person
              </a>
            </h4>
          </div>
          <div id="collapseOne" class="panel-collapse collapse">
            <div class="panel-body" id="person">
              <input type="text" class="form-control" id="testInput" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
               <span class="start">Filter by:</span> Academic Unit
             </a>
            </h4>
          </div>
          <div id="collapseTwo" class="panel-collapse collapse">
            <div class="panel-body" id="department">
              <input type="text" class="form-control" id="deptInput" placeholder="Search"/>
            </div>
          </div>
        </div>
      
        <div>
          <h5><a onclick="checkAll()">Check All</a> | <a onclick="uncheckAll()">Uncheck All</a></h5>
        </div>
      </div> 

      <div id="legendDiv" class="center-block"> </div>
    </div>
    
    <div id="site_wordcloud_vis" class="col-md-8">
      <div id="wc-text-container">
        <span class="text-primary" id="content"></span>
      </div>
      <span class="glyphicon glyphicon-info-sign pull-right" 
        data-toggle="tooltip" 
        data-original-title="The keyword cloud presents the top 300 keywords extracted from the journal articles published by Cornell faculty and researchers. <br> The size of each keyword in the cloud is directly proportional to the sum of the count of the faculty/researchers. <br> The bigger the keyword is in size, the more the faculty members and researcher used the term in their papers."
        data-placement="bottom"
        data-html="true" 
        data-viewport="#site_wordcloud_vis">
      </span>
      <a href="#" id="site_word_cloud_exporter" >
        <i class="fa  fa-download pull-right" aria-hidden="true" title="export this data"></i>
      </a>
      <div id="vis"> </div>
    </div>
  </div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/site-kwcloud.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/university-word-cloud.js"></script>')}

<script type="text/javascript">
  $().ready(function() {
    wc = new ScholarsVis.UniversityWordCloud({
      target : '#site_wordcloud_vis',
      modal : false
    });
    wc.show();
    $('#site_word_cloud_exporter').click(wc.showVisData);
  });
</script>

