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
 * 
 * The resulting array is sorted alphabetically by size, and limited to the 20 most used keywords.
 * 
 * Options:
 *   maxKeywords -- The transformed data will be truncated after this many keywords.
 *                    defaults to 20 keywords, may not be set to less than 5.
 */
function transform_word_cloud_data(graph, options) {
	var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
	var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");

	var maxKeywords = Math.max(options.maxKeywords || 20, 5);

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
					bucket.entities.push({
 	 					uri: uri, 
 	 					text: labelText
 	 				});
					bucket.size = bucket.size + 1;
				}
				
				function findUri(entity) {
					return entity.uri === uri;
				}
			}
		}
	}
	
	 function sortAndSlice(jsonResult) {
		 return jsonResult.sort(compareSizes).slice(0, maxKeywords);
	
		 function compareSizes(a, b) {
			 return b.size - a.size;
		}
	}
}
 
function close_word_cloud(target) {
	$(target).children("svg").remove();
	$('div.d3-tip').remove();
}


