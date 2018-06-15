/*******************************************************************************
 *
 * The glue that binds the original world-map code to the ScholarsVis script.
 *
 ******************************************************************************/

ScholarsVis["GlobalCollaboration"] = function(options) {
    var defaults = {
            fetch : fetcher,
            showProgress : progressShower,
            hideProgress : progressHider,
            views : {
                vis : {
                    display : visDisplayer,
                    closer: visCloser,
                    export : {
                        svg : {
                            filename: "globalCollaboration.svg",
                            call: exportGlobalCollaborationVisAsSvg
                        },
                        json : {
                            filename: "globalCollaboration.json",
                            call: exportGlobalCollaborationVisAsJson
                        }
                    }
                },
                table: {
                    display : tableDisplayer,
                    closer : tableCloser,
                    export : {
                        csv : {
                            filename: "globalCollaborationTable.csv",
                            call: exportGlobalCollaborationTableAsCSV,
                        },
                        json : {
                            filename: "globalCollaborationTable.json",
                            call: exportGlobalCollaborationTableAsJSON
                        }
                    }
                }
            }
    };
    return new ScholarsVis.Visualization(options, defaults);
    
    function fetcher(options) {
        return $.when(
                $.get(urlsBase+"/api/dataRequest/collabus"), 
                $.get(urlsBase+"/api/dataRequest/collabworld")
                ).then(storeData);
        
        function storeData(usData, worldData) {
            window.countryRaw = usData[0];
            window.worldRaw = worldData[0];
            options.fetched = {};
        }
    }
    
    function visDisplayer() {
        word = "usa"
        window.filterVariable = false;
        drawWorld(window.worldRaw);
        d3.selectAll("#rh-panel").style("visibility", "visible")
    }

    function visCloser(target) {
        $(target).find("svg").remove();
    }
    
    function progressShower() {
        $("#nowShowing").text("Loading map visualization"); 
        $("#time-indicator").show();
    }
    
    function progressHider() {
        $("#nowShowing").text("All");
        $("#time-indicator").hide();
    }
    
    function exportGlobalCollaborationVisAsSvg(data, filename, options) {
        if (word == "world") {
            ScholarsVis.Utilities.exportAsSvg("WORLD-" + filename, $(options.target).find("svg")[0]);
        } else {
            ScholarsVis.Utilities.exportAsSvg("US-" + filename, $(options.target).find("svg")[0]);
        }
    }

    function exportGlobalCollaborationVisAsJson(data, filename, options) {
        if (word == "world") {
            ScholarsVis.Utilities.exportAsJson("WORLD-" + filename, transformForJsonExport(worldRaw));
        } else {
            ScholarsVis.Utilities.exportAsJson("US-" + filename, transformForJsonExport(countryRaw));
        }
        
        function transformForJsonExport(data) {
            return Object.keys(data).sort().map(doRegion);
            
            function doRegion(key) {
                var regionStruct = data[key];
                return {
                    "name" : key,
                    "publicationCount" : regionStruct.length,
                    "collaboratingCornellResearchers" : buildCollaboratorMap(
                            auth => {return auth.authorName}, 
                            auth => {return auth.cornellAffiliation}),
                    "collaboratingInstitutions" : buildCollaboratorMap(
                            auth => {return auth.authorAffiliation.localName}, 
                            auth => {return !auth.cornellAffiliation})
                }
                
                function buildCollaboratorMap(nameGetter, qualifier) {
                    var researcherMap = {}
                    regionStruct.forEach(collabsFromPubs);
                    return pivotCollaboratorMap(researcherMap);
                    
                    function collabsFromPubs(pubStruct) {
                        var collaborators = new Set();
                        pubStruct.authors.forEach(addCollaborator);
                        mergeIntoMap(researcherMap, collaborators);
                        
                        function addCollaborator(authorStruct) {
                            if (qualifier(authorStruct)) {
                                collaborators.add(nameGetter(authorStruct));
                            }
                        }
                        
                        function mergeIntoMap(map, set) {
                            set.forEach(incrementCount);
                            
                            function incrementCount(name) {
                                map[name] = 1 + (map[name] || 0);
                            }
                        }
                    }
                    
                    function pivotCollaboratorMap(map) {
                        return Object.keys(map).sort().map(pivotOne);
                        
                        function pivotOne(name) {
                            return {
                              name: name,
                              publicationCount: map[name]
                            };
                        } 
                    }
                }
            }
        }
    }
    
    function tableDisplayer(data, target, options) {
        createTable("#world-table.vis_table", window.worldRaw, "country");
        createTable("#country-table.vis_table", window.countryRaw, "state");
        $('[data-view-id=table] input:radio[name=map]').off("change.ScholarsVis");
        $('[data-view-id=table] input:radio[name=map]').on("change.ScholarsVis", flipTables);
        $('[data-view-id=table] input:radio[name=map]:checked').change();
        
        function flipTables(e) {
            $(".vis_table").hide();
            if (e.target.value === "world") {
                $("#world-table.vis_table").show();
            } else {
                $("#country-table.vis_table").show();
            }
        }
        
        function createTable(selector, rawData, keyName) {
            var tableElement = $(target).find(selector).get(0);
            var table = new ScholarsVis.VisTable(tableElement);
            dataForTable(rawData, keyName).forEach(addRowToTable);
            table.complete();

            function addRowToTable(rowData) {
                table.addRow(rowData[keyName], rowData.publicationCount);
            }
        }
    }
    
    function tableCloser(target) {
        $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
    }
    
    function exportGlobalCollaborationTableAsCSV(data, filename) {
        var which = $('[data-view-id=table] input:radio[name=map]:checked').val();
        if (which == "world") {
            ScholarsVis.Utilities.exportAsCsv("WORLD-" + filename, dataForTable(window.worldRaw, "country"));
        } else {
            ScholarsVis.Utilities.exportAsCsv("US-" + filename, dataForTable(window.countryRaw, "state"));
        }
    }
    
    function exportGlobalCollaborationTableAsJSON(data, filename) {
        var which = $('[data-view-id=table] input:radio[name=map]:checked').val();
        if (which == "world") {
            ScholarsVis.Utilities.exportAsJson("WORLD-" + filename, dataForTable(window.worldRaw, "country"));
        } else {
            ScholarsVis.Utilities.exportAsJson("US-" + filename, dataForTable(window.countryRaw, "state"));
        }
    }
    
    function dataForTable(rawData, keyName) {
        return Object.keys(rawData).sort().map(dataToRow);
        
        function dataToRow(key) {
            var row = {};
            row[keyName] = key;
            row.publicationCount = rawData[key].length
            return row;
        }
    }
    
};

