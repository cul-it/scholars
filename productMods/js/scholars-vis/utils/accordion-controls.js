/**
 * A standard set of controls for use with the Accordion panels.
 * 
 * Selector: let the user select one from a list of items, with an optional
 * filter.
 * 
 * Checklist: present the user with checkboxes so they can choose from a list
 * of items.
 * 
 * <pre>
 * new AccordionControls.Selector(mainElementId, dataArray, selectionCallback);
 * </pre>
 */
var AccordionControls = (function() {
    return {
        Selector: Selector,
        Checklist: Checklist,
        RangeSlider: RangeSlider
        };
    
    function debugIt(message) {
        if (false) {
            var now = new Date();
            var time = now.toLocaleTimeString();
            var millis = ("000" + now.getMilliseconds().toString()).slice(-3);
            console.log(time + "." + millis + "  " + message);
        }
    }
    
    /**
     * Within the main element, display the data. When a data item is clicked,
     * execute the callback function.
     * 
     * mainElementId -- a d3 selector string
     * 
     * selectionCallback -- a function to be called when the user selects a data
     * item.
     * 
     * Methods:
     * 
     * loadData(dataArray) -- set the list of choices. 
     *     dataArray -- an array of object, each with a :label attribute, and other
     *             attributes as required by the selectionCallback function.
     *             
     * loadFromDataRequest(actionName) -- set the list of choices from the results 
     *         of a Data Distribution request. The data received is assumed to be
     *         in SPARQL SELECT JSON format, with values for 'uri' and 'label'.
     *         The data will be sorted by label (case-independent) and duplicated
     *         will be removed. 
     *     actionName -- the last element in the dataRequest path. This could 
     *             optionally include a query string (e.g. listWebSites?dept=ORG)
     * 
     * expand() -- open the selection panel
     * 
     * collapse() -- close the selection panel
     * 
     * The main element must have a descendent with id="selector", where the list
     * elements will be created.
     * 
     * The main element must have a text field descendent with id="searcher",
     * which can be used to filter the list elements.
     */
    function Selector(mainElementId, selectionCallback) {
        debugIt("create Selector");
        
        d3.select(mainElementId)
            .select("#searcher")
            .on('keyup', showMatchingItems);
        
        return {
            loadData: loadData,
            loadFromDataRequest: loadFromDataRequest,
            collapse: collapse,
            clearSelection: clearSelection
        };
        
        function showMatchingItems() {
            var query = this.value.toLowerCase();
            $(mainElementId + " #selector>li").each(showOrHide);
            
            function showOrHide() {
                if($(this).text().toLowerCase().includes(query)) {
                    $(this).show();
                }else{
                    $(this).hide();
                }
            }
        }
        
        function loadData(dataArray) {
            d3.select(mainElementId)
            .select("#selector")
            .selectAll("li")
            .data(dataArray)
            .enter()
            .append("li")
            .text(d=>d.label)
            .on("click.show", showSelection)
            .on("click.callback", selectionCallback)
        }
        
        function showSelection(d, i, nodes) {
            clearSelection();
            d3.select(this)
            .classed("current", true);
        }
        
        function clearSelection() {
            d3.select(mainElementId)
            .select("#selector")
            .selectAll("li")
            .classed("current", false);
        }
        
        /* Is this done properly? Should the mapper function be a parameter? */
        function loadFromDataRequest(actionName) {
            $.get(ScholarsVis.Utilities.baseUrl + "api/dataRequest/" + actionName).then(mapAndLoad);
            
            function mapAndLoad(data) {
                loadData(data.results.bindings.map(mapper).sort(sorter).filter(distinct));
                
                function mapper(d) {
                    return {
                        uri: d.uri.value,
                        label: d.label.value
                    }
                }
                
                function sorter(a, b) {
                    return a.label.toLowerCase().localeCompare(b.label.toLowerCase());
                }
                
                function distinct(el, i, array) {
                    return i == 0 || el.uri != array[i-1].uri;
                }
            }
        }
        
        function expand() {
            $(mainElementId + " .collapse").collapse("show");
        }

        function collapse() {
            $(mainElementId + " .collapse").collapse("hide");
        }
    }
    
    /**
     * Within the main element, display the data. When a data item is clicked,
     * execute the callback function.
     * 
     * mainElementId -- a d3 selector string
     * 
     * selectionCallback -- a function to be called when the user checks or 
     * unchecks a data item.
     * 
     * Methods:
     * 
     * loadData(array) -- set the list of choices. 
     *     array -- an array of strings, already in the desired order.
     *     
     * getChecked() -- returns an array of the checked strings.
     * 
     * updateChecks(array) -- adjust the state of each checkbox, depending on
     *         whether its text appears in this array.
     * 
     * expand() -- open the selection panel
     * 
     * collapse() -- close the selection panel
     * 
     * The main element must have a descendent with id="checkarea", where the list
     * elements will be created.
     * 
     * The main element must have a text field descendent with id="listFilter",
     * which can be used to filter the list elements.
     */
    function Checklist(mainElementId, changeCallback) {
        d3.select(mainElementId)
            .select("#listFilter")
            .on('keyup', showMatchingItems);
        
        return {
            loadData: loadData,
            getChecked: getChecked,
            updateChecks: updateChecks,
            expand: expand,
            collapse: collapse
        }
        
        function showMatchingItems() {
            var query = this.value.toLowerCase();
            $(mainElementId + " #checkarea>li").each(showOrHide);
            
            function showOrHide() {
                if($(this).text().toLowerCase().includes(query)) {
                    $(this).show();
                }else{
                    $(this).hide();
                }
            }
        }
        
       function loadData(array) {
            var anchorDiv = d3.select(mainElementId);
            var labels = anchorDiv
                .select("#checkarea")
                .selectAll("li")
                .data(array)
                .enter()
                .append("li");
            labels
                .append("input")
                .attr("checked", true)
                .attr("type", "checkbox")
                .attr("id", (d, i) => i)
                .attr("for", (d, i) => i)
                .on("change", changeCallback);
            labels
                .append("label")
                .attr("class", "checkListLabel")
                .text(d => d);
        }
        
        function getChecked() {
            return d3.select(mainElementId)
                .selectAll("#checkarea input[type='checkbox']:checked")
                .data();
        }
        
        function updateChecks(array) {
            debugIt("UpdateChecks: " + array.length);
            d3.select(mainElementId)
                .selectAll("#checkarea input[type='checkbox']")
                .each(updateCheck);
            
            function updateCheck(d) {
                if (array.includes(d)) {
                    this.checked = true;
                } else {
                    this.checked = false;
                }
            }
        }
        
        function expand() {
            $(mainElementId + " .collapse").collapse("show");
        }

        function collapse() {
            $(mainElementId + " .collapse").collapse("hide");
        }
    }
    
    /**
     * Within the main element, display a range slider (two handles). When a 
     * handle is moved, execute the callback function.
     * 
     * panelSelector -- a CSS selector string
     * 
     * changeCallback -- a function to be called when the user moves a handle
     * 
     * Methods:
     * 
     * setRange(values) -- set the limits of the range, and initialize the
     *     handle positions. 
     *     
     * getCurrentValues() -- returns an array reflecting the current positions 
     *     of the handles.
     *     
     * reset() -- restore the handles to their original positions.
     * 
     * expand() -- open the selection panel
     * 
     * collapse() -- close the selection panel
     * 
     * The main element must have a <div> descendent with id="slider", where the 
     * slider will be created.
     * 
     * Requires nouislider.min.js
     */
    function RangeSlider(panelSelector, changeCallback) {
        debugIt("Create RangeSlider on " + panelSelector);
        var sliderDiv = $(panelSelector + " #slider").get(0);  

        initialize();

        return {
            setRange: setRange,
            getCurrentValues: getCurrentValues,
            reset: resetHandles,
            expand: expand,
            collapse: collapse
        }
        
        function initialize() {
            noUiSlider.create(sliderDiv, {
                range: {
                    'min': 1,
                    'max': 100
                },
                start: [1, 100],
                connect: true,
                step: 1,
                tooltips: true,
                format: {
                    to: v => v,
                    from: v => v
                }
            });
            sliderDiv.noUiSlider.on("change", changeCallback);
        }
        
        function setRange(values) {
            sliderDiv.noUiSlider.updateOptions({
                range: {
                    min: values[0], max: values[1]
                }, 
                start: values
            }, false);
        }

        function getCurrentValues() {
            return sliderDiv.noUiSlider.get();
        }
        
        function resetHandles() {
            // Can't simply use reset() because the start values are still [1, 100], in spite of updateOptions()
            var range = sliderDiv.noUiSlider.options.range;
            sliderDiv.noUiSlider.set([range.min, range.max]);
        }
        
        function expand() {
            $(panelSelector + " .collapse").collapse("show");
        }

        function collapse() {
            $(panelSelector + " .collapse").collapse("hide");
        }

    }
})();
