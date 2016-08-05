/**
 * <pre>
 * loadVisualization([options])
 *   target: a jquery selector
 *     The first HTML element selected will contain the visualization. 
 *         If the viz is modal, the target will be returned to its original content before re-drawing.
 *     Default: create an unnamed, unstyled element and add it to the DOM.
 *   trigger: a jquery selector
 *     Clicking on the first HTML element selected will cause the visualization
 *         to appear.
 *     Required if modal is true.
 *     Default: create the visualization on page load.
 *   modal: true or false
 *     If true, the target will be used as a modal dialog. Close the box by 
 *         pressing escape, clicking the close icon, or clicking the page 
 *         outside the dialog.
 *     If false, the target will remain at its provided DOM location.
 *     Default: false.
 *   url: a url
 *     Where to get the data.
 *     Default: data is an empty string.
 *   parse: “turtle”
 *     If specified, parse the raw data into an RDF graph before passing it to 
 *         the transform function.
 *     Default: the transform function will receive the raw data string.
 *   transform: the name of a function(data), or a function ref.
 *     Massage the data to produce JSON for the display function
 *     Default: pass the data without change.
 *   display: the name of a function(transformed, jqTarget), or a function ref.
 *     Take the transformed data, and produce the visualization in the target 
 *         (a jQuery element).
 *     Default: display the data either as a turtle graph, or as a preformatted
 *         string.
 *   height: the height of the visualization
 *     The height of the target element, when passed to the display function.
 *     May be expressed as integer pixels, or as a fraction of the window
 *         height.
 *     May be overridden in the display funtion.
 *     Required.
 *   width: the width of the visualization
 *     Like height.
 * </pre>
 */

function loadVisualization(o) {

	try {
		setup(new Options(o))
	} catch (e) {
		displayError(e);
		throw e;
	}

	function Options(o) {

		// ----- Constructor -----

		if (!o) {
			o = {};
		}

		var targetElement;
		if (o.target) { // selector
			targetElement = getOneElement(o.target);
		} else { // default
			targetElement = simpleTarget();
		}

		var triggerElement;
		if (o.trigger) { // selector
			triggerElement = getOneElement(o.trigger);
		} else {
			if (o.modal) {
				throw new Error("A modal visualization must have a trigger.");
			} else {
				triggerElement = null;
			}
		}

		var positionerFunction;
		if (o.modal) {
			positionerFunction = modalPositioner;
		} else {
			positionerFunction = noopPositioner;
		}

		var parseFunction;
		if (!o.parse) {
			parseFunction = noopParser;
		} else if (o.parse == 'turtle') {
			parseFunction = turtleParser;
		} else {
			throw new Error("'turtle' is the only available parsing option.");
		}

		var transformFunction = getFunctionReference(o.transform, noopTransform);

		var displayFunction = getFunctionReference(o.display,
				prettyPrintDisplay);

		checkValidDimension(o.height, "height");

		checkValidDimension(o.width, "width");

		// ----- Accessors -----

		this.getTarget = function() {
			return targetElement;
		};

		this.getTrigger = function() {
			return triggerElement;
		};

		this.isModal = function() {
			return o.modal && true;
		}

		this.getUrl = function() {
			return o.url;
		};

		this.getPositioner = function() {
			return positionerFunction;
		}

		this.getParser = function() {
			return parseFunction;
		}

		this.getTransformer = function() {
			return transformFunction;
		}

		this.getDisplayer = function() {
			return displayFunction;
		}

		this.getHeight = function() {
			return o.height;
		}

		this.getWidth = function() {
			return o.width;
		}

		// ----- Helpers -----

		function simpleTarget() {
			$(document.body).append("<div id='visualizationTarget'></div>");
			return getOneElement("#visualizationTarget");
		}

		function getOneElement(selector) {
			var selection = $(selector);
			if (selection.length) {
				return selection[0]
			} else {
				throw new Error("Nothing is selected by '" + selector + "'");
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

		function checkValidDimension(dim, label) {
			if (dim) {
				if (dim <= 1) {
					return;
				} else if (Number.isInteger(dim) && dim >= 100) {
					return;
				}
			}
			throw new Error(label + " must be either a fraction of the window "
					+ label + " or an integer not less than 100.");
		}

		function noopPositioner(target) {
			// nothing to do.
		}

		function modalPositioner(target) {
			var t = $(target)
			t.css('margin-left', 0);
			t.css('left', ($(window).width() - t.width()) / 2);
			t.css('top', ($(window).height() - t.height()) / 2);
			t.fadeIn();
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
	}

	function setup(options) {
		if (options.isModal()) {
			prepareModalTrigger();
		} else if (options.getTrigger()) {
			prepareTrigger();
		} else {
			triggerItNow();
		}

		function prepareModalTrigger() {
			$(options.getTrigger()).addClass("jqModal");
			$(options.getTarget()).addClass("jqmWindow");
			$(options.getTarget()).jqm({
				trigger : options.getTrigger(),
				onShow : showModal
			});
			function showModal(hash) {
				hash.o.prependTo('body');
				fetchTransformAndDisplay();
			}
		}

		function prepareTrigger() {
			$(options.getTrigger()).click(fetchTransformAndDisplay);
		}

		function triggerItNow() {
			fetchTransformAndDisplay();
		}

		function fetchTransformAndDisplay() {
			if (options.getUrl()) {
				$.get(options.getUrl(), transformAndDisplay);
			} else {
				transformAndDisplay("");
			}

			function transformAndDisplay(data) {
				var parsed = options.getParser()(data);
				var transformed = options.getTransformer()(parsed);

				clearAndResize();
				options.getDisplayer()(transformed, options.getTarget());
				options.getPositioner()(options.getTarget());

				function clearAndResize() {
					var target = $(options.getTarget());
					var desiredHeight = desiredDimension(options.getHeight(),
							$(window).height())
					var desiredWidth = desiredDimension(options.getWidth(), $(
							window).width())

					restoreTargetToOriginalContent(target)
					target.height(desiredHeight);
					target.width(desiredWidth);

					function desiredDimension(requestedDim, windowDim) {
						if (!requestedDim) {
							return Math.floor(windowDim * 0.5);
						} else if (requestedDim > 1) {
							return Math.floor(requestedDim);
						} else {
							return Math.floor(windowDim * requestedDim);
						}
					}
					
					function restoreTargetToOriginalContent(target) {
					  if (options["originalTargetContent"]) {
					    target.html(options["originalTargetContent"]);
					  } else {
					    options["originalTargetContent"] = target.html();
					  }
					}
				}
			}
		}
	}

	function displayError(e) {
		$("#wrapper-content").html(
				"<h1>Javascript error</h1><div>" + e + "<br/><pre>" + e.stack
						+ "</pre></div>");
	}
}
