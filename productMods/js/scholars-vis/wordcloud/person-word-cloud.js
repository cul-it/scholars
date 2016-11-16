ScholarsVis["PersonWordCloud"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/person_word_cloud?person=" + options.person,
		    parse : 'turtle',
	    	transform : transform_word_cloud_data,
		    display : draw_word_cloud,
		    closer : close_word_cloud
		};
	return new ScholarsVis.Visualization(options, defaults);
};

function close_word_cloud(target) {
	$(target).children("svg").remove();
	$('div.d3-tip').remove();
}

/**
 * Transform the RDF graph into the JSON structure that is expected by draw_word_cloud
 * 
 * Here is an example of the output:
 * [
 *   {
 *     "text": "prostate cancer",
 *     "size": 2,
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
 * 
 * The transformation ensures that:
 * -- Two keywords are considered the same if the only difference is capitalization.
 * -- If an article lists two equivalent keywords (differ only in case), only one is counted.
 * -- On display, the first letter of each keyword is capitalized.
 * -- If an article has no label, it is ignored.
 */
function transform_word_cloud_data(graph) {
	var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
	var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");

	var jsonResult = [];
	var stmts = graph.statementsMatching(undefined, VIVO('freetextKeyword'));
	stmts.forEach(processStatement);
	return sortAndSlice(jsonResult);

	function processStatement(statement) {
		var articleUri = statement.subject.uri;
		var keyword = statement.object.value;
		var bucket = getBucket(keyword);
		addToBucket(articleUri, bucket);
		
		function getBucket(keyword) {
			return findBucket(keyword) || createBucket(keyword);
			
			function findBucket(keyword) {
				return jsonResult.find(bucketMatcher);
				
				function bucketMatcher(bucket) {
					return toMatcher(keyword) === bucket.matcher;
				}
			}
			
			function createBucket(keyword) {
				var bucket = {
						matcher: toMatcher(keyword),
						text: toDisplay(keyword),
						size: 0,
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
		}

		function addToBucket(uri, bucket) {
			var label = graph.any($rdf.sym(uri), RDFS("label"));
			if (label && label.value) {
				addToEntities(label.value);
			}
			
			function addToEntities(labelText) {
				if (! bucket.entities.find(findUri)) {
					bucket.entities.push({uri: uri, text: labelText});
					bucket.size = bucket.size + 1;
				}
				
				function findUri(entity) {
					return entity.uri === uri;
				}
			}
		}
	}
	
	 function sortAndSlice(jsonResult) {
		 return jsonResult.sort(compareSizes).slice(0, 50);
	
		 function compareSizes(a, b) {
			 return b.size - a.size;
		}
	}
}
 
 function draw_word_cloud(keywords, target) {
	 var height = Math.floor($(target).height());
	 var width = Math.floor($(target).width());

	 if (keywords.length == 0) {
		 $(target).html("<div>No Research Keywords</div>");
		 return;
	 }

	var fill = d3.scale.category20();
    
    var keywordScale = d3.scale.linear().range([15,60]);
      
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
    	.style("font-family", "Impact")
    	.style("fill", function(d, i) {
    		var wordFill = fill(i);
    		wordsToFills[d.text] = wordFill;
    		return wordFill;
    	})
    	.attr("text-anchor", "middle")
    	.attr("transform", function(d) {
    		return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    	})
    	.text(function(d) { return d.text; }).call(tip)
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

    $(document).click(function(e) {
    	if((!$(e.target).closest('text').length && !$(e.target).is('text')) || (!$(e.target).closest('#stage').length && !$(e.target).is('#stage'))){
         	tip.hide();
    	}
    });
 };
 