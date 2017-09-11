/**
 * <pre>
 * 
 * -----------------------------------------------------------------------------
 * Customary options:
 * -----------------------------------------------------------------------------
 * 
 * target: 
 *   A JQuery selector for the div that will hold the visualization. In the case 
 *   of a modal visualization, this is the div that will appear/disappear. 
 *   
 *   The div may contain a div#info_icon_text that will be used as the 
 *   contents of the info icon in the toolbar.
 *   
 *   The div may contain one or more div[data-view-id] to provide views of the
 *   visualization data.
 *   
 *   The div may contain one or more elements [data-export-id] that will trigger
 *   a matching methods from the 'export' option (below) when clicked. If the
 *   element is located within a view, it will trigger the matching method
 *   for that view.
 *   
 *   Required.
 *   
 * modal:
 *   If set to true, the target is treated as a modal dialog box. The HTML/CSS
 *   should render the target initially invisible.
 *   
 *   Default is false.
 * 
 * url:
 *   When using the default fetcher, this URL is the source of the data for the
 *   visualization. If this is omitted, the data will be an empty string.
 *   
 * parse:
 *   If specified, the only accepable value is "turtle". This assume that the 
 *   raw data is RDF in turtle format, and parses it into a graph before 
 *   passing it to the transform function.
 *   
 *   By default, the data is not parsed.
 * 
 * transform:
 *   Optional. A function that massages the (parsed) data that was fetched from
 *   the server. The default transformer passes the fetched data without change. 
 *   
 *   Accepts: the parsed data, 
 *            the options structure
 *   
 *   Returns: the transformed data
 *
 * display:
 *   Optional. A function that uses the transformed data to construct the 
 *   visualization. The visualization should be created within the target
 *   element (specified above). The default display does a pretty-print of the
 *   data.
 *   
 *   If views are specified, the main display method is called before the 
 *   view display method.
 *   
 *   Accepts: the transformed data, 
 *            the target element, 
 *            the options structure
 *   
 *   Returns: nothing
 *   
 * closer:
 *   Optional. A function that removes the visualization from the target. Its
 *   purpose is to ensure that each successive call to display the function
 *   begins with a "clean" target. 
 *   
 *   Extra calls to the closer should not cause a problem. The default closer 
 *   does nothing.
 *   
 *   If views are specified, the main closer method is called after the view 
 *   closer method.
 *   
 *   Accepts: the target element
 *   
 *   Returns: nothing
 * 
 * export:
 *   Optional. A map of ids to export functions. If a [data-export-id] element
 *   is clicked, the function that is mapped to that id will be invoked.
 *   
 *   Each function accepts: the trigger element,
 *                          the transformed data,
 *                          the options structure
 *                          
 *   Each function returns: nothing
 *   
 * -----------------------------------------------------------------------------
 * View options:
 * -----------------------------------------------------------------------------
 * 
 * views:
 *   A structure of options that will be used in constructing multiple views of
 *   the data. If views are specified, one view is visible whenever the 
 *   visualizataion as a whole is visible. If more than one view is specified,
 *   a selector will be created in the toolbar, so the desired view can be 
 *   selected.
 *   
 * Example of the views structure:
 * 
 * views : {
 *    vis : { 
 *      display : vis_display_function,
 *      closer : vis_closer_function
 *      export : {
 *        json: exportVisAsJson
 *      }
 *    } ,
 *    table : { 
 *      display : table_display_function,
 *      closer : table_closer_function
 *      export : {
 *        cvs: exportTableAsCvs,
 *        json: exportTableAsJson
 *      }
 *    }
 * }
 * 
 * Each key in the view structure should correspond to the data-view-id 
 * attribute of a div in the target. That div should also have a data-view-label
 * attribute, for use in the view selector in the toolbar.
 * 
 * Each view uses the same data, which has been fetched, parsed, and 
 * transformed as described above. The target for the view is the div with the
 * matching data-view-id.
 * 
 * display, closer, and export options are as described above.
 * 
 * -----------------------------------------------------------------------------
 * Less common options:
 * -----------------------------------------------------------------------------
 * 
 * fetch: 
 *   Optional. A function that fetches data from the server, replacing the 
 *   default fetcher. 
 * 
 *   Accepts: the options structure
 *   
 *   Returns: a jQuery Promise object which will fetch the data and store it in
 *            options.fetched
 * 
 * showProgress:
 *   Optional. A function that displays some indication that data is being 
 *   fetched from the server.
 *   
 *   The default function just makes visible a "#time-indicator" element in the 
 *   target.
 *   
 *   Accepts: the target element, 
 *            the options structure
 *   
 *   Returns: nothing
 *   
 * hideProgress:
 *   Optional. A function that removes the indication that data is being fetched 
 *   from the server.
 *   
 *   The default function just makes invisible a "#time-indicator" element in 
 *   the target.
 *   
 *   Accepts: the target element, the options structure
 *   
 *   Returns: nothing
 *   
 * -----------------------------------------------------------------------------
 * Notes:
 * -----------------------------------------------------------------------------
 * 
 * When an option value is described as "a function", it may either be an actual
 * function reference, or a string that names a function reference, to be
 * resolved at runtime.
 * 
 * </pre>
 */
