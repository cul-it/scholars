<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 kwcloud-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research keywords
         </h2>
      </div>
      
      <div class="panel-group" id="accordion">

        <div id="personSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
               Faculty Member
             </a>
          </div>
          <div id="collapseTwo" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>
        
        <div id="departmentSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
              <span class="start">Select:</span>
				<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                 Academic Unit
              </a>
          </div>
          <div id="collapseOne" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>

        <h4 style="margin-top:8px"><a id="siteSelector" href="#">Reset</a></h4>
        
      </div> 

      <div id="unit-help-text">
        <font size="2">
          <span><i>Click on a keyword to view the list of faculty who have publications associated with the keyword.</i></span>
        </font>
      </div>
      <div id="person-help-text" style="display:none;">
        <font size="2">
          <span><i>Click on a keyword to view the list of publications associated with the keyword.</i></span>
        </font>
      </div>

    </div>

    <div class="col-md-8">
      <div id="selectedWordCloudLabel"></div>
      
      <#-- swiped from individual--foaf-organization.ftl -->
      <div id="departmentWordCloudVis" style="display:none">
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          <p>
            This visualization displays the research keywords for an entire academic unit, and is an aggregation of the keywords found in all the articles authored by all faculty and researchers of an academic unit. The size of the keyword indicates the frequency with which the keyword appears in the author’s publications, indicating which subjects the author published on most (or least) frequently. 
          </p>
          <p>
            To interact with the visualization, click on any keyword to see the list of authors that have this keyword associated with one of more of their articles. One can click on the author’s name in the list to go to the author’s page, which contains the full list of author’s publications in Scholars.
          </p>
          <hr> 
          <p>
            Note: This information is based solely on publications that have been loaded into the system.
          </p> 
        </div>
      </div>
    
      <#-- swiped from individual--foaf-person.ftl -->
      <div id="personWordCloudVis" style="display:none">
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          <p>
            This visualization displays the research keywords associated with the author, and is an aggregation of keywords found in all of the author’s articles. There are different sources of these keywords: those expressed by the author in the articles, those assigned by the publishers to the article, and those that are algorithmically inferred from the text of the article’s abstract. The size of the keyword indicates the frequency with which the keyword appears in the author’s publications, indicating which subject the author published on most (or least) frequently. 
          </p>
          <p>
             To interact with the visualization, click on any the keyword to see the list of the articles associated with the keyword. You can then click on the article title in this list to navigate to the full view of the article’s metadata and a link to the full text when it's available.
          </p>
          <hr> 
          <p>
            Note: This information is based solely on publications that have been loaded into the system.
          </p> 
        </div>
      </div>

      <div id="siteWordCloudVis" style="display:none">
        <div id="wc-text-container">
          <span class="text-primary" id="content"></span>
        </div>
        <div id="vis"></div>

        <div id="info_icon_text" style="display:none">
          <p>
            This visualization gives a bird's eye view of the research keywords associated with all Cornell faculty and researchers, and is an aggregation of all the keywords found in their published articles. The size of the keyword indicates the frequency with which the keyword appeared in the authors’s publications, indicating which subjects Cornell faculty and researchers published on most (or least) frequently. 
          </p>
          <p>
             To interact with the visualization, click on any keyword to see the list of authors that have this keyword associated with one of more of their articles. You can then click on the author’s name in the list to go to the author’s page, which contains the full list of the author’s publications in Scholars.
          </p>
          <hr> 
          <p>
            Note: This information is based solely on publications that have been loaded into the system.
          </p> 
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
                          "#siteWordCloudVis", "#departmentWordCloudVis", "#personWordCloudVis", "#unit-help-text", "#person-help-text");
});
</script>
