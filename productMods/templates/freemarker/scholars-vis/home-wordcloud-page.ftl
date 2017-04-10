<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 kwcloud-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research keywords
         </h2>
         <p style="font-size:12px">Select faculty member or academic department.</p>
      </div>
      
      <div class="panel-group" id="accordion">

        <div id="personSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
               <span class="start">Select:</span> Faculty Member
             </a>
            </h4>
          </div>
          <div id="collapseTwo" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>
        
        <div id="departmentSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                <span class="start">Select:</span> Academic Department
              </a>
            </h4>
          </div>
          <div id="collapseOne" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>

        <h4 style="margin-top:8px"><a id="siteSelector" href="#">Reset</a></h4>
        
      </div> 

      <div>
        <font face="Times New Roman" size="2">
          <span><i>Click on a keyword to view the list of the relevant faculty. In a faculty keyword cloud, click on a keyword to view the list of the related publications of the selected faculty.</i></span>
        </font>
      </div>

    </div>

    <div class="col-md-8">
      <div id="selectedWordCloudLabel"></div>
      
      <#-- swiped from individual--foaf-organization.ftl -->
      <div id="departmentWordCloudVis" style="display:none">
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
          Cras finibus blandit turpis, eu egestas est sagittis eget. 
          Duis eu enim. 
        </div>
      </div>
    
      <#-- swiped from individual--foaf-person.ftl -->
      <div id="personWordCloudVis" style="display:none">
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
          Cras finibus blandit turpis, eu egestas est sagittis eget. 
          Duis eu enim. 
        </div>
      </div>

      <div id="siteWordCloudVis" style="display:none">
        <div id="wc-text-container">
          <span class="text-primary" id="content"></span>
        </div>
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          The keyword cloud presents the top 300 keywords extracted from the 
          journal articles published by Cornell faculty and researchers. 
          <br>
          The size of each keyword in the cloud is directly proportional to the 
          sum of the count of the faculty/researchers. 
          <br> 
          The bigger the keyword is in size, the more the 
          faculty members and researcher used the term in their papers.
        </div>
      </div>

    </div>

  </div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/home-wordcloud.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/kwcloud.css" />',
                  '<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/keywordcloud/site-kwcloud.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/university-word-cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/word-cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/home-wordcloud-selector.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>')}

<script>
$().ready(function() {
  createWordCloudSelector("#siteSelector", "#departmentSelectionPanel", "#personSelectionPanel", 
                          "#siteWordCloudVis", "#departmentWordCloudVis", "#personWordCloudVis");
});
$().ready(function() {
  new ScholarsVis.Toolbar("#departmentWordCloudVis");
  new ScholarsVis.Toolbar("#personWordCloudVis");
  new ScholarsVis.Toolbar("#siteWordCloudVis");
});
</script>
