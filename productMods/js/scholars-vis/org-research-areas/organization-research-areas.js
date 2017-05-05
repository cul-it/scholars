ScholarsVis["OrganizationResearchAreas"] = function(options) {
	var defaults = {
		    url : applicationContextPath + "/api/dataRequest/organization_research_areas?organization=" + options.organization,
		    parse : 'turtle',
		    transform : transformFlaredata,
		    display : plotConceptMap,
                    closer : closeConceptMap,
		};
	return new ScholarsVis.Visualization(options, defaults);
};

function transformFlaredata(graph) {
	var BIBO = $rdf.Namespace("http://purl.org/ontology/bibo/");
	var FOAF = $rdf.Namespace("http://xmlns.com/foaf/0.1/");
	var RDF = $rdf.Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
	var RDFS = $rdf.Namespace("http://www.w3.org/2000/01/rdf-schema#");
	var SCHOLARS = $rdf.Namespace("http://scholars.cornell.edu/individual/");
	var SKOS = $rdf.Namespace("http://www.w3.org/2004/02/skos/core#");
	var VIVO = $rdf.Namespace("http://vivoweb.org/ontology/core#");

	return {
		"ditems": figureDItems(),
		"themes": figureThemes()
	}
	
	function figureDItems() {
		var stmts = graph.statementsMatching(undefined, RDF("type"), FOAF("Person"))
		return stmts.map(figureDItem).sort(sortByName);

		function figureDItem(stmt, index) {
			var author = stmt.subject.uri;
			return {
				"type"  : "ditem",
				"ditem" : index, 
				"name"  : getLabel(author),
				"url"   : toDisplayPageUrl(author),
				"links" : figureLinks()
			}

			function figureLinks() {
				var authorships = findAuthorships();
				var articles = authorships.map(findArticles).reduce(flattener, []);
				var journals = articles.map(findJournals).reduce(flattener, []);
				var subjectAreas = journals.map(findSubjectAreas).reduce(flattener, []);
				var labels = new Set(subjectAreas.map(getLabel));
				return Array.from(labels);

				function findAuthorships() {
					var stmts = graph.statementsMatching($rdf.sym(author), VIVO("relatedBy"), undefined)
					return stmts.map(getObjectUri);
				}
				
				function findArticles(authorship) {
					var stmts = graph.statementsMatching($rdf.sym(authorship), VIVO("relates"), undefined)
					var uris = stmts.map(getObjectUri);
					var authorHere = uris.indexOf(author)
					if (authorHere >= 0) {
						uris.splice(authorHere, 1) 
					}
					return uris;
				}
				function findJournals(article) {
					var stmts = graph.statementsMatching($rdf.sym(article), VIVO("hasPublicationVenue"), undefined)
					return stmts.map(getObjectUri);
				}
				
				function findSubjectAreas(journal) {
					var stmts = graph.statementsMatching($rdf.sym(journal), VIVO("hasSubjectArea"), undefined)
					return stmts.map(getObjectUri);
				}
				
				function flattener(array, addition) {
					return array.concat(addition);
				}
			}
		}
	}
	
	function figureThemes() {
		var stmts = graph.statementsMatching(undefined, RDF("type"), SKOS("Concept"))
		var uris = Array.from(new Set(stmts.map(getSubjectUri)));
		return uris.map(figureTheme).sort(sortByName);
		
		function figureTheme(uri) {
			var label = getLabel(uri);
			return {
				"type"        : "theme",
				"name"        : label,
				"description" : "",
				"slug"        : label,
				"uri"         : uri
			}
		}
	}
	
	function getLabel(uri) {
		return graph.any($rdf.sym(uri), RDFS("label")).value;
	}
	
	function getSubjectUri(stmt) {
		return stmt.subject.uri;
	}
	
	function getObjectUri(stmt) {
		return stmt.object.uri;
	}
	function sortByName(a, b) {
		var aname = a.name.toLowerCase();
		var bname = b.name.toLowerCase();
		return aname > bname ? 1 : (aname < bname ? -1 : 0);
	}
	
}