/*******************************************************************************
 *
 * The original world-map code.
 *
 ******************************************************************************/

$.extend(this, urlsBase);

function drawCountryMap(articles) {


    articles['NY'] = articles['NY'].filter(nyFilter);

    var urls = {
        us:   urlsBase+"/api/dataRequest/usjson",
        keys: urlsBase+"/api/dataRequest/stateshash"
    }

    var margin = { top: 10, left: 0, bottom: 10, right: 15 }
    , width = parseInt(d3.select('.col-md-8').style('width'))
    , width = width - margin.left - margin.right
    , mapRatio = .6
    , height = width * mapRatio;

    // projection and path setup
    var projection = d3.geo.albersUsa()
    .scale(width)
    .translate([width / 2, height / 2]);

    var path = d3.geo.path()
    .projection(projection);

    // scales and axes
    var colors = d3.scale.quantize()
    .range(['#e0f3db', '#ccebc5', '#a8ddb5', '#7bccc4', '#4eb3d3', '#2b8cbe', '#0868ac', '#084081']);

    // make a map
    var map = d3.select('#mapViz').append('svg')
    .attr("id", "mapsvg")
    .style('height', height + 'px')
    .style('width', width + 'px');



    

    // queue and render

    d3.queue()
    .defer(d3.json, urls.us)
    .defer(d3.csv, urls.keys)
    .await(render);

    // catch the resize
    d3.select(window).on('resize', resize);
    d3.select("#clear").on("click", function(d){
        window.filterVariable = false;
        hideSidebar();
        destroyMap(); 
        restoreYears();



         currentData = data; 

        if(word == "usa"){
            drawCountryMap(window.countryRaw); 
        }

        else{
            drawWorldMap(window.worldRaw);
        }

       
        d3.select("#nowShowing").text("All"); 
        $("#subjectInput").val(""); 
        $("#academicInput").val(""); 
    })

    var g = map.append("g");

    var rect = g.append("rect")
    .attr("id", "background-rectangle")
    .attr("x", 0 + 'px')
    .attr("y", 0 + 'px')
    .attr("height", height + 'px')
    .attr("width", width + 'px')
    .style("fill", "white");

    rect.on("click", hideSidebar);

    $("#hamburgerIcon").on("click", function() {
            hideSidebar()
        })



    function render(err, us, abbr) {
        statesDict = {}

        abbr.forEach(function (entry) {
            statesDict[entry.full] = entry.short
        });

        //var stateCounts = getCounts(articles)[1];

        var states = topojson.feature(us, us.objects.states);
        //console.log(states.features);
        function getStateCounts(d) {
            var stateName = d.properties.name.toUpperCase();
            var short = statesDict[stateName];

            if (articles.hasOwnProperty(short)) {
                var smallerArticles = articles[short]; 
                
                return smallerArticles.length;
                
            }
            else {
                return 0;
            }
        }    

        function fillSidebar(d) {
            var state = statesDict[d.properties.name.toUpperCase()];
            window.state = state;
            arts = currentData[state]; 

            //console.log(arts);

            if(arts.length == 0){
                d3.select("#researchers1").selectAll("p").remove();
                d3.select("#institutions").selectAll("p").remove();
                d3.select("#bigCounts").html("(0)");
            }


            var researchersList = arts.map(d=>d.authors).reduce((a,b)=>a.concat(b)).filter(fromCornell); 
            var topResearchers = authorCounter(researchersList).filter(hasURI);
            //console.log(topResearchers);
            d3.select("#researchers1").selectAll("p").remove();
            
            //This is for presenting the persons with the links
            //d3.select("#researchers1").selectAll("p")
            //    .data(topResearchers).enter()
            //        .append("p").attr("class", "linked")
            //        .append("a").attr("href", d=>d.uri).html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 
            
            // This is for presenting the persons with no links
            d3.select("#researchers1").selectAll("p")
                .data(topResearchers).enter()
                    .append("p").attr("class", "unlinked").html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 
            
            
            var institutionList = arts.map(oneAuthor).reduce((a,b)=>a.concat(b)).filter(correctState);
            var topInstitutions = institutionCounter(institutionList).filter(containsCornell);
            
            d3.select("#institutions").selectAll("p").remove();
            
            //This is for presenting the institutions with the links
            //d3.select("#institutions").selectAll("p")
            //    .data(topInstitutions).enter().append("p").attr("class", returnLink)
            //    .append("a").attr("href", d=>d.uri).attr("target", "_blank").html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 
            
            // This is for presenting the institutions with no links
            d3.select("#institutions").selectAll("p")
                .data(topInstitutions).enter()
                .append("p").attr("class", "unlinked").html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 

            d3.select("#bigCounts").html(d=>"("+arts.length+")");

        }
        function hasURI(d){
            if (d.uri !== null){
                return true; 
            }
            else{
                return false;
            }
        }

        function oneAuthor(d){
            var authors = d.authors; 
            //for author
            var instList = []; 
            var uniqueAuthors = authors.filter(function(d){
                if ($.inArray(d.authorAffiliation.localName, instList) == -1){
                    instList.push(d.authorAffiliation.localName)
                    return true;
                }
                else{
                    return false; 
                }
            });

            return uniqueAuthors;
        }
        function containsCornell(d){
            if (d.name.toLowerCase().includes("cornell")){
                return false; 
            }
            else{
                return true; 
            }
        }
        function returnLink(d){
            if (d.uri){
                return "linked";
            }
            else{
                return "unlinked";
            }
        }

        function correctState(d){

            if(d.state == window.state){
                return true;
            }
            else{
                return false; 
            }
        }
        function fromCornell(d){
            if (d.authorAffiliation.localName === "Cornell University" || d.authorAffiliation.localName === "CORNELL UNIV"){
                return true;
            }
            else{
                return false;
            }
        }

        function notCornell(d){
            return !fromCornell(d); 
        }


        function stateClick(d) {
            sidebar(d);
            fillSidebar(d);

            d3.selectAll(".state")
                .style('fill', function (d) {

                if (getStateCounts(d) == 0){
                    return "#d3d3d3";
                }
                else{
                    return colors(Math.log(getStateCounts(d)));
                }
            });
            d3.select(this).style("fill", "#EF7633");
        }

        var tooltip = d3.select("#mapViz")
        .append("div")
        .style("position", "absolute")
        .style("z-index", "10")
        .attr("id", "newTip")
        .style("visibility", "hidden")
        .text("a simple tooltip");
        
        var tip = d3.tip().attr('class', 'd3-tip').html(function (d) { return d.properties.name + " (" + getStateCounts(d) + ")"; });

        /* Invoke the tip in the context of your visualization */
        map.call(tip)

        function stateMouseover(d) {
            state = d;
            tooltip.style("visibility", "visible");
            tooltip.text(state.properties.name + " (" + getStateCounts(state) + ")");
        }
        function stateMove(d){
            var coordinates = d3.mouse(this);
            return tooltip.style("top", (coordinates[1])+"px").style("left",(coordinates[0])+"px");
        }
        function stateMouseout(d) {
            return tooltip.style("visibility", "hidden");
        }



        var min = d3.max([1, d3.min(d3.values(articles).map(d => Math.log(d.length)))]); 

        colors.domain([min, d3.max(d3.values(articles).map(d => Math.log(d.length)))]);
        //console.log(colors.domain());
        
        var statePaths = g.selectAll('path.state')
        .data(states.features)
        .enter().append('path')
        .attr('class', 'state')
        .attr('d', path)
        .on("click", stateClick)
        .on("mouseover", stateMouseover)
        .on("mousemove", stateMove)
        .on("mouseout", stateMouseout)
        .style("cursor","pointer")
        .style('fill', function (d) {

            if (getStateCounts(d) == 0){
                return "#d3d3d3";
            }
            else{
                return colors(Math.log(getStateCounts(d)));
            }
        });

        addLegend("#legendDiv", colors)

    }





    function resize() {
        // adjust things when the window size changes
        width = parseInt(d3.select('.col-md-8').style('width'));
        width = width - margin.left - margin.right;
        height = width * mapRatio;

        // update projection
        projection
        .translate([width / 2, height / 2])
        .scale(width);

        // resize the map container
        map
        .style('width', width + 'px')
        .style('height', height + 'px');

        // resize the map
        map.select('.land').attr('d', path);
        map.selectAll('.state').attr('d', path);
    }



    

}///drawCountyMap


