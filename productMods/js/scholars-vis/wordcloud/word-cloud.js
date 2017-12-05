/*******************************************************************************
 * 
 * Define the structures that embed the visualization into HTML:
 *   person: simple and full
 *   department: simple and full
 * Where "full" includes the table view and the export functions.
 * 
 * Also, define the functions that another site might want to override.
 *
 ******************************************************************************/

ScholarsVis["WordCloud"] = {
        transform: transform_word_cloud_data,
        display: draw_word_cloud,
        closer: close_word_cloud,
        
        PersonVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/person_word_cloud?person=" + options.person,
                    parse : 'turtle',
                    transform : transform_word_cloud_data,
                    display : draw_word_cloud,
                    closer : close_word_cloud,
                    maxKeywords : 50,
                    interactive : true,
                    scaleRange : [15, 60]
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        FullPersonVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/person_word_cloud?person=" + options.person,
                    parse : 'turtle',
                    transform : transform_word_cloud_data,
                    views : {
                        vis : {
                            display : draw_word_cloud,
                            closer : close_word_cloud,
                            export : {
                                json : {
                                    filename: "personWordCloud.json",
                                    call: exportWcVisAsJson
                                },
                                svg : {
                                    filename: "personWordCloud.svg",
                                    call: exportWcVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : drawPersonWcTable,
                            closer : closePersonWcTable,
                            export : {
                                csv : {
                                    filename: "personWordCloudTable.csv",
                                    call: exportPersonWcTableAsCsv,
                                },
                                json : {
                                    filename: "personWordCloudTable.json",
                                    call: exportPersonWcTableAsJson
                                }
                            }
                        },
                        empty: {
                            display : d => {}
                        }
                    },
                    maxKeywords : 50,
                    interactive : true,
                    scaleRange : [15, 60]
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        DepartmentVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/department_word_cloud?department=" + options.department,
                    parse : 'turtle',
                    transform : transform_word_cloud_data,
                    display : draw_word_cloud,
                    closer : close_word_cloud,
                    maxKeywords : 100,
                    interactive : true,
                    scaleRange : [15, 60]
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        FullDepartmentVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/department_word_cloud?department=" + options.department,
                    parse : 'turtle',
                    transform : transform_word_cloud_data,
                    views : {
                        vis : {
                            display : draw_word_cloud,
                            closer : close_word_cloud,
                            export : {
                                json : {
                                    filename: "departmentWordCloud.json",
                                    call: exportWcVisAsJson
                                },
                                svg : {
                                    filename: "departmentWordCloud.svg",
                                    call: exportWcVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : drawDepartmentWcTable,
                            closer: closeDepartmentWcTable,
                            export : {
                                csv : {
                                    filename: "departmentWordCloudTable.csv",
                                    call: exportDepartmentWcTableAsCsv,
                                },
                                json : {
                                    filename: "departmentWordCloudTable.json",
                                    call: exportDepartmentWcTableAsJson
                                }
                            }
                        },
                        empty: {
                            display : d => {}
                        }
                    },
                    maxKeywords : 100,
                    interactive : true,
                    scaleRange : [15, 60]
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}

/*******************************************************************************
 * 
 * Transform the RDF graph into the JSON structure that is expected by draw_word_cloud
 * 
 * Here is an example of the output:
 * [
 *   {
 *     "text": "prostate cancer",
 *     "entities": [
 *       {
 *         "uri": "/scholars/display/UR-380249",
 *         "text": "E-selectin ligand-1 controls circulating prostate cancer cell rolling/adhesion and metastasis",
 *         "citationTypes": ["KEYWORD"]
 *       },
 *       {
 *         "uri": "/scholars/display/UR-19472",
 *         "text": "Human fucosyltransferase 6 enables prostate cancer metastasis to bone",
 *         "citationTypes": ["KEYWORD", "MESH"]
 *       }
 *     ]
 *   }
 * ]
 * 
 * The transformation ensures that:
 * -- Two keywords are considered the same if the only difference is capitalization.
 * -- If an article lists two equivalent keywords (differ only in case), only one is counted.
 * -- On display, the first letter of each keyword is capitalized.
 * -- If an article has no label, it is ignored.
 * 
 * The citationTypes ensure that:
 * -- If a publication has the same value for both a Keyword and a Mesh term (and later, 
 *      an inferred keyword), then that publication will only appear once in the entities
 *      list. However, multiple keywordTypes will be listed for it.
 *
 * Options:
 *   maxKeywords -- The transformed data will be truncated after this many keywords.
 *                    Defaults to 20 keywords, may not be set to less than 5.
 ******************************************************************************/
function transform_word_cloud_data(graph, options) {
	var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
	var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");
	var VIVOC= $rdf.Namespace("http://scholars.cornell.edu/ontology/vivoc.owl#");

	var jsonResult = [];

	var stmts = graph.statementsMatching(undefined, VIVO('freetextKeyword'));
	stmts.forEach(new StatementProcessor("KEYWORD").processStatement);

	stmts = graph.statementsMatching(undefined, VIVO('hasSubjectArea'));
	stmts.forEach(new StatementProcessor("MESH").processStatement);

	stmts = graph.statementsMatching(undefined, VIVOC('inferredKeyword'));
	stmts.forEach(new StatementProcessor("INFERRED").processStatement);
	
	return jsonResult;
	
	function StatementProcessor(citationType) {
		var labelFunction;
		if (citationType == "KEYWORD") {
			labelFunction = labelOfKeyword;
		} else if (citationType == "MESH"){
			labelFunction = labelOfMeshTerm;
		} else if (citationType == "INFERRED"){
			labelFunction = labelOfInferredTerm;
		} 
		
		return {processStatement: processStatement};
	
		function labelOfKeyword(statement) {
			return statement.object.value;
		}
		function labelOfMeshTerm(statement) {
			return graph.any(statement.object, RDFS("label")).value;
		}
		function labelOfInferredTerm(statement) {
			return statement.object.value;
		}

		function processStatement(statement) {
			var articleUri = statement.subject.uri;
			var keyword = labelFunction(statement);
			var bucket = findBucket() || createBucket();
			addToBucket(articleUri, bucket);

			function findBucket() {
				return jsonResult.find(bucketMatcher);
				
				function bucketMatcher(bucket) {
					return toMatcher(keyword) === bucket.matcher;
				}
			}
			
			function createBucket() {
				var bucket = {
						matcher: toMatcher(keyword),
						text: toDisplay(keyword),
						entities: []
				};
				jsonResult.push(bucket);
				return bucket;
				
				function toDisplay(keyword) {
					return keyword.charAt(0).toUpperCase() + keyword.slice(1);
				}
			}
			
			function toMatcher(keyword) {
				return keyword.toLowerCase();
			}
	
			function addToBucket(uri, bucket) {
				var label = graph.any($rdf.sym(uri), RDFS("label"));
				if (label && label.value) {
					var displayUri = ScholarsVis.Utilities.toDisplayUrl(uri);
					var entity = findEntity() || createEntity();
					addToEntity(entity);
				}
				
				function findEntity() {
					return bucket.entities.find(entityMatcher);
					
					function entityMatcher(entity) {
						return displayUri === entity.uri;
					}
				}
				
				function createEntity() {
					var entity = {
	 	 				uri: displayUri,
	 	 				text: label.value,
	 	 				citationTypes: []
					};
					bucket.entities.push(entity);
					return entity;
				}

				function addToEntity(entity) {
					if (! entity.citationTypes.includes(citationType)) {
						entity.citationTypes.push(citationType) ;
					}
				}
			}
		}
	}
}

/*******************************************************************************
 * 
 * Process the transformed data:
 *    Filter keyword structures by one or more citation types.
 *    Sort keywords by resulting number of citations.
 *    Trim to the 20 most commonly used keywords (or options.maxKeywords, 
 *        if provided).
 *        
 * The transformed data appears in the format described in transform_word_cloud_data().
 * 
 * filterSortAndSlice() produces output in the format that the display routine 
 * expectes:
 * [
 *   {
 *     "text": "prostate cancer",
 *     "size": 3,
 *     "entities": [
 *       {
 *         "uri": "/scholars/display/UR-380249",
 *         "text": "E-selectin ligand-1 controls circulating prostate cancer cell rolling/adhesion and metastasis"
 *       },
 *       {
 *         "uri": "/scholars/display/UR-19472",
 *         "text": "Human fucosyltransferase 6 enables prostate cancer metastasis to bone"
 *       }
 *     ]
 *   }
 * ]
 * This is the result of filtering the example data from transform_word_cloud_data()
 * on the type array ["KEYWORD", "MESH"]. Note that the second citation counts 
 * twice (has both citation types), for a total size of 3. 
 * 
 * The resulting array is sorted by size, and trimmed to the most used keywords.
 * 
 * Parameters:
 *   unfiltered -- the output from transform_word_cloud_data().
 *   options -- the options structure provided by the visualization framework.
 *   citationTypes -- a String or an Array of Strings containing the type(s) to
 *        filter against. Accepted types include "KEYWORD" and "MESH". 
 * 
 ******************************************************************************/
function filterSortAndSlice(unfiltered, options, citationTypes) {
	var maxKeywords = Math.max(options.maxKeywords || 20, 5);
	var typesArray = [].concat(citationTypes);
	
	return unfiltered.reduce(listFilter, []).sort(compareSizes).slice(0, maxKeywords);
	//return unfiltered.sort(compareSizes).slice(0, maxKeywords).reduce(listFilter, []);

	function listFilter(keywordsSoFar, keywordStruct) {
		var filteredEntities = keywordStruct.entities.reduce(entityFilter, []);
		var size = filteredEntities.length;
		if (size > 0) {
			keywordsSoFar.push({
				text: keywordStruct.text,
				size: size,
			    entities: filteredEntities
			});
		}
		return keywordsSoFar;
		
		function entityFilter(entitiesSoFar, entity) {
			if (entity.citationTypes.reduce(typeMatcher, false)) {
				entitiesSoFar.push({
					uri: entity.uri,
					text: entity.text,
					citationsTypes: entity.citationTypes
				});
			}
			return entitiesSoFar;
			
			function typeMatcher(matchingSoFar, type) {
				return matchingSoFar || typesArray.includes(type);
			}
		}
	}

	function compareSizes(a, b) {
	  return b.size - a.size;
	  //return b.entities.length - a.entities.length;
	}
}


/*******************************************************************************
 * 
 * Draw the word cloud from the transformed data.
 * 
 * Options:
 *   interactive -- Hovering over a keyword will cause it to brighten in color. 
 *                    Clicking on a keyword will show a tooltip.
 *                    Defaults to true.
 *   scaleRange -- A two-element array that determines the fontsize of the smallest
 *                    and largest keywords. Defaults to [15, 60].
 ******************************************************************************/
var allWords = [];
var initialLoad = true;
var targetDiv; 
var currentOptions;
var types = ["KEYWORD","MESH","INFERRED"];
var keywords;

function draw_word_cloud(unfiltered, target, options) {

    if (!unfiltered || unfiltered.length == 0) {
      return;
    }
    
	targetDiv = target; 
    currentOptions = options;

	keywords = filterSortAndSlice(unfiltered, options, types);
	//	var keywords = filterSortAndSlice(unfiltered, options, "KEYWORD");
	
	if(initialLoad){
		allWords = unfiltered;
		initialLoad = false;
	}

	var isInteractive =  (typeof(options.interactive) == 'undefined') || options.interactive;
	var scaleRange = options.scaleRange || [15, 50];

	var height_margin = 50;
	var width_margin = 40;
	 
	var height = Math.floor($(target).height()-height_margin);
	var width = Math.floor($(target).width()-width_margin);

	var fill = d3.scale.category20();
   
   	var keywordScale = d3.scale.linear().range(scaleRange);
     
   var tip = d3.tip().attr('class', 'wcloud-tip d3-tip choices triangle-isosceles').html(function(d) { 
     var repr = "";
     for(var i = 0; i < d.entities.length; i++) {
       repr += "<div class='kwhoverable'><a href='" + d.entities[i].uri + "'>" +(i+1)+". " + d.entities[i].text + "</a></div>";
     }
     return repr; 
   });

   keywordScale.domain([
                        d3.min(keywords, function(d) { return d.size; }),
                        d3.max(keywords, function(d) { return d.size; })
                        ]);

   var wordsToFills = {};
   
   d3.layout.cloud().size([width, height])
   	.words(keywords)
   	.rotate(function() { return ~~(Math.random() * 2) * 90; })
   	.font("Tahoma")
   	.fontSize(function(d) {
   		return keywordScale(d.size);
   	})
   	.on("end", draw)
   	.start();


   // RGB utility functions

   function parseRgb(rgbString) {
   	var commaString = rgbString.substring(4, rgbString.length - 1);
   	var numberStrings = commaString.split(",");
   	var nums = [];
   	for(var i = 0; i < numberStrings.length; i++) {
   		nums.push(parseInt(numberStrings[i]));
   	}
   	return nums;
   }

   function brighten(rgbs, p) {
   	var result = [];
   	for(var i = 0; i < rgbs.length; i++) {
   		if(rgbs[i] + 20 <= 255) {
   			result.push(rgbs[i] + p);
   		}
   		else {
   			result.push(255);
   		}
   	}
   	return result;
   }

   function toRgbString(rgbs) {
   	return "rgb(" + rgbs[0] + "," + rgbs[1] + "," + rgbs[2] + ")";
   }
   	
function draw(input) {

	if(input.length == 0) return;

   	var svg = d3.select(target)
   		.append("svg")
  		.attr("width", width)
  		.attr("height", height).attr("id", "stage")
   		.append("g")
  		.attr("transform", "translate("+(width/2)+","+(height/2)+")");

  	var cloud = svg.selectAll("g text")
        .data(input); 
    
    //Entering words
    cloud.enter()
        .append("text")
        .style("font-family", "Tahoma")
        .attr("class", "word")
        .style("fill", function(d, i) { 
        	var wordFill = fill(i);
   			wordsToFills[d.text] = wordFill;
   			return wordFill; 
   		})
        .attr("text-anchor", "middle")
        .attr('font-size', 1)
        .text(function(d) { return d.text; })
        .call(addKeywordActivity);  // for tooltips

        //Entering and existing words
 		if(currentOptions.animation){
			cloud.transition()
        		.duration(600)
        		.style("font-size", function(d) { return d.size + "px"; })
        		.attr("transform", function(d) {
            		return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        		})
        		.style("fill-opacity", 1);

        	//Exiting words
   			cloud.exit()
        		.transition()
        		.duration(200)
        		.style('fill-opacity', 1e-6)
        		.attr('font-size', 1)
        		.remove();
 		}else{
 			cloud.style("font-size", function(d) { return d.size + "px"; })
        		.attr("transform", function(d) {
            		return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        		})
        		.style("fill-opacity", 1);
 		}
 		
   	function addKeywordActivity(keywords) {
   		if (isInteractive) {
		    	keywords
		    	.call(tip)
		    	.on('click', tip.show) 
		    	.on('mouseover', function(d) {
		    		d3.select(this).style("cursor", "pointer");
		    		var currentColor = d3.select(this).style("fill");
		    		var rgbs = parseRgb(currentColor);
		    		var brighterFill = toRgbString(brighten(rgbs, 40));
		    		d3.select(this).style("fill", brighterFill);
		    	}).on('mouseout', function(d) {
		    		d3.select(this).style("fill", wordsToFills[d.text]);
		    	});
   		}
   	}
   }

   if (isInteractive) {
   	$ (document).click(function(e) {
   		if((!$(e.target).closest('text').length && !$(e.target).is('text')) || 
   		   (!$(e.target).closest('#stage').length && !$(e.target).is('#stage'))) {
   			tip.hide();
   		}
   	});
   }
};

/*******************************************************************************
 * Close the word cloud dialog box, and any lingering tooltips.
 ******************************************************************************/
function close_word_cloud(target) {
	$(target).children("svg").remove();
	$('div.d3-tip').remove();
}

/*Returns the status of the checkboxes as an array*/
function getChecks(){
 var all = d3.select("#all").property("checked");
 var keyword = d3.select("#keyword").property("checked"); 
 var ext = d3.select("#mesh").property("checked");
 var inf = d3.select("#inferred").property("checked");
 return [all, keyword, ext, inf];  
}

$(document).ready(function(){
	d3.selectAll(".radio").on("change", function(){
 		var checks = getChecks(); 
		types = [];
 		if(checks[0] == true){
 			types.push("MESH");
			types.push("KEYWORD");
			types.push("INFERRED");
		}else if(checks[1] == true){
			types.push("KEYWORD");
		}else if(checks[2] == true){
			types.push("MESH");
		}else if(checks[3] == true){
			types.push("INFERRED");
		}
		d3.select(targetDiv).selectAll("svg").remove(); 
		draw_word_cloud(allWords, targetDiv, currentOptions); 

	});
}); 

/*******************************************************************************
 * 
 * Export the visualization data.
 * 
 ******************************************************************************/
function exportWcVisAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, data);
}

function exportWcVisAsSvg(data, filename, options) {
    ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
}

/*******************************************************************************
 * 
 * Fill the Person Word Cloud table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawPersonWcTable(data, target, options) {
    var tableElement = $(target).find(".vis_table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForPersonTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(rowData.keyword, rowData.types, createLink(rowData.publication, rowData.uri));
        
        function createLink(text, uri) {
            return "<a href='" + uri + "'>" + text + "</a>"
        }
    }
}

function closePersonWcTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportPersonWcTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForPersonTable(data));
}

function exportPersonWcTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForPersonTable(data));
}

function transformAgainForPersonTable(data) {
    var tableData = [];
    data.forEach(doKeyword);
    return tableData;
    
    function doKeyword(keywordData) {
        keywordData.entities.forEach(doEntity); 
        
        function doEntity(entityData) {
            var row = {
                    keyword: keywordData.text, 
                    types: entityData.citationTypes.sort().join(" "),
                    publication: entityData.text,
                    uri: entityData.uri
            };
            tableData.push(row);
        }
    }
}

/*******************************************************************************
 * 
 * Fill the Department Word Cloud table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawDepartmentWcTable(data, target, options) {
    var tableElement = $(target).find(".vis_table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForDepartmentTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(rowData.keyword, createLink(rowData.name, rowData.uri));
        
        function createLink(text, uri) {
            return "<a href='" + uri + "'>" + text + "</a>"
        }
    }
}

function closeDepartmentWcTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportDepartmentWcTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForDepartmentTable(data));
}

function exportDepartmentWcTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForDepartmentTable(data));
}

function transformAgainForDepartmentTable(data) {
    var tableData = [];
    data.forEach(doKeyword);
    return tableData;
    
    function doKeyword(keywordData) {
        keywordData.entities.forEach(doEntity); 
        
        function doEntity(entityData) {
            var row = {
                keyword: keywordData.text, 
                name: entityData.text,
                uri: entityData.uri
            };
            tableData.push(row);
        }
    }
}
