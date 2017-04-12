<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 kwcloud-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research keywords
         </h2>
         <p style="font-size:12px">Select faculty member or academic unit.</p>
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
                <span class="start">Select:</span> Academic Unit
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
          This visualization represents the research keywords for an entire academic unit which is an aggregation of all the keywords found in all the articles authored by all faculty and researchers of an academic unit. The size of the keyword indicates the frequency of the keyword in the author’s publications which suggests that in which subject author published most (or least) frequently. This is not a static visualization. A user can click on any keyword to see the list of authors that have this keyword associated with one of more of their articles. One can click on the author’s name in the list to go to the author’s page which contains the full list of author’s publications in Scholars. Note: This information is based solely on publications that have been loaded into the system.
        </div>
      </div>
    
      <#-- swiped from individual--foaf-person.ftl -->
      <div id="personWordCloudVis" style="display:none">
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          This visualization represents the research keywords of the author which is an aggregation of keywords found in all the author’s articles. There are different sources of these keywords; those expressed by the author in the articles, those assigned by the publishers to the article and those that are algorithmically inferred from the text of the article’s abstract. The size of the keyword indicates the frequency of the keyword in the author’s publications which suggests that in which subject author published most (or least) frequently. This is not a static visualization. A user can click on any the keyword to see the list of actual articles that have this keyword. One can click on the article title in the list to navigate to the full view of the article’s metadata and a link to the full text when its available. Note: This information is based solely on publications that have been loaded into the system.
        </div>
      </div>

      <div id="siteWordCloudVis" style="display:none">
        <div id="wc-text-container">
          <span class="text-primary" id="content"></span>
        </div>
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
         This visualization gives a bird-view of the research keywords of the Cornell faculty and researchers which is an aggregation of all the keywords found in their published articles. The size of the keyword indicates the frequency of the keyword in the author’s publications which suggests that in which subject Cornell faculty and researchers published most (or least) frequently. This is not a static visualization. A user can click on any keyword to see the list of authors that have this keyword associated with one of more of their articles. One can click on the author’s name in the list to go to the author’s page which contains the full list of author’s publications in Scholars. Note: This information is based solely on publications that have been loaded into the system.
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
