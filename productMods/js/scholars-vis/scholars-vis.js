/**
 * <pre>
 * ScholarsVis
 * 
 * Contains a single constructor function, named Visualization. Calling 
 * 'new Visualizatio(options)' will return an object with these functions:
 * -- create and show the visualization (optionally, in a modal dialog box).
 * -- hide the visialization (if modal, close the dialog box).
 * -- open a new window for downloading the data that backs the visualization.
 * 
 * Behind these functions are those that fetch, parse, and transform the data.
 * Each of these is executed lazily, and only once.
 * 
 * The Visualization assumes:
 * -- JQuery is already loaded.
 * -- a variable named 'applicationContextPath' is set, e.g. to '/scholars' 
 *      or '/'
 * 
 * The options object allows these specifiers:
 *   target: a jquery selector
 *     The first HTML element selected will be passed to the display function
 *       as the target element. 
 *     Default: create an unnamed, unstyled element add it to the DOM, and use 
 *     that.
 *   url: a url
 *     Where to get the data.
 *     Default: data is an empty string.
 *   parse: “turtle”
 *     If specified, assume that the raw data is RDF in turtle format, and parse
 *       it into a graph before passing it to the transform function.
 *     Default: the transform function will receive the raw data string.
 *   transform: the name of a function(data), or a function ref.
 *     Massage the data to produce JSON for the display function
 *     Default: pass the data without change.
 *   display: the name of a function(transformed, jqTarget), or a function ref.
 *     Take the transformed data, and produce the visualization in the target 
 *         (a jQuery element).
 *     Default: display the data either as a turtle graph, or as a formatted
 *         string.
 *   modal: true or false
 *     If true, the target will be displayed as a modal dialog box.
 *     Default: false
 * </pre>
 */

