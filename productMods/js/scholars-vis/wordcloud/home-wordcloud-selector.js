/**
 * When the page comes up, bring up the university word cloud. Add two selectors
 * and a link.
 * 
 * Person selector brings up the person wordcloud for the person Academic unit
 * selector brings up the dept wordcloud
 */
function createWordCloudSelector(siteSelector, departmentSelector, personSelector, 
        siteWcContainer, unitWcContainer, personWcContainer, unitHelpText, personHelpText) {
    var siteWc;
    var personWc;
    var deptWc;
    
    var departmentControl = new AccordionControls.Selector(departmentSelector, showDepartmentCloud);
    departmentControl.loadFromDataRequest("optinDepartmentList");
    
    var personControl = new AccordionControls.Selector(personSelector, showPersonCloud);
    personControl.loadFromDataRequest("optinFacultyList");
    
    $(siteSelector).click(showSiteCloud);
    showSiteCloud();
    
    function showSiteCloud() {
        if (siteWc) {
            siteWc.hide();
        } else {
            siteWc = new ScholarsVis.UniversityWordCloud.FullVisualization({
                target : siteWcContainer,
            });
        }          
        siteWc.show();
        showClouds("site");
    }
    
    function showDepartmentCloud(unit) {
        if (deptWc) { 
            deptWc.hide()
        };
        deptWc = new ScholarsVis.WordCloud.FullDepartmentVisualization({
            target : unitWcContainer,
            department : unit.uri
        });
        deptWc.show();
        testForEmpty(unitWcContainer, deptWc);
        setHeadingText(unitWcContainer, unit.label, unit.uri);
        showClouds("unit");
    }
    
    function showPersonCloud(person) {
        if (personWc) { 
            personWc.hide()
        };
        personWc = new ScholarsVis.WordCloud.FullPersonVisualization({
            target : personWcContainer,
            person : person.uri
        });
        personWc.show();
        testForEmpty(personWcContainer, personWc);
        setHeadingText(personWcContainer, person.label, person.uri);
        showClouds("person");
    }
    
    function setHeadingText(container, label, uri) {
        var span = $(container).find("#title_bar span.heading")
        span.html('<a href="' + ScholarsVis.Utilities.toDisplayUrl(uri) + '">' + label + '</a>');
    }

    function testForEmpty(container, vis) {
        vis.examineData(function(data) {
            if (data.length == 0) {
                vis.showView("empty");
            }
        });
    }
    
    
   function showClouds(which) {
        if (which == "unit") {
            $(siteWcContainer).hide();
            $(unitWcContainer).show();
            $(personWcContainer).hide();
            $(personHelpText).hide();
            $(unitHelpText).show();
        } else if (which == "person") {
            $(siteWcContainer).hide();
            $(unitWcContainer).hide();
            $(personWcContainer).show();
            $(personHelpText).show();
            $(unitHelpText).hide();
        } else { // site
            $(siteWcContainer).show();
            $(unitWcContainer).hide();
            $(personWcContainer).hide();
            $(personHelpText).hide();
            $(unitHelpText).show();
        }
    }
}