function destroyMap() {
    hideSidebar();
    d3.select("#mapsvg").remove()
}


function sidebar(d) {
    var panel = d3.select("#rh-panel");

    $(function(){  // $(document).ready shorthand
      $('#panel-icon').fadeOut('fast');
      $('.onPanel').fadeIn('fast')
    });

    d3.select("#hamburgerIcon").style("visibility", "visible");
    d3.selectAll(".list").style({"border-style":"solid", "border-color": "white", "border-width": "1px"});
    d3.selectAll(".rule").transition(500).delay(500).style("display", "block");
    if (panel.classed('closed')) {
        panel.style("width", "25%");
        panel.classed("closed", false);
        panel.select("#areaTitle").style("opacity", 0).html(d.properties.name + "<span id='bigCounts'></span>").transition(500).delay(500).style("opacity", 1);
    }

    else {
        panel.select("#areaTitle").style("opacity", 0).html(d.properties.name + "<span id='bigCounts'></span>").transition(100).delay(100).style("opacity", 1);
    }

    d3.select("#res").text("Featured Cornell Researchers");
    d3.select("#inst").text("Featured Institutions");
}


function hideSidebar() {
    var panel = d3.select("#rh-panel");

    $(function(){  
      $('#panel-icon').fadeIn('slow');
      $('.onPanel').fadeOut('fast');
    });
    panel.style("width", "0%");

    panel.classed("closed", true)
    d3.select("#hamburgerIcon").style("visibility", "hidden");
    panel.select("#areaTitle").style("opacity", 0).text("");
    d3.select("#researchers1").selectAll("p").remove();
    d3.select("#institutions").selectAll("p").remove();
    d3.selectAll(".heading-travis").text("");
    d3.selectAll(".list").style("border", "hidden");
    d3.selectAll(".rule").style("display", "none");
}




