function PersonWordCloud(uri) {
	var width = 1000;
	var height = 700;
	var fill = d3.scale.category20();
	
	d3.text(uri, receiveData);

	function receiveData(data) {
		var keywords = transformData(data);
		var keywordScale = createScale(keywords); 
		doTheLayout(keywords, keywordScale);

		function transformData(data) {
			var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");
			var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");
			var graph = $rdf.graph();

			try {
			    $rdf.parse(data, graph, "http://graph.name", "text/turtle");
			    var keywordSet = buildKeywordSet();
			    var keywordArray = populateKeywordArray(keywordSet);
			    return sortAndSlice(keywordArray);
			} catch (err) {
    			console.log(err)
    			return []
			}

			function buildKeywordSet() {
				var stmts = graph.statementsMatching(undefined, VIVO('freetextKeyword'));
				var set = new Set();
				for (let stmt of stmts) {
					set.add(stmt.object.toString());
				}
				return set;
			}
			
			function populateKeywordArray(keywordSet) {
			    var keywordArray = [];
			    for (let keyword of keywordSet) {
			    	keywordArray.push(gatherKeywordInfo(keyword));
			    }
			    return keywordArray;
			}

			function gatherKeywordInfo(keyword) {
				var linkInfo = []
				var stmts = graph.statementsMatching(undefined, undefined, keyword);
				for (let stmt of stmts) {
					linkInfo.push(getLinkInfo(stmt.subject))
				}
				return {text: keyword, size: stmts.length, links: linkInfo}
			
				function getLinkInfo(subject) {
					var label = graph.any(subject, RDFS("label"))
					return {uri: subject.uri, label: label.toString()}
				}
			}
			
			function sortAndSlice(keywordArray) {
				return keywordArray.sort(compareSizes).slice(0, 30);
				
				function compareSizes(a, b) {
					return b.size - a.size;
				}
			}
		}

		function createScale(keywords) {
			var keywordScale = d3.scale.linear().range([ 10, 60 ]);
			keywordScale.domain([ d3.min(keywords, getSize),
					d3.max(keywords, getSize) ]);
			return keywordScale;

			function getSize(d) {
				return d.size;
			}
		}
		
		function doTheLayout(keywords, keywordScale) {
			d3.layout.cloud().size([ width, height ]).words(keywords).rotate(
					wordAngle).font("Impact").fontSize(scaledSize).on("end",
					draw).start();

			function wordAngle() {
				return ~~(Math.random() * 2) * 90;
			}

			function scaledSize(d) {
				return keywordScale(d.size);
			}

			function draw(words) {
				d3.select("#person_word_cloud").append("svg").attr("width",
						width).attr("height", height).append("g").attr(
						"transform",
						"translate(" + (width / 2) + "," + (height / 2) + ")")
						.selectAll("text").data(words).enter().append("text")
						.style("font-size", sizer).style("font-family",
								"Impact").style("fill", filler).attr(
								"text-anchor", "middle").attr("transform",
								transformer).text(getText);

				function sizer(d) {
					return d.size + "px";
				}

				function transformer(d) {
					return "translate(" + [ d.x, d.y ] + ")rotate(" + d.rotate
							+ ")";
				}

				function filler(d, i) {
					return fill(i);
				}

				function getText(d) {
					return d.text;
				}
			}
		}
	}
}

$(document).ready(PersonWordCloud(word_cloud_data_uri))