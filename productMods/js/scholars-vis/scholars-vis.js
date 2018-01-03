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
 *   The div may contain a div#title_bar_info_text that will be used as the 
 *   contents of the info icon in the title bar.
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
 *   a selector will be created in the title bar, so the desired view can be 
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
 * attribute of a div in the target.
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
 *   Returns: a jQuery Deferred object which will fetch the data and store it 
 *            in options.fetched
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
var ScholarsVis = (function() {
    var utilities = new Utilities();
    utilities.loadScripts(
            utilities.baseUrl + "js/scholars-vis/stupidtable.min.js",
            utilities.baseUrl + "js/scholars-vis/rdflib.js", 
            utilities.baseUrl + "js/scholars-vis/FileSaver.js",
            utilities.baseUrl + "js/scholars-vis/jqModal.js"
            );
    utilities.loadStyles(
            utilities.baseUrl + "css/scholars-vis/jqModal.css",
            utilities.baseUrl + "css/scholars-vis/scholars-vis.css"
            );

    return {
        Visualization: Visualization,
        VisTable: VisTable,
        Utilities: utilities
    };
    
    function debugIt(message) {
        if (false) {
            var now = new Date();
            var time = now.toLocaleTimeString();
            var millis = ("000" + now.getMilliseconds().toString()).slice(-3);
            console.log(time + "." + millis + " ScholarsVis  " + message);
        }
    }
    
    function handleError(e) {
        $("#wrapper-content").html(
                "<h1>Javascript error</h1><div>" + e + "<br/><pre>" + e.stack
                + "</pre></div>");
        throw e;
    }
    
    /*
     * -------------------------------------------------------------------------
     * Visualization
     * -------------------------------------------------------------------------
     */
    
    function Visualization(opts, defaults) {
        debugIt("create Visualization");
        try {
            if (defaults) {
                var options = new Options($.extend(defaults, opts)); 
            } else {
                var options = new Options(opts); 
            }
            debugIt("Options: " + ScholarsVis.Utilities.stringify(options));
            
            var titleBar = new TitleBar(options.target);
            
            linkViewButtons(options.target);
            linkExportButtons(options.target);
        } catch (e) {
            handleError(e);
        }
        
        return {
            examineData: examineData,
            show: show, 
            showView: showView,
            hide: hide
        };
        
        function linkViewButtons(target) {
            $(target).find("[data-view-selector]").off("click.ScholarsVis");
            $(target).find("[data-view-selector]").on("click.ScholarsVis", serviceViewButton);
        }
        
        function serviceViewButton(e) {
            e && e.preventDefault();
            
            var viewId = $(e.target).data("view-selector");
            debugIt("Servicing: view=" + viewId);
            showView(viewId);
        }
        
        function linkExportButtons(target) {
            $(target).find("[data-export-id]").off("click.ScholarsVis");
            $(target).find("[data-export-id]").on("click.ScholarsVis", serviceExportButton);
        }
        
        function serviceExportButton(e) {
            e && e.preventDefault();
            
            var viewId = $(e.target).closest("[data-view-id]").data("view-id");
            var exportId = $(e.target).data("export-id");
            doExport(locateExportParms());
            
            function locateExportParms() {
                if (viewId) {
                    var viewStruct = options.viewsArray.find(v => { return v.id == viewId; });
                    return (viewStruct && viewStruct.export) ? viewStruct.export[exportId] : null;
                } else {
                    return (options.export) ? options.export[exportId] : null; 
                }
            }
            
            function doExport(exportParms) {
                if (exportParms) {
                    var callback = exportParms.call;
                    var filename = exportParms.filename;
                    if (!callback) {
                        debugIt("Servicing: No callback for export=" + exportId + ", view=" + viewId);
                    } else if (!filename) {
                        debugIt("Servicing: No filename for export=" + exportId + ", view=" + viewId);
                    } else {
                        debugIt("Servicing: export=" + exportId + ", view=" + viewId);
                        callback(options.transformed, filename, options);
                    }
                } else {
                    debugIt("Servicing: No export parameters for export=" + exportId + ", view=" + viewId);
                }
            }
        }
        
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
                displayProgress().then(fetchAndProcess).then(positionModal).then(displayMain).then(makeModal).then(showView).then(hideProgress);
            } else {
                debugIt("Vis:show");
                displayProgress().then(fetchAndProcess).then(displayMain).then(makeVisible).then(showView).then(hideProgress);
            }
            
            
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
                    var copyOfTransformed = JSON.parse(JSON.stringify(options.transformed || {}));
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
                        hideViews();
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
        
        function hide(e) {
            e && e.preventDefault();
            hideViews();
            if (options.modal) {
                debugIt("Vis:hide");
                $.when(releaseModal());
            } else {
                $.when(clearCanvas());
            }
            
            function releaseModal() {
                return defer("releaseModal", function() {
                    hideViews();
                    options.closer(options.target);
                    $(options.target).jqmHide(); 
                });
            }
            
            function clearCanvas() {
                return defer("clearCanvas", function() {
                    hideViews();
                    options.closer(options.target);
                });
            }
        }
        
        function showView(viewId) {
            debugIt("View ID: " + viewId);
            if (options.viewsArray.length == 0) {
                debugIt("No views to display");
                return "";
            }

            var view = chooseView();
            debugIt("View is: " + view.id);
            
            adjustViewButtons();
            hideViews();

            $(view.target).show();
            
            return defer("displaying view", function() {
                var copyOfTransformed = JSON.parse(JSON.stringify(options.transformed));
                view.displayer(copyOfTransformed, view.target, options)
            });
            
            function chooseView() {
                viewId = viewId || " ";
                for (var i = 0; i < options.viewsArray.length; i++) {
                    if (options.viewsArray[i].id == viewId) {
                        return options.viewsArray[i];
                    }
                }
                return options.viewsArray[0];
            }
            
            function adjustViewButtons() {
                if (view.id == "empty") {
                    $(options.target).find('[data-view-selector]').hide();
                } else {
                    $(options.target).find('[data-view-selector]').show();
                    $(options.target).find('[data-view-selector=' + view.id + ']').hide();
                }
            }
        }
        
        function hideViews() {
            options.viewsArray.forEach(closeView);
            
            function closeView(view) {
                debugIt("closing view: " + view.id);
                view.closer(view.target);
                $(view.target).hide()
            }
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
        
        // ----------------------------------------------------------------------
        // Options class
        //
        // Preprocess all of the options, finding appropriate values, assigning
        // defaults as needed, throwing an error on an invalid value.
        //
        // ----------------------------------------------------------------------
        
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
            
            // ----------------------------------------------------------------------
            // ViewOptions class
            //
            // Each view must have a target, a display method, a closer, and an
            // export structure.
            //
            // ----------------------------------------------------------------------
            
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
        
        // ----------------------------------------------------------------------
        // TitleBar class
        //
        // Doesn't need to be a class, as it stands now, because the constructor
        // does all the work and returns no functionality.
        //
        // So currently, it's just a way to organize this logic.
        //
        // ----------------------------------------------------------------------
        
        function TitleBar(target) {
            buildInfoIcon();
            return {};
            
            function buildInfoIcon() {
                var tipText = $(target).find("#title_bar_info_text").html();
                var tipOptions = {
                        title: tipText,
                        html: true,
                        placement: "bottom",
                        viewport: target
                };
                var tooltip = $(target).find("#title_bar .glyphicon-info-sign").tooltip(tipOptions);
            }
        }
    }

    /*
     * -------------------------------------------------------------------------
     * VisTable
     * 
     * The first row of the table (other than the header) will be hidden and
     * used as a template for the actual rows of data.
     * 
     * -------------------------------------------------------------------------
     */

    function VisTable(tableElement) {
        if (ScholarsVis.Utilities.isVisTable(tableElement)) {
            ScholarsVis.Utilities.disableVisTable(tableElement);
        }
        
        var rowsToAdd = [];

        var table = $(tableElement);

        var template = table.find("tr:has(td):eq(0)").detach();
        template.find("td").text("");
        
        table.find("tr:has(td)").remove();

        return {
            addRow: addRow,
            complete: complete
        }
        
        function addRow(...values) {
            var row = template.clone();
            row.find("td").each(fillCell);
            rowsToAdd.push(row);
            
            function fillCell(index, cell) {
                $(cell).html(index < values.length ? values[index] : " ");
            }
        }
        
        function complete() {
            table.append(rowsToAdd);
            rowsToAdd = [];

            table.stupidtable();
            table.on("aftertablesort", showSortDirection); 
            table.on("aftertablesort", highlightRows); 
            table.on("aftertablesort", highlightCells); 
            table.data("is-vis-table", "true");
            table.find("thead th").eq(0).stupidsort("asc");
            
            function showSortDirection (event, data) {
                var th = $(this).find("th");
                th.find(".arrow").remove();
                var arrow = data.direction === "asc" ? "<i class='fa fa-arrow-up' aria-hidden='true'></i>" : "<i class='fa fa-arrow-down' aria-hidden='true'></i>";
                th.eq(data.column).append('<span class="arrow">' + arrow +'</span>');
            }
            
            function highlightRows(event, data) {
                var previousValue = "";
                var odd = false;
                
                table.find("tbody tr").each(setRowClasses);
                
                function setRowClasses(index, rowElement) {
                    var row = $(rowElement);
                    var value = row.find("td").eq(data.column).text();

                    row.removeClass("first-row not-first-row odd-row even-row");
                    if (value != previousValue) {
                        previousValue = value;
                        odd = !odd;
                        row.addClass("first-row");
                    } else {
                        row.addClass("not-first-row");
                    }
                    row.addClass(odd ? "odd-row" : "even-row");
                }
            }
            
            function highlightCells(event, data) {
                table.find("tbody tr td").removeClass("sorted-cell").addClass("unsorted-cell");
                table.find("tbody tr td:nth-of-type(" + (data.column + 1) +")").removeClass("unsorted-cell").addClass("sorted-cell");
            }
        }
    }

    /*
     * -------------------------------------------------------------------------
     * Utilities
     * -------------------------------------------------------------------------
     */
    
    function Utilities() {
        return {
            baseUrl: figureBaseUrl(),
            toDisplayUrl: toDisplayUrl,
            loadScripts: loadScripts,
            loadStyles: loadStyles,
            exportAsJson: exportAsJson,
            exportAsCsv: exportAsCsv,
            exportAsSvg: exportAsSvg,
            isVisTable: isVisTable,
            disableVisTable: disableVisTable,
            stringify: stringify
        }
        
        function figureBaseUrl() {
            var rawSrc = $('script[src*="/scholars-vis.js"]').attr('src');
            var questionHere = rawSrc.indexOf('?');
            if (questionHere > 0) {
                rawSrc = rawSrc.slice(0, questionHere);
            }
            var baseUrl = rawSrc.slice(0, - "js/scholars-vis/scholars-vis.js".length);
            if (baseUrl.length == 0) {
                baseUrl = '/';
            }
            return baseUrl;
        }
        
        function toDisplayUrl(uri) {
            // How do you test links to profile pages on a server other than the
            // one in the default namespace? Use displayPage URLs instead of
            // URIs for links.
            var delimiterHere = Math.max(uri.lastIndexOf('/'), uri.lastIndexOf('#'));
            var localname = uri.substring(delimiterHere + 1);
            return ScholarsVis.Utilities.baseUrl + "display/" + localname;
        }
        
        function loadScripts(scriptPaths) {
            var paths = [...arguments]
            if (paths.length == 0) {
                return;
            }
            
            $.holdReady(true);
            $.ajax({ 
                url: paths[0], 
                dataType: "script",
                cache: true
                    }).done(doTheNext).fail(reportFailure).always(release);
            
            function doTheNext() {
                debugIt("Loaded " + paths[0])
                loadScripts(...paths.slice(1));
            }
            
            function reportFailure(jqXHR, textStatus, errorThrown) {
                debugIt("Failed to load " + paths[0] + "; reason is " + textStatus + " -- " + errorThrown);
            }
            
            function release() {
                $.holdReady(false);
            }
        }
        
        function loadStyles(stylePaths) {
            [...arguments].forEach(createLink);
            
            function createLink(path) {
                $('<link/>', {
                    rel: 'stylesheet',
                    type: 'text/css',
                    href: path
                 }).prependTo('head');
                debugIt("Loaded " + path);
            }
        }
        
        function exportAsJson(filename, data) {
            exportToFile(filename, JSON.stringify(data, null, 2), "application/json;charset=utf-8");
        }
        
        function exportAsCsv(filename, data) {
            exportToFile(filename, d3.csv.format(data), "text/csv;charset=utf-8");
        }
        
        function exportAsSvg(filename, svgElement) {
            var xml = (new XMLSerializer()).serializeToString(svgElement);
            exportToFile(filename, xml, "image/svg+xml;charset=utf-8")
        }
        
        function exportToFile(filename, formatted, type) {
            saveAs(new Blob([formatted], {type: type}), filename);
        }
        
        function isVisTable(tableElement) {
            return (typeof $(tableElement).data("is-vis-table") !== "undefined");
        }

        function disableVisTable(tableElement) {
            if (isVisTable(tableElement)) {
                $(tableElement).removeData("is-vis-table");
                $(tableElement).removeAttr("data-is-vis-table");
                $(tableElement).removeData("sortFns");
                $(tableElement).removeAttr("sortFns");
                $(tableElement).removeData("stupidsort_internaltable");
                $(tableElement).removeAttr("stupidsort_internaltable");
                $(tableElement).removeAttr("stupidtable.settings");
                $(tableElement).off("click.stupidtable", "thead th"); 
            }
        }
        
        function stringify(object) {
            return "(" + richType() + ") " + JSON.stringify(object, stringifyReplacer, 2);
            
            function richType() {
                if (object instanceof jQuery) {
                    return "JQuery";
                } else {
                    return Object.prototype.toString.call(object);
                }
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
        }
    }
})();