function plotConceptMap(flaredata, target) {
	
		function addNewlines(str) {
		var splitStr = str.split(" ");
		var subarrays = [];
		var wordsInSubstring = 3;
		for (var i = 0; i < splitStr.length; i += wordsInSubstring) {
			subarrays.push(splitStr.slice(i, i + wordsInSubstring));
		}
		var substrings = [];
		for (var i = 0; i < subarrays.length; i++) {
			substrings.push(subarrays[i].join(" "));
		}
		var result = "<tspan x='0' dy='0'>" + substrings[0] + "</tspan>";
		for (var i = 1; i < substrings.length; i++) {
			result += "<tspan x='0' dy='1.2em'>" + substrings[i] + "</tspan>";
		}
		return result;
	}
	// edit slugs
	for (var i = 0; i < flaredata["themes"].length; i++) {
		flaredata["themes"][i]["slug"] = addNewlines(flaredata["themes"][i]["slug"]);
		flaredata["themes"][i]["name"] = addNewlines(flaredata["themes"][i]["name"]);
	}
	// edit links
	for (var i = 0; i < flaredata["ditems"].length; i++) {
		var links = flaredata["ditems"][i]["links"];
		for (var j = 0; j < links.length; j++) {
			links[j] = addNewlines(links[j]);
		}
	}
	var plot = ConceptMap("graph", "graph-info", flaredata);

	function ConceptMap(chartElementId, infoElementId, dataJson) {
	    var width = Math.floor($(target).width());
	    var height = Math.floor($(target).height());
//		var width = 999;// document.body.clientWidth; //window.innerWidth ||
//		// document.documentElement.clientWidth ||
//		// document.body.clientWidth;
//		var height = 600; // window.innerHeight ||
		// document.documentElement.clientHeight ||
		// document.body.clientHeight;
		var a = width, c = height, h = c, U = 180, // width of the person
													// fields.
		K = 17, // height of the person field area.
		S = 20, s = 8, R = -15, // Radius for node circle 110
		J = 30, o = 15, // placement
		t = 10, w = 1000, F = "elastic", N = "#0da4d3";
		var T, q, x, j, H, A, P;
		var L = {}, k = {};
		var i, y;
		var r = d3.layout.tree().size([ 360, h / 2 - R ]).separation(
				function(Y, X) {
					return (Y.parent == X.parent ? 1 : 2) / Y.depth
				});
		var W = d3.svg.diagonal.radial().projection(function(X) {
			return [ X.y, X.x / 180 * Math.PI ]
		});
		var v = d3.svg.line().x(function(X) {
			return X[0]
		}).y(function(X) {
			return X[1]
		}).interpolate("bundle").tension(0.5);
		// Node name at Footer
		var Nh = (c / 2) + 100;
		var svgHeight = height + 250;
		var d = d3.select(target).append("div").attr("class", "conceptmap").append("svg").attr("id", "svg-id").attr("width", a)
				.attr("height", svgHeight).append("g").attr("transform",
						"translate(" + a / 2 + "," + Nh + ")");
		// var I = d.append("rect").attr("class", "bg").attr({
		// 	x : a / -2,
		// 	y : c / -3,
		// 	width : a,
		// 	height : c,
		// 	fill : "transparent"
		// }).on("click", O);
		var B = d.append("g").attr("class", "links"), f = d.append("g").attr(
				"class", "ditems"), E = d.append("g").attr("class", "nodes");

		var Q = d3.select(target).append("div").attr("class", "graph-info");

		T = d3.map(dataJson);
		q = d3.merge(T.values());
		x = {};
		A = d3.map();

		/** ******************* */
		var outerId = [ 0 ];
		/** ******************* */

		q.forEach(function(aa) {
			aa.key = p(aa.name);
			aa.canonicalKey = aa.key;
			x[aa.key] = aa;

			if (aa.group) {
				if (!A.has(aa.group)) {
					A.set(aa.group, [])
				}
				A.get(aa.group).push(aa);
			}
		});

		/** *********Used for Node color on mouse over=Start********* */
		j = d3.map();

		T.get("ditems").forEach(function(aa) {
			aa.links = aa.links.filter(function(ab) {
				return typeof x[p(ab)] !== "undefined" // && ab.indexOf("r-")
														// !== 0
			});

			j.set(aa.key, aa.links.map(function(ab) {
				var ac = p(ab);
				if (typeof j.get(ac) === "undefined") {
					j.set(ac, [])
				}
				j.get(ac).push(aa);
				return x[ac];
			}));
		});
		/** *******Used for Node color on mouse over- End********** */
		var Z = window.location.hash.substring(1);
		if (Z && x[Z]) {
			G(x[Z]);
		} else {
			O();
			M();
		}

		window.onhashchange = function() {
			var aa = window.location.hash.substring(1);
			if (aa && x[aa]) {
				G(x[aa], true)
			}
		};

		function O() {
			if (L.node === null) {
				return

				

			}
			L = {
				node : null,
				map : {}
			};
			i = Math.floor(c / T.get("ditems").length);
			y = Math.floor(T.get("ditems").length * i / 2);
			T.get("ditems").forEach(function(af, ae) {
				af.x = U / -2;
				af.y = ae * i - y
			});
			// Half circular nodes var ad = 180 + J,
			// Full Circular nodes var ad = 0 + J,
			var ad = 0 + J,
			// Z = 360 - J,
			Z = 360 - J, ac = (Z - ad) / (T.get("themes").length - 1);
			T.get("themes").forEach(function(af, ae) {
				/* Node with rectangle= start */
				af.x = Z - ae * ac;
				af.y = h / 2 - R;
				// af.xOffset = -S;
				if (af.x > 180) {
					af.xOffset = -S;
				} else {
					af.xOffset = S;
				}
				af.depth = 1
				/* Node with rectange= End */
			});

			H = [];
			var ab, Y, aa, X = h / 2 - R;
			T.get("ditems").forEach(function(ae) {
				ae.links.forEach(function(af) {
					ab = x[p(af)];
					if (!ab || ab.type === "reference") {
						return

						

					}
					Y = (ab.x - 90) * Math.PI / 180;
					aa = ae.key + "-to-" + ab.key;
					if (ab.x > 180) {
						H.push({
							source : ae,
							target : ab,
							key : aa,
							canonicalKey : aa,
							x1 : ae.x + (ab.type === "theme" ? 0 : U),
							y1 : ae.y + K / 2,
							x2 : Math.cos(Y) * X + ab.xOffset,
							y2 : Math.sin(Y) * X
						})
					} else if (ae.x < 180) {
						H.push({
							source : ae,
							target : ab,
							key : aa,
							canonicalKey : aa,
							x1 : ae.x + (ab.type === "theme" ? U : 0),
							y1 : ae.y + K / 2,
							x2 : Math.cos(Y) * X + ab.xOffset,
							y2 : Math.sin(Y) * X
						})
					}
				})
			});
			P = [];
			A.forEach(function(af, ag) {
				var ae = (ag[0].x - 90) * Math.PI / 180;
				// a2 = (ag[1].x - 90) * Math.PI / 180, bulge = 20;
				P.push({
					x1 : Math.cos(ae) * X + ag[0].xOffset,
					y1 : Math.sin(ae) * X// ,
				// xx: Math.cos((ae + a2) / 2) * (X + bulge) + ag[0].xOffset,
				// yy: Math.sin((ae + a2) / 2) * (X + bulge),
				// x2: Math.cos(a2) * X + ag[1].xOffset,
				// y2: Math.sin(a2) * X
				})
			});
			window.location.hash = "";
			M()
		}

		function G(Y, X) {
			if (L.node === Y && X !== true) {
				if (Y.type === "ditem") {
					// window.location.href = Y.url;
					return

					

				}
				L.node.children.forEach(function(aa) {
					aa.children = aa._group
				});
				e();
				return

				

			}
			if (Y.isGroup) {
				L.node.children.forEach(function(aa) {
					aa.children = aa._group
				});
				Y.parent.children = Y.parent._children;
				e();
				return

				

			}
			Y = x[Y.canonicalKey];
			q.forEach(function(aa) {
				aa.parent = null;
				aa.children = [];
				aa._children = [];
				aa._group = [];
				aa.canonicalKey = aa.key;
				aa.xOffset = 0
			});
			L.node = Y;
			L.node.children = j.get(Y.canonicalKey);
			L.map = {};
			var Z = 0;
			L.node.children.forEach(function(ac) {
				L.map[ac.key] = true;
				ac._children = j.get(ac.key).filter(function(ad) {
					return ad.canonicalKey !== Y.canonicalKey
				});
				ac._children = JSON.parse(JSON.stringify(ac._children));
				ac._children.forEach(function(ad) {
					ad.canonicalKey = ad.key;
					ad.key = ac.key + "-" + ad.key;
					L.map[ad.key] = true
				});
				var aa = ac.key + "-group", ab = ac._children.length;
				ac._group = [ {
					isGroup : true,
					key : aa + "-group-key",
					canonicalKey : aa,
					name : ab,
					count : ab,
					xOffset : 0
				} ];
				L.map[aa] = true;
				Z += ab
			});
			L.node.children.forEach(function(aa) {
				aa.children = Z > 50 ? aa._group : aa._children
			});
			window.location.hash = L.node.key;
			e()
		}

		function n() {
			k = {
				node : null,
				map : {}
			};
			z()
		}

		function g(X) {
			if (k.node === X) {
				return

				

			}
			k.node = X;
			k.map = {};
			k.map[X.key] = true;
			if (X.key !== X.canonicalKey) {
				k.map[X.parent.canonicalKey] = true;
				k.map[X.parent.canonicalKey + "-to-" + X.canonicalKey] = true;
				k.map[X.canonicalKey + "-to-" + X.parent.canonicalKey] = true
			} else {
				j.get(X.canonicalKey).forEach(function(Y) {
					k.map[Y.canonicalKey] = true;
					k.map[X.canonicalKey + "-" + Y.canonicalKey] = true
				});
				H.forEach(function(Y) {
					if (k.map[Y.source.canonicalKey]
							&& k.map[Y.target.canonicalKey]) {
						k.map[Y.canonicalKey] = true
					}
				})
			}
			z()
		}

		function M() {
			V();
			B.selectAll("path").attr("d", function(X) {
				return v([ [ X.x1, X.y1 ], [ X.x1, X.y1 ], [ X.x1, X.y1 ] ])
			}).transition().duration(w).ease(F).attr(
					"d",
					function(X) {
						return v([ [ X.x1, X.y1 ], [ X.target.xOffset * s, 0 ],
								[ X.x2, X.y2 ] ])
					});
			D(T.get("ditems"));
			// b(d3.merge([T.get("themes"), T.get("perspectives")]));
			b(T.get("themes"));
			C([]);
			m(P);
			n();
			z()
		}

		function e() {
			var X = r.nodes(L.node);
			X.forEach(function(Z) {
				if (Z.depth === 1) {
					Z.y -= 20
				}
			});
			H = r.links(X);
			H.forEach(function(Z) {
				if (Z.source.type === "ditem") {
					Z.key = Z.source.canonicalKey + "-to-"
							+ Z.target.canonicalKey
				} else {
					Z.key = Z.target.canonicalKey + "-to-"
							+ Z.source.canonicalKey
				}
				Z.canonicalKey = Z.key
			});
			V();
			B.selectAll("path").transition().duration(w).ease(F).attr("d", W);
			D([]);
			b(X);
			C([ L.node ]);
			m([]);
			var Y = "";
			if (L.node.description) {
				Y = L.node.description
			}
			// Node Click Start
			if (L.node.name) {
				BindGridView(L.node.name);
			}
			// Node Click End
			Q.html(Y);
			n();
			z()
		}

		function b(X) {
			var X = E.selectAll(".node").data(X, u);
			var Y = X.enter().append("g").attr(
					"transform",
					function(aa) {
						var Z = aa.parent ? aa.parent : {
							xOffset : 0,
							x : 0,
							y : 0
						};
						return "translate(" + Z.xOffset + ",0)rotate("
								+ (Z.x - 90) + ")translate(" + Z.y + ")"
					}).attr("class", "node").on("mouseover", g).on("mouseout",
					n).on("click", G);
			Y.append("circle").attr("r", 0);
			Y.append("text").attr("stroke", "#fff").attr("stroke-width", 4)
					.attr("class", "label-stroke");
			Y.append("text").attr("font-size", 0).attr("class", "label");
			X.transition().duration(w).ease(F).attr(
					"transform",
					function(Z) {
						if (Z === L.node) {
							return null
						}
						// var aa = Z.isGroup ? Z.y + (7 + Z.count) : Z.y;
						var aa = Z.y;
						return "translate(" + Z.xOffset + ",0)rotate("
								+ (Z.x - 90) + ")translate(" + aa + ")"
					});
			X.selectAll("circle").transition().duration(w).ease(F).attr("r",
					function(Z) {
						if (Z == L.node) {
							return 90 // size of internal node
						} else {
							if (Z.isGroup) {
								return 7 + Z.count
							} else {
								return 3 // intermediate node's size
							}
						}
					});
			X.selectAll("text").transition().duration(w).ease(F).attr("dy",
					".3em").attr("font-size", function(Z) {
				if (Z.depth === 0) {
					return 11 // size of the text in the middle node.
				} else {
					return 11 // size of the external research areas.
				}
			}).attr("text-anchor", function(Z) {
				if (Z === L.node || Z.isGroup) {
					return "middle"
				}
				return Z.x < 180 ? "start" : "end"
			}).attr(
					"transform",
					function(Z) {
						if (Z === L.node) {
							return null
						} else {
							if (Z.isGroup) {
								return Z.x > 180 ? "rotate(180)" : null
							}
						}
						return Z.x < 180 ? "translate(" + t + ")"
								: "rotate(180)translate(-" + t + ")"
					});
			X.selectAll("text").html(function(d) {
				return d.name;
			});
			X.selectAll("text.label-stroke").attr("display", function(Z) {
				return Z.depth === 1 ? "block" : "none"
			});
			X.exit().remove()
		}

		function V() {
			var X = B.selectAll("path").data(H, u);
			X.enter().append("path").attr("d", function(Z) {
				var Y = Z.source ? {
					x : Z.source.x,
					y : Z.source.y
				} : {
					x : 0,
					y : 0
				};
				return W({
					source : Y,
					target : Y
				})
			}).attr("class", "link");
			X.exit().remove()
		}

		function C(Z) {
			var ac = d.selectAll(".detail").data(Z, u);
			var Y = ac.enter().append("g").attr("class", "detail");
			var ab = Z[0];
			if (ab && ab.type === "ditem") {
				var aa = Y.append("a").attr("xlink:href", function(ae) {
					return ae.url // url of the faculty member
				});
				aa.append("text").attr("fill", N).attr("text-anchor", "middle")
						.attr("y", (o + t) * -1).text("Faculty Page")
			} else {
				if (ab && ab.type === "theme") {
					var aa = Y.append("a").attr("xlink:href", function(ae) {
						return ae.url
					});
					aa.append("text").attr("fill", "#aaa").attr("text-anchor",
							"middle").attr("y", (o + t) * -1).text(
							"Subject Area")
				}
			}
			ac.exit().remove();
			var X = d.selectAll(".all-ditems").data(Z);
			X.enter().append("text").attr("text-anchor", "start").attr("x",
					a / -2 + t).attr("y", c / 2 - t).text("All Data").attr(
					"class", "all-ditems").on("click", O);
			X.exit().remove()
		}

		function D(Y) {
			var Y = f.selectAll(".ditem").data(Y, u);
			var X = Y.enter().append("g").attr("class", "ditem").on(
					"mouseover", g).on("mouseout", n).on("click", G);
			X.append("rect").attr("x", U / -2).attr("y", K / -2).attr("width",
					U).attr("height", K).transition().duration(w).ease(F).attr(
					"x", function(Z) {
						return Z.x
					}).attr("y", function(Z) {
				return Z.y
			});
			X.append("text").attr("font-size", 11) // size of the faculty
													// members
			.attr("x", function(Z) {
				return U / -2 + t
			}).attr("y", function(Z) {
				return K / -2 + o
			}).attr("fill", "#fff").text(function(Z) {
				// Remove / from Text
				var n = Z.name.lastIndexOf('/');
				var PageName = Z.name.substring(n + 1);
				return PageName
				// return Z.name
			}).transition().duration(w).ease(F).attr("x", function(Z) {
				return Z.x + t
			}).attr("y", function(Z) {
				return Z.y + o
			});
			Y.exit().selectAll("rect").transition().duration(w).ease(F).attr(
					"x", function(Z) {
						return U / -2
					}).attr("y", function(Z) {
				return K / -2
			});
			Y.exit().selectAll("text").transition().duration(w).ease(F).attr(
					"x", function(Z) {
						return U / -2 + t
					}).attr("y", function(Z) {
				return K / -2 + o
			});
			Y.exit().transition().duration(w).remove()
		}

		function m(Y) {
			var X = f.selectAll("path").data(Y);
			X.enter().append("path").attr("d", function(Z) {
				return v([ [ Z.x1, Z.y1 ], [ Z.x1, Z.y1 ], [ Z.x1, Z.y1 ] ])
			}).attr("stroke", "#000").attr("stroke-width", 1.5).transition()
					.duration(w).ease(F).attr(
							"d",
							function(Z) {
								return v([ [ Z.x1, Z.y1 ], [ Z.xx, Z.yy ],
										[ Z.x2, Z.y2 ] ])
							});
			X.exit().remove()
		}

		function z() {
			f.selectAll("rect").attr("fill", function(X) {
				return l(X, "#000", N, "#000")
			});
			B
					.selectAll("path")
					.attr("stroke", function(X) {
						return l(X, "#aaa", N, "#aaa")
					})
					.attr("stroke-width", function(X) {
						return l(X, "1.5px", "2.5px", "1px")
					})
					.attr("opacity", function(X) {
						return l(X, 0.4, 0.75, 0.3)
					})
					.sort(
							function(Y, X) {
								if (!k.node) {
									return 0
								}
								var aa = k.map[Y.canonicalKey] ? 1 : 0, Z = k.map[X.canonicalKey] ? 1
										: 0;
								return aa - Z
							});
			E.selectAll("circle").attr("fill", function(X) {
				if (X === L.node) {
					return "#000"
				} else {
					if (X.type === "theme") {
						return l(X, "#666", N, "#000")
					} // else {
					// if (X.type === "perspective") {
					// return "#fff"
					// }
					// }
					// New code

				}
				return l(X, "#000", N, "#999")
			}).attr("stroke", function(X) {
				if (X === L.node) {
					return l(X, null, N, null)
				} else {
					if (X.type === "theme") {
						return "#000"
					} else {
						// if (X.type === "perspective") {
						// return l(X, "#000", N, "#000")
						// }

					}
				}
				return null
			}).attr("stroke-width", function(X) {
				if (X === L.node) {
					return l(X, null, 2.5, null)
				} else {
					// if (X.type === "theme" || X.type === "perspective") {
					// return 1.5
					// }
					if (X.type === "theme") {
						return 1.5
					}
				}
				return null
			});
			E.selectAll("text.label").attr(
					"fill",
					function(X) { // research area words
						return (X === L.node || X.isGroup) ? "#fff" : l(X,
								"#000", N, "#999")
					})
		}

		function p(X) {
			return X.toLowerCase().replace(/[ .,()]/g, "-")
		}

		function u(X) {
			return X.key
		}

		function l(X, aa, Z, Y) {
			if (k.node === null) {
				return aa
			}
			return k.map[X.key] ? Z : aa
		}
	}
};

function closeConceptMap(target) {
    $(target).children(".conceptmap").remove();
    $(target).children(".graph-info").remove();
}