function drawWorldMap(data) {
    d3.select("#hamburgerIcon").style("visibility", "hidden");
    
    data['KOREA'] = data['SOUTH KOREA'];

    var urls = {
        world: urlsBase+"/api/dataRequest/topoc"
    }

    var margin = { top: 30, left: 10, bottom: 10, right: 15 }
    , width = parseInt(d3.select('.col-md-8').style('width'))
    , width = width - margin.left - margin.right
    , mapRatio = .6
    , height = width * mapRatio + 10;

    var formats = {
        percent: d3.format('%')
    };

    // projection and path setup
    var projection = d3.geo.mercator()
    .scale(width / 6)
    .translate([width / 2, (height)/ 2 + 75]);

    var path = d3.geo.path()
    .projection(projection);

    // scales and axes
    var colors = d3.scale.quantize()
    .range(['#e0f3db', '#ccebc5', '#a8ddb5', '#7bccc4', '#4eb3d3', '#2b8cbe', '#0868ac']);

    // make a map
    var map = d3.select('#mapViz').append('svg')
    .attr("id", "mapsvg")
    .style('height', height + 'px')
    .style('width', width + 'px');

    var rect = map.append("rect")
    .attr("id", "background-rectangle")
    .attr("x", 0 + 'px')
    .attr("y", 0 + 'px')
    .attr("height", height + 'px')
    .attr("width", width + 'px')
    .style("fill", "white");

    rect.on("click", hideSidebar);

    // queue and render
    d3.queue()
    .defer(d3.json, urls.world)
    .await(render);

    // catch the resize
    d3.select(window).on('resize', resize);
    d3.select("#clear").on("click", function(d){
        hideSidebar();
        destroyMap(); 
        restoreYears();
        window.filterVariable = false;

        currentData = window.data; 

        if(word == "usa"){
            
            drawCountryMap(window.countryRaw); 
        }

        else{
           
            drawWorldMap(window.worldRaw);
        }

        
        d3.select("#nowShowing").text("All"); 
        $("#subjectInput").val(""); 
        $("#academicInput").val(""); 
    });

    function render(err, world) {

        window.world = world;

        data['UNITED STATES'] = []; 
        //console.log(data);

        colors.domain([0,d3.max((d3.values(data).map(d=>d.length)))]);
        //console.log(colors.domain());


        var tip = d3.tip().attr('class', 'd3-tip').html(function (d) { 
            var nameKey = d.properties.name.toUpperCase();
            //console.log(data[nameKey].length);
            return d.properties.name + " ("+data[nameKey].length+")"; 
        });




        var tooltip = d3.select("#mapViz")
        .append("div")
        .style("position", "absolute")
        .style("z-index", "10")
        .attr("id", "newTip")
        .style("visibility", "hidden")
        .text("a simple tooltip");

        /* Invoke the tip in the context of your visualization */
        map.call(tip)

    function countryMouseover(d) {
            var country = d;
            var nameKey = country.properties.name.toUpperCase();

            //console.log(nameKey);

            //console.log(d);
            tooltip.style("visibility", "visible");
            if(data[nameKey]){
                tooltip.text(country.properties.name + " (" + data[nameKey].length + ")");
            }
            else{
             tooltip.text(country.properties.name + " (" + 0 + ")");
         }
     }


     function countryMove(d){
        var coordinates = d3.mouse(this);
        return tooltip.style("top", (coordinates[1])+"px").style("left",(coordinates[0])+"px");
     }
     function countryMouseout(d) {
        tooltip.style("visibility", "hidden");
    }

    $("span#hamburgerIcon").on("click", function() {
        hideSidebar()
    });

    map.selectAll("path")
    .data(topojson.feature(world, world.objects.countries).features)
    .enter()
    .append("path")
    .attr("class", "state")
    .attr("id", d=>d.id)
    .attr("d", path)
    .style("cursor","pointer")
    .style("fill", function (d) {
        if(d.properties.name == "United States"){
            return "#4d4d4d";
        }
        if(data[d.properties.name.toUpperCase()]){
            if (data[d.properties.name.toUpperCase()].length == 0){
                return "#d3d3d3";
            }
            return colors(data[d.properties.name.toUpperCase()].length);
        }
        else{
            return "#d3d3d3";
        }
    })
    .on("mouseover", countryMouseover)
    .on("mousemove", countryMove)
    .on("mouseout", countryMouseout)
    .on("click", countryClick);

    addLegend("#legendDiv", colors)


    function countryClick(d){
        if (d.id !== "USA"){
            //console.log(d);
            d3.selectAll(".state").style("fill", function (d) {
                if(d.properties.name == "United States"){
                    return "#4d4d4d";
                }
                if(data[d.properties.name.toUpperCase()]){
                    if (data[d.properties.name.toUpperCase()].length == 0){
                        return "#d3d3d3";
                    }
                    return colors(data[d.properties.name.toUpperCase()].length);
                }
                else{
                    return "#d3d3d3";
                }
            })
            d3.select(this).style("fill","#EF7633");
            sidebar(d);
            fillCountrySidebar(d);
        }
    }

    function fillCountrySidebar(d){
        var country = d.properties.name.toUpperCase(); 
        window.country = country;
        arts = currentData[country];
        //console.log(arts);

        if(!arts || arts.length == 0){
            d3.select("#researchers1").selectAll("p").remove();
            d3.select("#institutions").selectAll("p").remove();
            d3.select("#bigCounts").html("(0)");
        }

        else{
            var researchersList = arts.map(d=>d.authors).reduce((a,b)=>a.concat(b)).filter(fromCornell); 
            var topResearchers = authorCounter(researchersList).filter(hasURI);
            //console.log(topResearchers);
            d3.select("#researchers1").selectAll("p").remove();
            
            // This is for the linked persons
            // d3.select("#researchers1").selectAll("p")
            //     .data(topResearchers).enter()
            //     .append("p")
            //     .attr("class", "linked")
            //     .append("a").attr("href", d=>d.uri).html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 

            // This is for the unlinked persons
            d3.select("#researchers1").selectAll("p")
                .data(topResearchers).enter()
                .append("p")
                .attr("class", "unlinked")
                .html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 




            var institutionList = arts.map(oneAuthor).reduce((a,b)=>a.concat(b)).filter(correctCountry);
            var topInstitutions = institutionCounter(institutionList).filter(containsCornell);
            d3.select("#institutions").selectAll("p").remove();
            
            // This is for the linked institutions
            // d3.select("#institutions").selectAll("p")
            //     .data(topInstitutions).enter()
            //     .append("p").attr("class", returnLink)
            //     .append("a").attr("href", d=>d.uri).attr("target", "_blank").html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 

            // This is for presenting the institutions with no links
             d3.select("#institutions").selectAll("p")
                .data(topInstitutions).enter()
                .append("p")
                .attr("class", "unlinked")
                .html(d=>"<span class='long-name'>"+ d.name + "</span><span class='counts'>(" + d.count + ") </span>"); 


            d3.select("#bigCounts").html(d=>"("+arts.length+")");

        }
    }   

    function hasURI(d){
        if (d.uri !== null){
            return true; 
        }
        else{
            return false;
        }
    }

    function oneAuthor(d){
        var authors = d.authors; 
            //for author
            var instList = []; 
            var uniqueAuthors = authors.filter(function(d){
                if ($.inArray(d.authorAffiliation.localName, instList) == -1){
                    instList.push(d.authorAffiliation.localName)
                    return true;
                }
                else{
                    return false; 
                }
            });

            return uniqueAuthors;
        }
        function containsCornell(d){
            if (d.name.toLowerCase().includes("cornell")){
                return false; 
            }
            else{
                return true; 
            }
        }
        function returnLink(d){
            if (d.uri){
                return "linked";
            }
            else{
                return "unlinked";
            }
        }

        function correctCountry(d){
            //console.log(d);
            if(d.country == window.country){
                return true;
            }
            else{
                return false; 
            }
        }
        function fromCornell(d){
            if (d.authorAffiliation.localName === "Cornell University" || d.authorAffiliation.localName === "CORNELL UNIV"){
                return true;
            }
            else{
                return false;
            }
        }

        function notCornell(d){
            return !fromCornell(d); 
        }


        

    }

    function resize() {
        // adjust things when the window size changes
        var margin = { top: 10, left: 10, bottom: 10, right: 15 }
        , width = parseInt(d3.select('.col-md-8').style('width'))
        , width = width - margin.left - margin.right
        , mapRatio = .5
        , height = width * mapRatio;

        // update projection
        var projection = d3.geo.mercator()
        .scale(width / 6)
        .translate([width / 2, height / 2]);

        // resize the map container
        map
        .style('width', width + 'px')
        .style('height', height + 'px');

        // resize the map
        map.select('.land').attr('d', path);
        map.selectAll('.state').attr('d', path);
    }

}