var ScholarsVis = (function() {
	return {Visualization: Visualization};
	
	function debugIt(message) {
		if (false) {
			var now = new Date();
			var time = now.toLocaleFormat("%H:%M:%S");
			var millis = now.getMilliseconds().toString().padStart(3, "0");
			console.log(time + "." + millis + "  " + message);
		}
	}
	
	function handleError(e) {
		$("#wrapper-content").html(
				"<h1>Javascript error</h1><div>" + e + "<br/><pre>" + e.stack
				+ "</pre></div>");
		throw e;
	}
	
	function Visualization(opts, defaults) {
		debugIt("create Visualization");
		try {
			if (defaults) {
				var options = new Options($.extend(defaults, opts)); 
			} else {
				var options = new Options(opts); 
			}
		} catch (e) {
			handleError(e);
		}
		
		return {show: show, hide: hide, downloadData, downloadData};
		
		function show(e) {
			if (options.modal) {
				debugIt("Vis:showModal");
				fetch().then(parse).then(transform).then(positionModal).then(display).then(makeModal);
				e.preventDefault();
			} else {
				debugIt("Vis:show");
				fetch().then(parse).then(transform).then(display).then(makeVisible);
				e.preventDefault();
			}
		}
		
		function hide() {
			if (options.modal) {
				debugIt("Vis:hide");
				$.when(releaseModal());
			} else {
				$.when(makeInvisible());
			}
		}
		
		function downloadData() {
			debugIt("Vis:downloadData");
			fetch().then(parse).then(transform).then(exportPrep).then(download);
		}
		
		function fetch(nextFunction) {
			if (typeof options.fetched === "undefined") {
				debugIt("set up fetching");
				return $.get(options.url).then(function(fetched) {
					options.fetched = fetched;
					debugIt("fetched");
				});
			} else {
				return alreadyDone("fetching");
			}
		}
		
		function parse() {
			if (typeof options.parsed === "undefined") {
				return defer("parsing", function() {
					options.parsed = options.parser(options.fetched);
				});
			} else {
				return alreadyDone("parsing");
			}
		}
		
		function transform() {
			if (typeof options.transformed === "undefined") {
				return defer("transforming", function() {
					options.transformed = options.transformer(options.parsed);
				});
			} else {
				return alreadyDone("transforming");
			}
		}
		
		function display() {
			return defer("displaying", function() {
				var copyOfTransformed = JSON.parse(JSON.stringify(options.transformed));
				options.displayer(copyOfTransformed, options.target)
			});
		}
		
		function makeVisible() {
			return defer("makeVisible", function() {
				$(options.target).show();
			});
		}
		
		function makeInvisible() {
			return defer("makeVisible", function() {
				$(options.target).hide();
				options.closer(options.target);
			});
		}
		
		function positionModal() {
			return defer("positionModal", function() {
				$(options.target).addClass("jqmWindow");
				$(options.target).css('margin-left', 0);
				$(options.target).css('left', ($(window).width() - $(options.target).outerWidth()) / 2);
				$(options.target).css('top', ($(window).height() - $(options.target).outerHeight()) / 2);
			});
		}
		
		function makeModal() {
			return defer("makeModal", function() {
				$(options.target).jqm({
				  onShow : showModal,
				  onHide : hideModal,
				}); 
				$(options.target).jqmShow();
				
				function showModal(hash) {
					hash.o.prependTo('body');
					hash.w.fadeIn();
				}
				function hideModal(hash) {
					hash.w.hide(); 
					hash.o && hash.o.remove();
					options.closer(options.target);
				}
			});
		}
		
		function releaseModal() {
			return defer("releaseModal", function() {
				$(options.target).jqmHide(); 
			});
		}
		
		function exportPrep() {
			return alreadyDone("BOGUS exportPrep");
		}
		
		function download() {
			return alreadyDone("BOGUS download");
		}
		
		function alreadyDone(label) {
			return $.when(debugIt(label + " is already done."));
		}
		
		function defer(label, task) {
			debugIt("set up " + label);
			return $.when().then(function() {
				debugIt(label);
				task();
			});
		}
		
	}
	
	function Options(o) {
		o = o || {};
		
		return {
			url: o.url, 
			target: getOneElement(o.target), 
			parser: figureParseFunction(o), 
			transformer: getFunctionReference(o.transform, noopTransform), 
			displayer: getFunctionReference(o.display, prettyPrintDisplay), 
			closer: getFunctionReference(o.closer, noopCloser),
			modal: o.modal,
			exporter: getFunctionReference(o.exporter, noopExporter)
		}
		
		function getOneElement(selector) {
			var selection = $(selector);
			if (selection.length) {
				return selection[0]
			} else {
				throw new Error("Nothing is selected by '" + selector + "'");
			}
		}
		
		function figureParseFunction(o) {
			if (typeof o.parse === "undefined") {
				return noopParser;
			} else if (o.parse == 'turtle') {
				return turtleParser;
			} else {
				throw new Error("'turtle' is the only available parsing option.");
			}
		}
		
		function getFunctionReference(provided, defaultFunction) {
			if (!provided) {
				return defaultFunction;
			} else if (typeof provided == 'function') {
				return provided;
			} else if (typeof provided == 'string') {
				var func = window[provided];
				if (typeof func == 'function') {
					return func;
				} else {
					throw new Error("Can't locate function '" + provided + "'.");
				}
			} else {
				throw new Error(
				"If provided, 'transform' must be a function name or a function reference.");
			}
		}
		
		function noopParser(data) {
			return data;
		}
		
		function turtleParser(data) {
			var graph = $rdf.graph();
			$rdf.parse(data, graph, "http://graph.name", "text/turtle");
			return graph;
		}
		
		function noopTransform(data) {
			return data;
		}
		
		function prettyPrintDisplay(data, target) {
			var h = Math.floor($(window).height() * 0.8);
			var textArea = document.createElement("div")
			$(textArea).css({
				"overflow" : "auto",
				"height" : h,
				"font-family" : "monospace",
				"line-height" : "normal",
				"margin" : "1em"
			})
			$(textArea).append(
					"<pre>" + JSON.stringify(data, null, 2) + "</pre>")
					$(target).append("<div>The transformed data</div>")
					.append(textArea);
		}
		
		function noopCloser(target) {
			// nothing to do.
			debugIt("NOOP Closer");
		}
		
		function noopExporter(data) {
			return data;
		}
	}
})();
