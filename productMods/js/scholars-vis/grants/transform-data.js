/*
 * Take the data as it comes from the server, and convert it for the bubble-chart.
 * 
 * This is a limited version, in that it assumes that all values are present, 
 * and that each grant is represented only once. In the future, we will need to 
 * check for both of those.
 */
function transformGrantsData(resultSet) {
	console.log(window.location.href);
	console.log("BASE" + applicationBaseUrl);
	var uniqueId = 1;
	var bindings = resultSet.results.bindings;
	return bindings.map(transformBinding)

	function transformBinding(binding) {
		return {
			"group":      figureGrantGroup(),
			"person":     getPersonDetails(),
			"P-I-Id":     "55226-3713", // BOGUS
			"NetId":      binding.personNetid.value,
		    "Type":       "GRANT", // BOGUS?
		    "Title":      binding.grantTitle.value,
			"grant":      getGrantDetails(),
			"dept":       getDepartmentDetails(),
			"Person":     binding.personName.value,
	        "deptCode":   "CBE", // BOGUS
			"Cost":       parseInt(binding.amount.value),
			"Role":       "CO", // BOGUS
			"Department": binding.deptName.value,
			"End":        binding.endYear.value,
			"Start":      binding.startYear.value,
			"id":         getUniqueId() // BOGUS?
		};
		
		function figureGrantGroup() {
			var rawAmount = binding.amount
			if (rawAmount == null) {
				return "unknown";
			}
			var amount = parseInt(rawAmount.value);
			if (amount == 0) {
				return "unknown";
			} else if (amount <= 100000) {
				return "low";
			} else if (amount > 1000000) {
				return "high";
			} else {
				return "medium";
			}
		}
		
		function getGrantDetails() {
			return {
				"uri":   toDisplayPage(binding.grant.value),
				"title": binding.grantTitle.value
			};
		}

		function getPersonDetails() {
			return {
				"uri":   toDisplayPage(binding.person.value),
				"name":  binding.personName.value,
				"netid": binding.personNetid.value
			};
		}

		function getDepartmentDetails() {
			return {
				"code": "CBE", //BOGUS
				"name": binding.deptName.value,
				"uri":  toDisplayPage(binding.dept.value)
			};
		}
		
		function getUniqueId() {
			return uniqueId++;
		}
		
		function toDisplayPage(uri) {
			var delimiterHere = Math.max(uri.lastIndexOf('/'), uri.lastIndexOf('#'));
			var localname = uri.substring(delimiterHere + 1);
			return applicationBaseUrl + "/display/" + localname;
		}
	}
}
/*
 * Provided:
 *  
 *       {
        "grant": { "type": "uri" , "value": "http://scholars.cornell.edu/individual/gnt69457" } ,
        "grantTitle": { "type": "literal" , "value": "TRANSFER OF TECHNIQUE AND KNOW-HOW FOR ISOLATION AND CULTIVATION OF HUMAN TASTE BUDS" } ,
        "amount": { "type": "literal" , "value": "120000.0" } ,
        "person": { "type": "uri" , "value": "http://scholars.cornell.edu/individual/rd426" } ,
        "personName": { "type": "literal" , "value": "Dando, Robin" } ,
        "personNetid": { "type": "literal" , "value": "rd426" } ,
        "dept": { "type": "uri" , "value": "http://scholars.cornell.edu/individual/org86203" } ,
        "deptName": { "type": "literal" , "value": "Food Science" } ,
        "startYear": { "type": "literal" , "value": "2013" } ,
        "endYear": { "type": "literal" , "value": "2015" }
      } ,

 */

/*
 * Desired result:
 * 
 *  {
      "group":"high",
      "person":{
         "uri":"http://vivo.cornell.edu",
         "name":"ARCHER, LYNDEN A",
         "netid":"LAA25"
      },
      "P-I-Id":"55226-3713",
      "NetId":"LAA25",
      "Type":"GRANT",
      "Title":"KAUST-CORNELL CENTER FOR RESEARCH AND EDUCATION",
      "grant":{
         "uri":"http://vivo.cornell.edu",
         "title":"KAUST-CORNELL CENTER FOR RESEARCH AND EDUCATION"
      },
      "dept":{
         "code":"CBE",
         "name":"Chemical and Biomolecular Engineering",
         "uri":"http://vivo.cornell.edu"
      },
      "Person":"ARCHER, LYNDEN A",
      "deptCode":"CBE",
      "Cost":24987685,
      "Role":"CO",
      "Department":"Chemical and Biomolecular Engineering",
      "End":2015,
      "Start":2008,
      "id":55226
   },
   
   Where group:
     high: over 1,000,000
     medium: between 1,000,000 and 100,000
     low: under 100,000
     unknown: unknown or 0
 */