/*
getCounts accepts an array of objects that have been parsed from json input. 
Returns: an array with two objects.
*/
function getCounts(testObjects) {

    var collabCounter = {};
    var statesCounter = {};

    testObjects.forEach(function (paper) {
        paper.authors.forEach(function (author) {
            if (collabCounter.hasOwnProperty(author.country)) {
                collabCounter[author.country]++;
            }
            else {
                collabCounter[author.country] = 1;
            }
            if (author.country === "UNITED STATES") {
                if (statesCounter.hasOwnProperty(author.state)) {
                    if (!author.cornellAffiliation && author.authorAffiliation !== "Cornell University" && author.authorAffiliation !== "CORNELL UNIV") {
                        statesCounter[author.state]++;
                    }
                }
                else {
                    statesCounter[author.state] = 1;
                }
            }
        })
    })

    return [collabCounter, statesCounter];
}

function addLegend(target, scale) {
    d3.selectAll("#legend").remove();
    if (window.word == "usa"){

        if (scale.domain()[0] < 1 || scale.domain()[1] < 1){
        var legendSvg = d3.select("#legendDiv").append("svg").attr("width", 250).attr("height", 200).attr("id", "legend");
        legendSvg.append("rect").attr("height", 20).attr("width", 20).attr("x", 10).attr("y", 10 ).style("fill", scale.range().pop());
        legendSvg.append("text").attr("x", 12 + 10).attr("y",45).text("<= 2").style("alignment-baseline", "middle").style("font-size", 12).style("text-anchor", "middle");
        }
        else{

        var increment = scale.domain()[1]/scale.range().length;
        //console.log(increment);
        var legendSvg = d3.select("#legendDiv").append("svg").attr("width", 250).attr("height", 200).attr("id", "legend");
        
        scale.range().forEach(function (d, i) {
            legendSvg.append("rect").attr("height", 20).attr("width", 20).attr("x", 10 + i * 25).attr("y", 10 ).style("fill", d);
            legendSvg.append("text").attr("x", 12 + 10 + i * 25).attr("y",45).text(function(d){
                if (i == 0){
                    return Math.floor(Math.exp(increment*i));
                }
                else if(i==7){
                    return Math.ceil(Math.exp(increment*(i+1))); 
                }
                else{
                    return '' 
                }
            }).style("alignment-baseline", "middle").style("font-size", 12).style("text-anchor", "middle");
          
            })
        }
    }
    else{

        /*if (scale.domain()[1] <= 2){
            console.log(scale.domain());
        var legendSvg = d3.select("#legendDiv").append("svg").attr("width", 250).attr("height", 200).attr("id", "legend");
        legendSvg.append("rect").attr("height", 20).attr("width", 20).attr("x", 10).attr("y", 10 ).style("fill", scale.range().pop());
        legendSvg.append("text").attr("x", 12 + 10).attr("y",45).text("<= 2").style("alignment-baseline", "middle").style("font-size", 12).style("text-anchor", "middle");
        }*/
        //else{
       d3.selectAll("#legend").remove();
       var increment = scale.domain()[1]/scale.range().length;
       //
       //console.log(increment);
       var legendSvg = d3.select("#legendDiv").append("svg").attr("width", 250).attr("height", 200).attr("id", "legend");

       scale.range().forEach(function (d, i) {
        legendSvg.append("rect").attr("height", 20).attr("width", 20).attr("x", 10 + i * 25).attr("y", 10).style("fill", d);
        legendSvg.append("text").attr("x", 12 + 10 + i * 25).attr("y", 45).text(function(d){
            if (i == 0){
                    return Math.floor(increment*i)+1
                }
                else if(i==6){
                    return  Math.floor(increment*(i+1)); 
                }
                else{
                    return '' 
                }
        }).style("alignment-baseline", "middle").style("font-size", 12).style("text-anchor", "middle");
        //console.log(d);
        });
        //}
        }
    }   