var ScholarsVis2 = (function() {
    return {
        Visualization: Visualization
    };
    
    function debugIt(message) {
        if (true) {
            var now = new Date();
            var time = now.toLocaleTimeString();
            var millis = ("000" + now.getMilliseconds().toString()).slice(-3);
            console.log(time + "." + millis + " ScholarsVis2  " + message);
        }
    }
    
    function handleError(e) {
        $("#wrapper-content").html(
                "<h1>Javascript error</h1><div>" + e + "<br/><pre>" + e.stack
                + "</pre></div>");
        throw e;
    }
    
    function stringifyReplacer(key, value) {
        if (typeof value === "function") {
            return "function()";
        } else if (value instanceof HTMLElement) {
            var html = $(value).html();
            if (html.length <= 50) {
                return html;
            } else {
                return html.substring(0, 47) + "...";
            }
        } else {
            return value;
        }
    }
    
    function Visualization(opts, defaults) {
        debugIt("create Visualization");
        try {
            if (defaults) {
                var options = new Options($.extend(defaults, opts)); 
            } else {
                var options = new Options(opts); 
            }
            debugIt("Options: " + JSON.stringify(options, stringifyReplacer, 2));
            
            var toolbar = new Toolbar(options.target);
        } catch (e) {
            handleError(e);
        }
        
        return {
            examineData: examineData,
            show: show, 
            hide: hide
        };
        
        function examineData(examiner) {
            debugIt("Vis:examineData");
            options.examiner = examiner;
            fetchAndProcess().then(examine);
            
            function examine() {
                return defer("examining", function() {
                    options.checkResult = options.examiner(options.transformed, options);
                });
            }
        }
        
        function show(e) {
            e && e.preventDefault();
            if (options.modal) {
                debugIt("Vis:showModal");
                displayProgress().then(fetchAndProcess).then(positionModal).then(hideProgress).then(displayMain).then(makeModal);
            } else {
                debugIt("Vis:show");
                displayProgress().then(fetchAndProcess).then(hideProgress).then(displayMain).then(makeVisible);
            }
            showView();
            
            function displayProgress() {
                return defer("displayingProgressIndicator", function() {
                    options.showProgress(options.target, options);
                });
            }
            
            function hideProgress() {
                return defer("hidingProgressIndicator", function() {
                    options.hideProgress(options.target, options);
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
            
            function displayMain() {
                return defer("displaying main", function() {
                    var copyOfTransformed = JSON.parse(JSON.stringify(options.transformed));
                    options.displayer(copyOfTransformed, options.target, options)
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
            
            function makeVisible() {
                return defer("makeVisible", function() {
                    $(options.target).show();
                });
            }
        }
        
        function hide() {
            e && e.preventDefault();
            if (options.modal) {
                debugIt("Vis:hide");
                $.when(releaseModal());
            } else {
                $.when(clearCanvas());
            }
            
            function releaseModal() {
                return defer("releaseModal", function() {
                    $(options.target).jqmHide(); 
                });
            }
            
            function clearCanvas() {
                return defer("clearCanvas", function() {
                    options.closer(options.target);
                });
            }
        }
        
        function showView(e) {
            var id = e ? $(this).val() : " ";
            debugIt("View: " + id);

            if (options.viewsArray.length == 0) {
                debugIt("No views to display");
                return "";
            }
            
            options.viewsArray.forEach(closeView);
            
            function closeView(view) {
                debugIt("Closing view " + view.id);
                view.closer(view.target);
                $(view.target).hide()
            }
             
            debugIt("View ID: " + id);
            var view = options.viewsArray[0];
            options.viewsArray.forEach(v => {if (v.id == id) {view = v}});
            $(view.target).show();
            
            return defer("displaying view", function() {
                var copyOfTransformed = JSON.parse(JSON.stringify(options.transformed));
                view.displayer(copyOfTransformed, view.target, options)
            });
        }
        
        function fetchAndProcess() {
            return fetch().then(parse).then(transform);
            
            function fetch() {
                if (typeof options.fetched === "undefined") {
                    debugIt("set up fetching");
                    return options.fetcher(options);
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
                        options.transformed = options.transformer(options.parsed, options);
                    });
                } else {
                    return alreadyDone("transforming");
                }
            }
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
        
        //----------------------------------------------------------------------
        // Options class
        //
        // Preprocess all of the options, finding appropriate values, assigning
        // defaults as needed, throwing an error on an invalid value.
        //
        //----------------------------------------------------------------------
        
        function Options(o) {
            o = o || {};
            
            var target = getOneElement(o.target);
            var viewOptions = new ViewOptions(o.views, target);
            var defaultDisplayer = (Object.keys(viewOptions).length > 0) ?
                    noopDisplay : prettyPrintDisplay;
            
            return $.extend({}, o, {
                target: target,
                fetcher: getFunctionReference("fetch", defaultFetcher),
                parser: figureParseFunction(o.parse), 
                transformer: getFunctionReference("transform", noopTransform),
                showProgress: getFunctionReference("showProgress", defaultShowProgress), 
                hideProgress: getFunctionReference("hideProgress", defaultHideProgress), 
                displayer: getFunctionReference("display", defaultDisplayer), 
                closer: getFunctionReference("closer", noopCloser),
                viewsArray: viewOptions.array
            });
            
            function getOneElement(selector) {
                var selection = $(selector);
                if (selection.length) {
                    return selection[0]
                } else {
                    throw new Error("Nothing is selected by '" + selector + "'");
                }
            }
            
            function figureParseFunction(parse) {
                if (typeof parse === "undefined") {
                    return noopParser;
                } else if (parse == 'turtle') {
                    return turtleParser;
                } else {
                    throw new Error("'turtle' is the only available parsing option.");
                }
            }
            
            function getFunctionReference(name, defaultFunction) {
                var provided = o[name];
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
                            "If provided, 'options." + name + "' must be a function name or a function reference.");
                }
            }
            
            function defaultFetcher(options) {
                return $.get(options.url).then(storeFetchedData);
                
                function storeFetchedData(fetched) {
                    options.fetched = fetched;
                    debugIt("fetched");
                }
            }
            
            function defaultShowProgress(target) {
                $(target).find("#time-indicator").show();
            }
            
            function defaultHideProgress(target) {
                $(target).find("#time-indicator").hide();
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
            
            function noopDisplay(data, target) {
                // Do nothing
                debugIt("noopDisplay");
            }
            
            function prettyPrintDisplay(data, target) {
                debugIt("prettyPrintDisplay");
                var h = Math.floor($(window).height() * 0.8);
                var textArea = document.createElement("div")
                $(textArea).addClass("prettyPrint").css({
                    "overflow" : "auto",
                    "height" : h,
                    "font-family" : "monospace",
                    "line-height" : "normal",
                    "margin" : "1em"
                })
                $(textArea).append("<div>The transformed data</div>").append(
                        "<pre>" + JSON.stringify(data, null, 2) + "</pre>");
                $(target).append(textArea);
            }
            
            function noopCloser(target) {
                $(target).remove(".prettyPrint");
                debugIt("NOOP Closer");
            }
            
            //----------------------------------------------------------------------
            // ViewOptions class
            //
            // Each view must have a target, a display method, a closer, and an 
            // export structure.
            //
            //----------------------------------------------------------------------
            
            function ViewOptions(v, t) {
                v = v || {};
                return {
                    array : $.map($(t).find("[data-view-id]"), buildView)
                }

                function buildView(element) {
                    var id = $(element).data("view-id");
                    return {
                        id : id,
                        target : element,
                        displayer : v[id].display || prettyPrintDisplay,
                        closer : v[id].closer || noopCloser,
                        export : v[id].export || {}
                    }
                }
            }
        }
        
        //----------------------------------------------------------------------
        // Toolbar class
        //
        // Doesn't need to be a class, as it stands now, because the constructor
        // does all the work and returns no functionalit.
        //
        // So currently, it's just a way to organize this logic.
        //
        //----------------------------------------------------------------------
        
        function Toolbar(target) {
            var toolbar = $(target).find(".vis_toolbar");
            buildInfoIcon();
            addViewOptions();
            return {};
            
            function buildInfoIcon() {
                var tipText = $(target).find("#info_icon_text").html();
                var tipOptions = {
                        title: tipText,
                        html: true,
                        placement: "bottom",
                        viewport: target
                };
                var tooltip = $("<span></span>").addClass("glyphicon glyphicon-info-sign pull-right").tooltip(tipOptions);
                toolbar.append(tooltip);
            }
            
            function addViewOptions() {
                var selector = $(target).find("#vis_toolbar_select");
                $(target).find("[data-view-id]").each(addOption);
                $(selector).change(showView);
                
                function addOption(i, viewTarget) {
                    var id = $(viewTarget).data("view-id");
                    var label = $(viewTarget).data("view-label");
                    selector.append($("<option></option").attr("value", id).text(label));
                }
            }
        }
    }

})();
