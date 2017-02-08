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
  populateSelector(departmentControl, "departmentList");
  
  var personControl = new AccordionControls.Selector(personSelector, showPersonCloud);
  populateSelector(personControl, "facultyList");
  
  showSiteCloud();
  
  function showSiteCloud() {
    if (wc) { wc.hide()};
    wc = new ScholarsVis.UniversityWordCloud({
      target : site_wc_container + ' #vis',
    });
    wc.show();
    $(site_wc_container + '>#exporter').click(wc.showVisData);
    showSelection("Scholars@Cornell");
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
    showSelection(unit.label, unit.uri);
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
    showSelection(person.label, person.uri);
    showClouds("person");
  }
  
  function showSelection(message, uri) {
    if ( typeof uri == "undefined") {
      $("#selectedWordCloudLabel").html("Keyword cloud for " + message);
    } else {
      $("#selectedWordCloudLabel").html('Keyword cloud for <a href="' + toDisplayPageUrl(uri) + '">' + message + '</a>');
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
  
  function populateSelector(selector, dataRequest) {
    $.get(applicationContextPath + "/api/dataRequest/" + dataRequest).then(mapAndLoad);
    
    function mapAndLoad(data) {
      selector.loadData(data.results.bindings.map(mapper).sort(sorter).filter(distinct));
      
      function mapper(d) {
        return {
          uri: d.uri.value,
          label: d.label.value
        }
      }
      
      function sorter(a, b) {
        return a.label > b.label;
      }
      
      function distinct(el, i, array) {
        return i == 0 || el.uri != array[i-1].uri;
      }
    }
  }
}
