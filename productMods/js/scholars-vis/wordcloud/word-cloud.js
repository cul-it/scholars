ScholarsVis["PersonWordCloud"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/person_word_cloud?person=" + options.person,
		    parse : 'turtle',
	    	transform : transform_word_cloud_data,
		    display : draw_word_cloud,
		    closer : close_word_cloud,
		    
		    maxKeywords : 50,
		    interactive : true,
		    scaleRange : [15, 60]
		};
	return new ScholarsVis.Visualization(options, defaults);
};

ScholarsVis["IconizedPersonWordCloud"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/person_word_cloud?person=" + options.person,
		    parse : 'turtle',
	    	transform : transform_word_cloud_data,
		    display : draw_word_cloud,
		    closer : close_word_cloud,
		    
		    maxKeywords : 50,
		    interactive : false,
		    scaleRange : [2, 18]
		};
	return new ScholarsVis.Visualization(options, defaults);
};

ScholarsVis["DepartmentWordCloud"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/department_word_cloud?department=" + options.department,
		    parse : 'turtle',
	    	transform : transform_word_cloud_data,
		    display : draw_word_cloud,
		    closer : close_word_cloud,
		    
		    maxKeywords : 100,
		    interactive : true,
		    scaleRange : [15, 60]
		};
	return new ScholarsVis.Visualization(options, defaults);
};

ScholarsVis["IconizedDepartmentWordCloud"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/department_word_cloud?department=" + options.department,
		    parse : 'turtle',
	    	transform : transform_word_cloud_data,
		    display : draw_word_cloud,
		    closer : close_word_cloud,
		    
		    maxKeywords : 100,
		    interactive : false,
		    scaleRange : [2, 18]
		};
	return new ScholarsVis.Visualization(options, defaults);
};

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

	var jsonResult = [];

	var stmts = graph.statementsMatching(undefined, VIVO('freetextKeyword'));
	stmts.forEach(new StatementProcessor("KEYWORD").processStatement);

	stmts = graph.statementsMatching(undefined, VIVO('hasSubjectArea'));
	stmts.forEach(new StatementProcessor("MESH").processStatement);
	
	return jsonResult;
	
	function StatementProcessor(citationType) {
		var labelFunction;
		if (citationType == "KEYWORD") {
			labelFunction = labelOfKeyword;
		} else {
			labelFunction = labelOfMeshTerm;
		}
		
		return {processStatement: processStatement};
	
		function labelOfKeyword(statement) {
			return statement.object.value;
		}
		
		function labelOfMeshTerm(statement) {
			return graph.any(statement.object, RDFS("label")).value;
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
					var displayUri = toDisplayPageUrl(uri);
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
					text: entity.text
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
function draw_word_cloud(unfiltered, target, options) {
//	var keywords = filterSortAndSlice(unfiltered, options, ["MESH", "KEYWORD"]);
	var keywords = filterSortAndSlice(unfiltered, options, "KEYWORD");

	 var isInteractive =  (typeof(options.interactive) == 'undefined') || options.interactive;
	 var scaleRange = options.scaleRange || [15, 60];

	 var height_margin = 20;
	 var width_margin = 20;
	 
	 var height = Math.floor($(target).height()-height_margin);
	 var width = Math.floor($(target).width()-width_margin);

	 if (keywords.length == 0) {
		 $(target).html("<div>No Research Keywords</div>");
		 return;
	 }

	var fill = d3.scale.category20();
   
   var keywordScale = d3.scale.linear().range(scaleRange);
     
   var tip = d3.tip().attr('class', 'd3-tip choices triangle-isosceles').html(function(d) { 
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
   	.font("Impact")
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

   function draw(words) {
   	d3.select(target)
   	.append("svg")
  		.attr("width", width)
  		.attr("height", height)
  		.attr("id", "stage")
   	.append("g")
  		.attr("transform", "translate("+(width/2)+","+(height/2)+")")
   	.selectAll("text")
   	.data(words)
   	.enter().append("text")
   	.style("font-size", function(d) { return d.size + "px"; })
   	.style("font-family", "Tahoma")
   	.style("fill", function(d, i) {
   		var wordFill = fill(i);
   		wordsToFills[d.text] = wordFill;
   		return wordFill;
   	})
   	.attr("text-anchor", "middle")
   	.attr("transform", function(d) {
   		return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
   	})
   	.text(function(d) { return d.text; }).call(addKeywordActivity);
   	
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