function drawCountry(data) {
    window.data = data;
    window.currentData = data; 
    drawCountryMap(window.currentData);
    addListeners();
    addChecks("#academicUnit", filterUnitsForOptIn(getAcademicUnits(window.currentData)), "academic");
    addChecks("#subjectArea", getSubjectArea(window.currentData), "subject");
    addClicks();
    addListSearch();
    addYears(currentData);
}

function drawWorld(data){
    window.data = data;   
    window.currentData = data;
    window.word = "world";
    drawWorldMap(data);
    addListeners();
    addChecks("#academicUnit", filterUnitsForOptIn(getAcademicUnits(window.currentData)), "academic");
    addChecks("#subjectArea", getSubjectArea(window.currentData), "subject");
    addClicks();
    addListSearch();
    addYears(currentData);
}

function hideFields() {
    d3.select("#areaTitle").text("");
}

function uniqueCountPreserve(inputArray){
    //Sorts the input array by the number of time
    //each element appears (largest to smallest)

    //Count the number of times each item
    //in the array occurs and save the counts to an object
    var arrayItemCounts = {};
    for (var i in inputArray){
        if (!(arrayItemCounts.hasOwnProperty(inputArray[i]))){
            arrayItemCounts[inputArray[i]] = 1
        } else {
            arrayItemCounts[inputArray[i]] += 1
        }
    }

    //Sort the keys by value (smallest to largest)
    //please see Markus R's answer at: http://stackoverflow.com/a/16794116/4898004
    var keysByCount = Object.keys(arrayItemCounts).sort(function(a, b){
        return arrayItemCounts[a]-arrayItemCounts[b];
    });

    //Reverse the Array and Return
    return(keysByCount.reverse())
}

