/**
 * A standard set of controls for use with the Accordion panels.
 * 
 * Selector: let the user select one from a list of items, with an optional
 * filter.
 * 
 * <pre>
 * new AccordionControls.Selector(mainElementId, dataArray, selectionCallback);
 * </pre>
 */
var AccordionControls = (function() {
    return {Selector: Selector};
    
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
            collapse: collapse
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
            .on("click", selectionCallback);
        }
        
        /* Is this done properly? Should the mapper function be a parameter? */
        function loadFromDataRequest(actionName) {
            $.get(applicationContextPath + "/api/dataRequest/" + actionName).then(mapAndLoad);
            
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
})();
