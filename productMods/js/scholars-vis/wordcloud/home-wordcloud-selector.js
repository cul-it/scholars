/**
 * When the page comes up, bring up the university word cloud. Add two selectors
 * and a link.
 * 
 * Person selector brings up the person wordcloud for the person Academic unit
 * selector brings up the dept wordcloud
 */
function createWordCloudSelector(siteSelector, departmentSelector, personSelector, 
                                 site_wc_container, unit_wc_container, person_wc_container) {
  var wc;  
  $(siteSelector).click(showSiteCloud);
  
  var departmentControl = new AccordionControls.Selector(departmentSelector, showDepartmentCloud);
  departmentControl.loadFromDataRequest("departmentList");
  
  var personControl = new AccordionControls.Selector(personSelector, showPersonCloud);
  personControl.loadFromDataRequest("facultyList");
  
  var personToolbar = new ScholarsVis.Toolbar(person_wc_container);
  var unitToolbar = new ScholarsVis.Toolbar(unit_wc_container);
  var siteToolbar = new ScholarsVis.Toolbar(site_wc_container);

  showSiteCloud();
  
  function showSiteCloud() {
    if (wc) { wc.hide()};
    wc = new ScholarsVis.UniversityWordCloud({
      target : site_wc_container + ' #vis',
    });
    wc.show();
    $(site_wc_container + '>#exporter').click(wc.showVisData);
    showSelection(siteToolbar);
    showClouds("site");
  }
  
  function showDepartmentCloud(unit) {
    if (wc) { wc.hide()};
    wc = new ScholarsVis.DepartmentWordCloud({
      target : unit_wc_container + ' #vis',
      department : unit.uri
    });
    wc.show();
    $(unit_wc_container + '>#exporter').click(wc.showVisData);
    showSelection(unitToolbar, unit.label, unit.uri);
    showClouds("unit");
  }
  
  function showPersonCloud(person) {
    if (wc) { wc.hide()};
    wc = new ScholarsVis.PersonWordCloud({
      target : person_wc_container + ' #vis',
      person : person.uri
    });
    wc.show();
    $(person_wc_container + ' #exporter').click(wc.showVisData);
    showSelection(personToolbar, person.label, person.uri);
    showClouds("person");
  }
  
  function showSelection(toolbar, message, uri) {
    if ( typeof message == "undefined") {
      toolbar.setHeadingText("University-wide research keywords");
    } else if ( typeof uri == "undefined") {
      toolbar.setHeadingText("Research keywords for " + message);
    } else {
      toolbar.setHeadingText('Research keywords for <a href="' + toDisplayPageUrl(uri) + '">' + message + '</a>');
    }
  }
  
  function showClouds(which) {
    if (which == "unit") {
      $(site_wc_container).hide();
      $(unit_wc_container).show();
      $(person_wc_container).hide();
    } else if (which == "person") {
      $(site_wc_container).hide();
      $(unit_wc_container).hide();
      $(person_wc_container).show();
    } else { // site
      $(site_wc_container).show();
      $(unit_wc_container).hide();
      $(person_wc_container).hide();
    }
  }
}