function getAcademicUnits(articles){
    var units = [];
    Object.keys(articles).forEach(function(state){
        var stateArticles = articles[state]; 
        var stateAuthors = stateArticles.map(d=>d.authors).map(d=>d===null ? [] : d).reduce((a, b)=>a.concat(b)); 
        //console.log(state);
        var stateUnits = stateAuthors.map(d=>d.cornellAffiliation).map(d=>d===null ? [] : d).reduce((a, b)=>a.concat(b)); 
        //console.log(stateUnits);
        units.push(stateUnits); 
    })

    units = units.reduce((a,b)=>a.concat(b)); 
    return _.uniq(units); 
}

function filterUnitsForOptIn(units) {
    // BOGUS HARDCODED LIST
    var OPT_IN_UNITS = [
       "College of Agriculture and Life Sciences",
       "College of Engineering",
       "Cornell SC Johnson College of Business"
       ];

	return units.filter(u => OPT_IN_UNITS.includes(u));
}

function getSubjectArea(articles){
    var areas = []; 
    Object.keys(articles).forEach(function(state){
        var stateArticles = articles[state]; 
        var stateAreas = stateArticles.map(d=>d.subjectAreas).map(d=>d===null ? [] : d).reduce((a, b)=>a.concat(b)); 
        areas.push(stateAreas); 
    })
    return _.uniq(areas.reduce((a,b)=>a.concat(b))); 
}

function addChecks(target, list, classWord){
   var anchorDiv = d3.select(target); 

   anchorDiv.selectAll("p").remove();

   var labels = anchorDiv.selectAll("div")
   .data(list.sort())
   .enter()
   .append("p")
   .attr("class","listy list-item-"+ classWord)
   .html(d=>d);  
}

function addClicks(){
    d3.selectAll(".list-item-academic").on("click", academicClick); 
    d3.selectAll(".list-item-subject").on("click", subjectAreaClick); 
}

function academicClick(d){

    window.filterVariable = ['academic', d];
    hideSidebar();
    destroyMap();
    window.currentData = []; 


    if (word == "usa"){

        for (var property in window.countryRaw){
            currentData[property] = window.countryRaw[property].filter(function(article){
                var stateAuthors = article.authors.map(d=>d===null ? [] : d);
                var stateUnits = stateAuthors.map(d=>d.cornellAffiliation).map(d=>d===null ? [] : d).reduce((a, b)=>a.concat(b)); 
                if($.inArray(d, stateUnits) !== -1){
                    return true;
                }
                else{
                    return false; 
                }

            }); 
        }


        drawCountryMap(currentData);
    }

    if (word == "world"){
        //console.log("filtering world based on: " + d);
        for (var property in window.worldRaw){
            currentData[property] = window.worldRaw[property].filter(function(article){
                //console.log(article);
                var stateAuthors = article.authors.map(d=>d===null ? [] : d);
                var stateUnits = stateAuthors.map(d=>d.cornellAffiliation).map(d=>d===null ? [] : d).reduce((a, b)=>a.concat(b)); 
                if($.inArray(d, stateUnits) !== -1){
                    return true;
                }
                else{
                    return false; 
                }

            }); 
        }
        //console.log(currentData);

        drawWorldMap(currentData); 
    }




    restoreYears(); 

    d3.select("#nowShowing").text(d);
}

function subjectAreaClick(d){

    window.filterVariable = ['subject', d];
    var articles = window.data; 
    hideSidebar();
    destroyMap();
    window.currentData = []; 

    //console.log("subject clicked: " + d);
    //console.log(currentData); 

    if(window.word =="usa"){
         for (var property in window.countryRaw){
        currentData[property] = window.countryRaw[property].filter(function(article){
            if ($.inArray(d, article.subjectAreas) !== -1){
                return true; 
            }
            else{
                return false; 
            }
        }); 
        }
        //console.log(currentData);
        drawCountryMap(currentData);  
    }
    else{
        for (var property in window.worldRaw){
        currentData[property] = window.worldRaw[property].filter(function(article){
            if ($.inArray(d, article.subjectAreas) !== -1){
                return true; 
            }
            else{
                return false; 
            }
        }); 
    }
        //console.log("WorldMap: ");    
        //console.log(currentData);
        drawWorldMap(currentData);
    }
    restoreYears();
    d3.select("#nowShowing").text(d);
}


function getYears(articles){
    var years = []; 
    Object.keys(articles).forEach(function(state){
        var stateArticles = articles[state]; 
        var stateYears = stateArticles.map(d=>+d.yearOfPublication); 
        years.push(stateYears); 
    }) 
    return _.uniq(years.reduce((a,b)=>a.concat(b))); 
}
function addYears(articles){

    var yearExtent = d3.extent(getYears(articles)); 
    window.min = yearExtent[0]; 
    window.max = yearExtent[1]; 
    var range = document.getElementById('range');
    noUiSlider.create(range, {
          start: yearExtent, // Handle start position
          connect: true, // Display a colored bar between the handles
          step: 1, 
          tooltips: true,
          format: {
            to: function ( value ) {
              return value;
          },
          from: function ( value ) {
              return value;
          }}, 
          range: { // Slider can select '0' to '100'
          'min': yearExtent[0],
          'max': yearExtent[1]
      }, 
      pips: {
          mode: 'values',
          values: yearExtent, 
          density: 75
      }
  });

        range.noUiSlider.on("change", function(values, handle){
        /*window.filterVariable = ['years', values];
+        hideSidebar();
+        destroyMap();
+        window.currentData = []; 
+      
+        if (word == "usa"){
+              for (var property in window.data){
+            currentData[property] = window.data[property].filter(function(article){
+                if (article.yearOfPublication >= values[0] && article.yearOfPublication <= values[1]){
+                    return true; 
+                }
+                else{
+                    return false; 
+                }
+            }); 
+            }
+            drawCountryMap(window.currentData);
+        }
+
+        if (word == "world"){
+            drawWorldMap(window.currentData);
+        }
+
+        d3.select("#nowShowing").text("Articles Published: " + values[0] + " - " + values[1]);
+
+        */
            window.filterVariable = ['years', values];
            hideSidebar();
            destroyMap();
            rangeChange(values);
        });
    };
    


