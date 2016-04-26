function popupRdf(options) {
	try {
		options = populateOptions(options)
		setup(options)
	} catch (e) {
		displayError(e);
		throw e;
	}

	function populateOptions(options) {
		if (!options) {
			options = {};
		}
		if (!options.trigger) {
			throw new Error("trigger option is required.")
		}
		if (!options.target) {
			options.target = simpleTarget();
		}
		if (!options.url) {
			// compensate for this later.
		}
		if (!options.transform) {
			options.transform = noopTransform;
		}
		if (!options.display) {
			options.display = prettyPrintDisplay;
		}
		if (!options.width) {
			options.width = Math.floor($(window).width() * 0.6)
		}
		if (!options.height) {
			options.height = Math.floor($(window).height() * 0.6)
		}

		options.triggerElement = getOneElement(options.trigger)
		options.targetElement = getOneElement(options.target)

		return options;

		function simpleTarget() {
			$(document.body).append("<div id='popupRdfTarget'></div>");
			return "#popupRdfTarget";
		}

		function getOneElement(selector) {
			var selection = $(selector);
			if (selection.length) {
				return selection[0]
			} else {
				throw new Error("Nothing is selected by '" + selector + "'");
			}
		}

		function noopTransform(graph) {
			return graph.statements;
		}

		function prettyPrintDisplay(transformed, target, width, height) {
			$(target).append("<div>The transformed data</div>").append(
					"<div><pre>" + JSON.stringify(transformed, null, 2)
							+ "</pre></div>");
		}
	}

	function setup(options) {
		$(options.triggerElement).addClass("jqModal");
		$(options.targetElement).addClass("jqmWindow");
		$(options.targetElement).jqm({
			trigger : options.trigger,
			onShow : (options.url ? withFetch : withoutFetch)
		});

		function withFetch(hash) {
			$.get(options.url, function(turtle) {
				showIt(hash, turtle)
			})
		}

		function withoutFetch(hash) {
			showIt(hash, '')
		}

		function showIt(hash, turtle) {
			var graph = parseTurtle(turtle)
			var transformed = options.transform(graph);

			hash.o.prependTo('body');
			
			hash.w.empty()
			hash.w.width(options.width)
			hash.w.height(options.height)

			options.display(transformed, options.target, options.width, options.height);
			
			hash.w.css('margin-left', -(hash.w.width / 2))
			hash.w.fadeIn();
		}

		function parseTurtle(turtle) {
			var graph = $rdf.graph();
			$rdf.parse(turtle, graph, "http://graph.name", "text/turtle");
			return graph;
		}
	}

	function displayError(e) {
		$("#wrapper-content").html(
				"<h1>Javascript error</h1><div>" + e + "<br/><pre>" + e.stack
						+ "</pre></div>");
	}
}