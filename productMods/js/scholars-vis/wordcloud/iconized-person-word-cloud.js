function iconize_word_cloud_data(graph) {
	var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
	var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");

	var keywordSet = buildKeywordSet();
	var keywordArray = populateKeywordArray(keywordSet);
	return sortAndSlice(keywordArray);

	function buildKeywordSet() {
		var stmts = graph
				.statementsMatching(undefined, VIVO('freetextKeyword'));
		return new Set(stmts.map(getObjectValue));

		function getObjectValue(stmt) {
			return stmt.object.value
		}
	}

	function populateKeywordArray(keywordSet) {
		return Array.from(keywordSet).map(gatherKeywordInfo)
	}

 	function gatherKeywordInfo(keyword) {
 		var stmts = graph.statementsMatching(undefined, undefined, keyword);
 		return {
 			text : keyword,
 			size : stmts.length,
 			entities : stmts.map(getEntityInfo).filter(hasLabel)
 		}

 		function getEntityInfo(stmt) {
 			var info = {uri : toDisplayPageUrl(stmt.subject.uri)};
 			var label = graph.any(stmt.subject, RDFS("label"));
 			if (label) {
 				info["text"] = label.value;
 			}
 			return info;
 		}
 		function hasLabel(entity) {
 			return entity.text && entity.text.length > 0 
 		}
	}


	function sortAndSlice(keywordArray) {
		return keywordArray.sort(compareSizes).slice(0, 50);

		function compareSizes(a, b) {
			return b.size - a.size;
		}
	}
}
 
 function draw_iconized_word_cloud(keywords, target) {
	 var height = 110;//$(target).height();
	 var width = 220;//$(target).width();

	 if (keywords.length == 0) {
		 $(target).html("<div>No Research Keywords</div>");
		 return;
	 }

	var fill = d3.scale.category20();
    
    var keywordScale = d3.scale.linear().range([2,18]);
     
/*    var tip = d3.tip().attr('class', 'd3-tip choices triangle-isosceles').html(function(d) { 
      var repr = "";
      for(var i = 0; i < d.entities.length; i++) {
        repr += "<div class='hoverable'><a href='" + d.entities[i].uri + "'>" + d.entities[i].text + "</a></div>";
      } 
      return repr; 
    });
*/
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
    	.text(function(d) { return d.text; })//.call(tip)
   /* 	.on('click', tip.show) 
    	.on('mouseover', function(d) {
    		d3.select(this).style("cursor", "pointer");
    		var currentColor = d3.select(this).style("fill");
    		var rgbs = parseRgb(currentColor);
    		var brighterFill = toRgbString(brighten(rgbs, 40));
    		d3.select(this).style("fill", brighterFill);
    	}).on('mouseout', function(d) {
    		d3.select(this).style("fill", wordsToFills[d.text]);
    	}); */
    }

    $(document).click(function(e) {
    	if(!$(e.target).closest('#stage').length && !$(e.target).is('#stage')) {
    	//	tip.hide();
    	}
    });
 };
 