//return a filtered list of {name:"", count: "", uri: ""}

function authorCounter(array){
    var returnObject = {}; 
    array.forEach(function(author){
        if (returnObject.hasOwnProperty(author.authorName)){
            returnObject[author.authorName].count++; 
        }
        else{
            returnObject[author.authorName] = {
                name: author.authorName, 
                count: 1, 
                uri: author.authorURI
            }
        }
    }); 

    var returnArray = []; 
    for (var property in returnObject){
        if(returnObject.hasOwnProperty(property)){
            returnArray.push(returnObject[property]);
        }
    }
    
    return returnArray.sort(function(x,y){
        return d3.descending(x.count, y.count);
    });
}

function institutionCounter(array){
    var returnObject = {}; 
    array.forEach(function(author){
        if (returnObject.hasOwnProperty(author.authorAffiliation.localName)){
            returnObject[author.authorAffiliation.localName].count++; 
        }
        else{
            returnObject[author.authorAffiliation.localName] = {
                name: author.authorAffiliation.localName, 
                count: 1, 
                uri: author.authorAffiliation.gridURI
            }
        }
    }); 

    var returnArray = []; 
    for (var property in returnObject){
        if(returnObject.hasOwnProperty(property)){
            returnArray.push(returnObject[property]);
        }
    }
    
    return returnArray.sort(function(x,y){
        return d3.descending(x.count, y.count);
    });
}

function nyFilter(d){
    var nyNotCornell = 0; 
    d.authors.forEach(function(author){
        if (author.state == 'NY' && author.authorAffiliation.localName !== 'Cornell University' && author.authorAffiliation.localName !== 'CORNELL UNIV'){
            nyNotCornell++; 
        }
    })
    return nyNotCornell > 0 ? true : false; 

}

function update(articles){
    d3.selectAll(".state").data(articles).style("fill", "white"); 
}

function restoreYears(){
    var slider = document.getElementById('range'); 
    range.noUiSlider.set([window.min, window.max]);
}

function addListSearch(){

    $('#academicInput').on('keyup', function() {
        //console.log(this.value); 
        var query = this.value.toLowerCase();

        $('.list-item-academic').each(function(i, elem) {
            if (elem.innerHTML.toLowerCase().indexOf(query) != -1) {
                $(this).closest('p').show();

            }else{
                $(this).closest('p').hide();

            }
        });

    });

    $('#subjectInput').on('keyup', function() {
        //console.log(this.value); 
        var query = this.value.toLowerCase();

        $('.list-item-subject').each(function(i, elem) {
            if (elem.innerHTML.toLowerCase().indexOf(query) != -1) {
                $(this).closest('p').show();

            }else{
                $(this).closest('p').hide();

            }
        });

    });
}
function addListeners(){
      d3.selectAll('[data-view-id=vis] input[name="map"]').on("change", function(d){
        word = d3.select('[data-view-id=vis] input[name="map"]:checked').node().value;  
    
        destroyMap(); 
    
        if(!window.filterVariable){
            d3.select("#nowShowing").text("All"); 
    
            if (word==="usa"){
    
                drawCountry(window.countryRaw)
                
            }
    
            if (word==="world"){
                drawWorld(window.worldRaw);
            }   
        }
        else{
            //console.log("There is a filter variable set");
            if(window.filterVariable[0] == 'subject'){
                subjectAreaClick(window.filterVariable[1]);
            }
            else if (window.filterVariable[0] == 'years'){
                rangeChange(window.filterVariable[1]);
            }
            else{
                academicClick(window.filterVariable[1]);
            }
        }
    
    
    });
    }
    
    
    function rangeChange(yearsArray){
    
        currentData = []
        if(word=="usa"){
            for (var property in window.countryRaw){
                currentData[property] = window.countryRaw[property].filter(function(article){
                    if(article.yearOfPublication >= yearsArray[0] && article.yearOfPublication <= yearsArray[1]){
                        return true;
                    }
                    else{
                        return false; 
                    }
                })
            }
    
            drawCountryMap(currentData)
        }
        else{
             for (var property in window.worldRaw){
                currentData[property] = window.worldRaw[property].filter(function(article){
                    if(article.yearOfPublication >= yearsArray[0] && article.yearOfPublication <= yearsArray[1]){
                        return true;
                    }
                    else{
                        return false; 
                    }
                })
            }
    
            drawWorldMap(currentData)
    
        }
    
        d3.select("#nowShowing").text("Articles Published: " + yearsArray[0] + " - " + yearsArray[1]);
    }
