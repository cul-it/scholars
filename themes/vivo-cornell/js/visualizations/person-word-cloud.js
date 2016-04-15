function PersonWordCloud(uri) {
	var width = 1000;
	var height = 700;
	var fill = d3.scale.category20();
	
	d3.csv(uri, receiveData);

	function receiveData(data) {
		var keywords = transformData(data);
		var keywordScale = createScale(keywords); 
		doTheLayout(keywords, keywordScale);

		function transformData(data) {
			return data.filter(dataFilter).map(dataMapper).sort(dataSorter)
					.slice(0, 30);

			function dataFilter(d) {
				return +d.count > 1;
			}
			
			function dataMapper(d) {
				return {
					text : d.keyword,
					size : +d.count,
				};
			}
			
			function dataSorter(a, b) {
				return d3.descending(a.size, b.size);
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