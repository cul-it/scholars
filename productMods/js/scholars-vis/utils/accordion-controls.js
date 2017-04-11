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
     * dataArray -- an array of object, each with a :label attribute, and other
     * attributes as required.
     * 
     * selectionCallback -- a function to be called when the user selects a data
     * item.
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
            loadFromDataRequest: loadFromDataRequest
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
        function loadFromDataRequest(dataRequest) {
            $.get(applicationContextPath + "/api/dataRequest/" + dataRequest).then(mapAndLoad);
            
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
    }
})();
