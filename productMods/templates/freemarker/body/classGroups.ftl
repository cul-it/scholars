<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List class groups, and classes within each group. -->
<div class="row scholars-row">
  <div class="col-md-12 scholars-container">
	<h2 class="expertsResultsHeader">Index</h2>
	
<#include "classgroups-checkForData.ftl">

<#if (!noData)>
    <section class="siteMap" role="region">
        <div id="isotope-container">
            <#list classGroups as classGroup>
                <#assign groupSize = classGroup.classes?size >
                <#assign classCount = 0 >
                <#assign splitGroup = false>
                <#-- Only render classgroups that have at least one populated class -->
                <#if (classGroup.individualCount > 0) && classGroup.displayName != "locations"> 
                	<div class="class-group">             
                        <h2 class="group-name">${classGroup.displayName?capitalize}</h2>
                        <ul role="list">
                            <#list classGroup.classes as class> 
                                <#-- Only render populated classes -->
                                <#if (class.individualCount > 0)>
                                    <li role="listitem"><a href="${class.url}" title="${i18n().class_name}">${class.name}</a> (${class.individualCount})</li>
                                <#assign classCount = classCount + 1 >
                                </#if>
                                <#if (classCount > 34) && !splitGroup >
                                   <#assign splitGroup = true >
                                   </ul></div>
                                   <div class="class-group">
                                       <h2>${classGroup.displayName} (${i18n().continued})</h2>
                                          <ul role="list">
                                </#if>
                            </#list>
                        </ul>
                    </div> <!-- end class-group -->
                </#if>
            </#list>
          </div> <!-- end isotope-container -->
    </section>
  </div>
</div>
    ${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/isotope/jquery.isotope.min.js"></script>')}
    <script>
		$(document).ready(function() {
        	var initHeight = $("#isotope-container").height();
        	initHeight = (initHeight/2.1) ;
        	$("#isotope-container").css("height",initHeight + "px");

	        $('#isotope-container').isotope({
	          // options
			  getSortData: {
				groupName : '.group-name'
			  },
	          //itemSelector : '.class-group',
			  sortBy : 'groupName',
	          layoutMode : 'masonry'
	        });
		});
    </script>
<#else>
    ${noDataNotification}
</#if>
