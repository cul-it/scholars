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
    departmentControl.loadFromDataRequest("departmentList");
    
    var personControl = new AccordionControls.Selector(personSelector, showPersonCloud);
    personControl.loadFromDataRequest("facultyList");
    
    $(siteSelector).click(showSiteCloud);
    showSiteCloud();
    
    function showSiteCloud() {
        if (siteWc) {
            siteWc.hide();
        } else {
            siteWc = new ScholarsVis2.UniversityWordCloud({
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
        deptWc = new ScholarsVis2.DepartmentWordCloud({
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
        personWc = new ScholarsVis2.PersonWordCloud({
            target : personWcContainer,
            person : person.uri
        });
        personWc.show();
        testForEmpty(personWcContainer, personWc);
        setHeadingText(personWcContainer, person.label, person.uri);
        showClouds("person");
    }
    
    function setHeadingText(container, label, uri) {
        var span = $(container).find(".vis_toolbar span.heading")
        span.html('<a href="' + toDisplayPageUrl(uri) + '">' + label + '</a>');
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